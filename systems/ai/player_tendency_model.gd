class_name PlayerTendencyModel
extends RefCounted

const SAVE_VERSION := 1
const MIN_EVIDENCE := 3.0
const DECAY_PER_POSSESSION := 0.93
const MAX_ACTION_WEIGHT := 24.0
const RECENT_ACTION_LIMIT := 8

var _attempts: Dictionary = {}
var _successes: Dictionary = {}
var _recent_sequence: Array[StringName] = []


func observe(action: StringName, succeeded: bool = true, weight: float = 1.0) -> void:
    var safe_weight := clampf(weight, 0.0, 3.0)
    _attempts[action] = minf(
        MAX_ACTION_WEIGHT,
        float(_attempts.get(action, 0.0)) + safe_weight
    )
    if succeeded:
        _successes[action] = minf(
            MAX_ACTION_WEIGHT,
            float(_successes.get(action, 0.0)) + safe_weight
        )
    _recent_sequence.append(action)
    if _recent_sequence.size() > RECENT_ACTION_LIMIT:
        _recent_sequence.pop_front()


func finish_possession() -> void:
    _decay_dictionary(_attempts)
    _decay_dictionary(_successes)


func tendency(action: StringName) -> float:
    var total := _total_attempts()
    if total < MIN_EVIDENCE:
        return 0.0
    return float(_attempts.get(action, 0.0)) / maxf(total, 1.0)


func confidence(action: StringName) -> float:
    return clampf(float(_attempts.get(action, 0.0)) / 8.0, 0.0, 1.0)


func success_rate(action: StringName) -> float:
    var attempts := float(_attempts.get(action, 0.0))
    if attempts < MIN_EVIDENCE:
        return 0.5
    return float(_successes.get(action, 0.0)) / attempts


func repeated_action(minimum_repeats: int = 3) -> StringName:
    if _recent_sequence.size() < minimum_repeats:
        return &""
    var candidate := _recent_sequence[-1]
    for offset in range(2, minimum_repeats + 1):
        if _recent_sequence[-offset] != candidate:
            return &""
    return candidate


func dominant_tendency() -> StringName:
    if _total_attempts() < MIN_EVIDENCE:
        return &""
    var best_action := &""
    var best_weight := 0.0
    for key in _attempts.keys():
        var weight := float(_attempts[key])
        if weight > best_weight:
            best_weight = weight
            best_action = StringName(key)
    return best_action


func to_dictionary() -> Dictionary:
    return {
        "version": SAVE_VERSION,
        "attempts": _string_key_dictionary(_attempts),
        "successes": _string_key_dictionary(_successes),
    }


func from_dictionary(data: Dictionary) -> void:
    _attempts.clear()
    _successes.clear()
    var saved_attempts: Dictionary = {}
    var saved_successes: Dictionary = {}
    if typeof(data.get("attempts", {})) == TYPE_DICTIONARY:
        saved_attempts = data.get("attempts", {})
    if typeof(data.get("successes", {})) == TYPE_DICTIONARY:
        saved_successes = data.get("successes", {})
    for key in saved_attempts.keys():
        _attempts[StringName(key)] = clampf(
            float(saved_attempts.get(key, 0.0)),
            0.0,
            MAX_ACTION_WEIGHT
        )
    for key in saved_successes.keys():
        _successes[StringName(key)] = clampf(
            minf(
                float(saved_successes.get(key, 0.0)),
                float(_attempts.get(StringName(key), 0.0))
            ),
            0.0,
            MAX_ACTION_WEIGHT
        )
    _recent_sequence.clear()


func reset_short_term_memory() -> void:
    _recent_sequence.clear()
    _scale_dictionary(_attempts, 0.65)
    _scale_dictionary(_successes, 0.65)


func _total_attempts() -> float:
    var total := 0.0
    for value in _attempts.values():
        total += float(value)
    return total


func _decay_dictionary(values: Dictionary) -> void:
    _scale_dictionary(values, DECAY_PER_POSSESSION)


func _scale_dictionary(values: Dictionary, multiplier: float) -> void:
    for key in values.keys():
        values[key] = float(values[key]) * multiplier
        if float(values[key]) < 0.05:
            values.erase(key)


func _string_key_dictionary(values: Dictionary) -> Dictionary:
    var result := {}
    for key in values.keys():
        result[String(key)] = snappedf(float(values[key]), 0.001)
    return result
