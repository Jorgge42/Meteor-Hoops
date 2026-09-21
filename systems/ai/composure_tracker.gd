class_name ComposureTracker
extends RefCounted

const SAVE_VERSION := 1
const MAX_METER := 100.0
const VARIETY_WINDOW := 4
const REPEAT_PENALTY := 10.0
const SAFE_POSSESSION_GAIN := 16.0
const DEFENSIVE_STOP_GAIN := 18.0
const TURNOVER_PENALTY := 24.0

var meter := 0.0
var current_chain := 0
var best_chain := 0
var roars_silenced := 0
var games := 0
var _recent_actions: Array[StringName] = []


func start_match(saved_profile: Dictionary = {}) -> void:
    from_dictionary(saved_profile)
    games += 1
    meter = 0.0
    current_chain = 0
    _recent_actions.clear()


func observe(action: StringName) -> Dictionary:
    if action == &"":
        return {"recorded": false}

    var repeated := _recent_actions.has(action)
    var delta := 0.0
    if repeated:
        current_chain = 1
        _recent_actions.clear()
        _recent_actions.append(action)
        delta = -REPEAT_PENALTY
    else:
        current_chain += 1
        best_chain = maxi(best_chain, current_chain)
        _recent_actions.append(action)
        if _recent_actions.size() > VARIETY_WINDOW:
            _recent_actions.pop_front()
        delta = 12.0 + minf(float(current_chain), 4.0) * 3.0
    return _apply_delta(delta, repeated, action)


func begin_possession() -> void:
    current_chain = 0
    _recent_actions.clear()


func reward_safe_possession() -> Dictionary:
    return _apply_delta(SAFE_POSSESSION_GAIN, false, &"safe_possession")


func reward_defensive_stop() -> Dictionary:
    return _apply_delta(DEFENSIVE_STOP_GAIN, false, &"defensive_stop")


func punish_turnover() -> Dictionary:
    current_chain = 0
    _recent_actions.clear()
    return _apply_delta(-TURNOVER_PENALTY, true, &"turnover")


func reset_short_term_memory() -> void:
    meter *= 0.50
    current_chain = 0
    _recent_actions.clear()


func to_dictionary() -> Dictionary:
    return {
        "version": SAVE_VERSION,
        "games": games,
        "best_composure_chain": best_chain,
        "roars_silenced": roars_silenced,
    }


func from_dictionary(data: Dictionary) -> void:
    games = clampi(int(data.get("games", 0)), 0, 9999)
    best_chain = clampi(int(data.get("best_composure_chain", 0)), 0, 999)
    roars_silenced = clampi(int(data.get("roars_silenced", 0)), 0, 9999)
    meter = 0.0
    current_chain = 0
    _recent_actions.clear()


func _apply_delta(delta: float, repeated: bool, source: StringName) -> Dictionary:
    var before := meter
    meter = clampf(meter + delta, 0.0, MAX_METER)
    var activated := meter >= MAX_METER
    if activated:
        meter = 0.0
        roars_silenced += 1
        current_chain = 0
        _recent_actions.clear()
    return {
        "recorded": true,
        "source": source,
        "repeated": repeated,
        "delta": meter - before if not activated else MAX_METER - before,
        "meter": meter,
        "chain": current_chain,
        "best_chain": best_chain,
        "activated": activated,
    }
