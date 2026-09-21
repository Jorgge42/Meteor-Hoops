class_name CrownLegacyTracker
extends RefCounted

const SAVE_VERSION := 1
const LEGACY_PER_EDICT := 34.0
const MAX_LEGACY := 100.0

var legacy_meter := 0.0
var active_edict := &"balanced"
var broken_this_match := 0
var best_edicts_broken := 0
var crowns_shattered := 0
var games := 0

var _broken_cycle: Array[StringName] = []
var _unique_actions: Array[StringName] = []
var _pass_fake_armed := false
var _active_edict_broken := false


func start_match(saved_profile: Dictionary = {}) -> void:
    from_dictionary(saved_profile)
    games += 1
    legacy_meter = 0.0
    active_edict = &"balanced"
    broken_this_match = 0
    _broken_cycle.clear()
    _reset_edict_progress()


func set_edict(edict: StringName) -> void:
    active_edict = edict
    _reset_edict_progress()


func begin_possession() -> void:
    _unique_actions.clear()
    _pass_fake_armed = false


func observe_action(
    action: StringName,
    prediction_broken: bool = false
) -> Dictionary:
    if action == &"":
        return {"recorded": false}
    if not _unique_actions.has(action):
        _unique_actions.append(action)
    if action == &"pass_fake":
        _pass_fake_armed = true
    if active_edict == &"written_fate" and prediction_broken:
        return _break_active_edict(&"prediction_broken")
    return {
        "recorded": true,
        "broken": false,
        "unique_actions": _unique_actions.size(),
        "pass_fake_armed": _pass_fake_armed,
    }


func observe_completed_pass() -> Dictionary:
    if active_edict == &"night_hunt" and _pass_fake_armed:
        _pass_fake_armed = false
        return _break_active_edict(&"fake_then_pass")
    return {"recorded": true, "broken": false}


func observe_home_score(shot_type: String) -> Dictionary:
    if active_edict == &"iron_throne" and shot_type in ["JUMPER", "3PT"]:
        return _break_active_edict(&"perimeter_score")
    if active_edict == &"royal_command" and _unique_actions.size() >= 3:
        return _break_active_edict(&"varied_score")
    return {"recorded": true, "broken": false}


func broken_edict_keys() -> Array[StringName]:
    return _broken_cycle.duplicate()


func reset_short_term_memory() -> void:
    _unique_actions.clear()
    _pass_fake_armed = false


func to_dictionary() -> Dictionary:
    return {
        "version": SAVE_VERSION,
        "games": games,
        "best_edicts_broken": best_edicts_broken,
        "crowns_shattered": crowns_shattered,
    }


func from_dictionary(data: Dictionary) -> void:
    games = clampi(int(data.get("games", 0)), 0, 9999)
    best_edicts_broken = clampi(
        int(data.get("best_edicts_broken", 0)),
        0,
        999
    )
    crowns_shattered = clampi(int(data.get("crowns_shattered", 0)), 0, 9999)
    legacy_meter = 0.0
    active_edict = &"balanced"
    broken_this_match = 0
    _broken_cycle.clear()
    _reset_edict_progress()


func _break_active_edict(source: StringName) -> Dictionary:
    if (
        _active_edict_broken
        or active_edict == &"balanced"
        or _broken_cycle.has(active_edict)
    ):
        return {"recorded": true, "broken": false}

    _active_edict_broken = true
    var broken_edict := active_edict
    _broken_cycle.append(broken_edict)
    broken_this_match += 1
    best_edicts_broken = maxi(best_edicts_broken, broken_this_match)
    legacy_meter = minf(MAX_LEGACY, legacy_meter + LEGACY_PER_EDICT)
    var shattered := legacy_meter >= MAX_LEGACY
    var cycle_count := _broken_cycle.size()
    if shattered:
        legacy_meter = 0.0
        crowns_shattered += 1
        _broken_cycle.clear()
    return {
        "recorded": true,
        "broken": true,
        "edict": broken_edict,
        "source": source,
        "legacy_meter": legacy_meter,
        "cycle_count": cycle_count,
        "broken_this_match": broken_this_match,
        "shattered": shattered,
    }


func _reset_edict_progress() -> void:
    _unique_actions.clear()
    _pass_fake_armed = false
    _active_edict_broken = false
