class_name SequencePredictionModel
extends RefCounted

const SAVE_VERSION := 1
const START_ACTION := &"possession_start"
const MIN_CONTEXT_EVIDENCE := 3.0
const MIN_PREDICTION_CONFIDENCE := 0.52
const DECAY_PER_POSSESSION := 0.94
const MAX_TRANSITION_WEIGHT := 18.0
const MAX_CONTEXTS := 16

var _transitions: Dictionary = {}
var _context: StringName = START_ACTION


func begin_possession() -> void:
    _context = START_ACTION


func observe(action: StringName, weight: float = 1.0) -> Dictionary:
    if action == &"":
        return {"recorded": false}

    var forecast := predict_next()
    var actual_probability := transition_probability(_context, action)
    var result := {
        "recorded": true,
        "had_prediction": bool(forecast.get("available", false)),
        "predicted": StringName(forecast.get("action", &"")),
        "actual": action,
        "correct": false,
        "confidence": float(forecast.get("confidence", 0.0)),
        "surprise": 0.0,
        "context": _context,
    }
    if bool(result["had_prediction"]):
        result["correct"] = StringName(result["predicted"]) == action
        result["surprise"] = clampf(1.0 - actual_probability, 0.0, 1.0)

    var safe_weight := clampf(weight, 0.0, 3.0)
    var row: Dictionary = _transitions.get(_context, {})
    row[action] = minf(
        MAX_TRANSITION_WEIGHT,
        float(row.get(action, 0.0)) + safe_weight
    )
    _transitions[_context] = row
    _context = action
    return result


func predict_next() -> Dictionary:
    var row: Dictionary = _transitions.get(_context, {})
    var evidence := _row_total(row)
    var best_action := &""
    var best_weight := 0.0
    for key in row.keys():
        var action_weight := float(row.get(key, 0.0))
        if action_weight > best_weight:
            best_weight = action_weight
            best_action = StringName(key)

    var share := best_weight / maxf(evidence, 1.0)
    var evidence_factor := clampf(evidence / 8.0, 0.0, 1.0)
    var confidence := clampf(share * (0.55 + evidence_factor * 0.45), 0.0, 1.0)
    var available := (
        evidence >= MIN_CONTEXT_EVIDENCE
        and confidence >= MIN_PREDICTION_CONFIDENCE
        and best_action != &""
    )
    return {
        "available": available,
        "action": best_action if available else &"",
        "candidate": best_action,
        "confidence": confidence if available else 0.0,
        "evidence": evidence,
        "entropy": _normalized_entropy(row),
        "context": _context,
    }


func transition_probability(context: StringName, action: StringName) -> float:
    var row: Dictionary = _transitions.get(context, {})
    var total := _row_total(row)
    if total <= 0.0:
        return 0.0
    return clampf(float(row.get(action, 0.0)) / total, 0.0, 1.0)


func finish_possession() -> void:
    _scale_transitions(DECAY_PER_POSSESSION)
    begin_possession()


func reset_short_term_memory() -> void:
    _scale_transitions(0.72)
    begin_possession()


func to_dictionary() -> Dictionary:
    var saved_transitions := {}
    for context in _transitions.keys():
        var saved_row := {}
        var row: Dictionary = _transitions.get(context, {})
        for action in row.keys():
            saved_row[String(action)] = snappedf(float(row[action]), 0.001)
        if not saved_row.is_empty():
            saved_transitions[String(context)] = saved_row
    return {
        "version": SAVE_VERSION,
        "transitions": saved_transitions,
    }


func from_dictionary(data: Dictionary) -> void:
    _transitions.clear()
    var saved_transitions = data.get("transitions", {})
    if typeof(saved_transitions) != TYPE_DICTIONARY:
        begin_possession()
        return

    var contexts_loaded := 0
    for context_key in saved_transitions.keys():
        if contexts_loaded >= MAX_CONTEXTS:
            break
        var saved_row = saved_transitions.get(context_key, {})
        if typeof(saved_row) != TYPE_DICTIONARY:
            continue
        var row := {}
        for action_key in saved_row.keys():
            var value := clampf(
                float(saved_row.get(action_key, 0.0)),
                0.0,
                MAX_TRANSITION_WEIGHT
            )
            if value >= 0.05:
                row[StringName(action_key)] = value
        if not row.is_empty():
            _transitions[StringName(context_key)] = row
            contexts_loaded += 1
    begin_possession()


func _row_total(row: Dictionary) -> float:
    var total := 0.0
    for value in row.values():
        total += float(value)
    return total


func _normalized_entropy(row: Dictionary) -> float:
    var total := _row_total(row)
    if total <= 0.0 or row.size() <= 1:
        return 0.0
    var entropy := 0.0
    for value in row.values():
        var probability := float(value) / total
        if probability > 0.0:
            entropy -= probability * log(probability)
    return clampf(entropy / log(float(row.size())), 0.0, 1.0)


func _scale_transitions(multiplier: float) -> void:
    for context in _transitions.keys():
        var row: Dictionary = _transitions.get(context, {})
        for action in row.keys():
            row[action] = float(row[action]) * multiplier
            if float(row[action]) < 0.05:
                row.erase(action)
        if row.is_empty():
            _transitions.erase(context)
        else:
            _transitions[context] = row
