class_name SaveManager
extends RefCounted

const SAVE_PATH := "user://meteor_hoops_save.json"
const PLAYER_IDS := ["kiro", "luma", "bato", "nilo", "mako"]
const PLAYER_NAMES := {
    "kiro": "Kiro", "luma": "Luma", "bato": "Bato", "nilo": "Nilo", "mako": "Mako"
}

static func default_profile() -> Dictionary:
    return {
        "version": 9,
        "intro_seen": false,
        "seen_story_chapters": [],
        "tutorial_completed": false,
        "training_unlocked": false,
        "highest_unlocked_match": 1,
        "campaign_completed": false,
        "completed_matches": [],
        "best_scores": {},
        "last_result": {},
        "match_history": [],
        "preferred_trio": ["kiro", "luma", "bato"],
        "difficulty": "ADVENTURE",
        "shot_feedback": true,
        "reduced_fx": false,
        "high_contrast": false,
        "player_progress": _default_player_progress(),
        "season_totals": _default_season_totals(),
        "adaptive_profile": {
            "version": 1,
            "attempts": {},
            "successes": {}
        },
        "sequence_profile": {
            "version": 1,
            "transitions": {}
        },
        "semifinal_profile": {
            "version": 1,
            "games": 0,
            "best_composure_chain": 0,
            "roars_silenced": 0
        },
        "final_profile": {
            "version": 1,
            "games": 0,
            "best_edicts_broken": 0,
            "crowns_shattered": 0
        },
        "last_progression": []
    }

static func _default_player_progress() -> Dictionary:
    var result := {}
    for id in PLAYER_IDS:
        result[id] = {
            "xp": 0, "level": 1, "mvp": 0, "upgrade_points": 0,
            "upgrades": {"speed": 0, "shooting": 0, "passing": 0, "defense": 0, "strength": 0}
        }
    return result

static func _default_season_totals() -> Dictionary:
    var result := {}
    for id in PLAYER_IDS:
        result[id] = {
            "games": 0, "points": 0, "assists": 0, "rebounds": 0,
            "steals": 0, "blocks": 0, "fgm": 0, "fga": 0, "3pm": 0, "3pa": 0,
            "ftm": 0, "fta": 0, "fouls": 0, "turnovers": 0
        }
    return result

static func load_profile() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return default_profile()
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return default_profile()
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        return default_profile()
    var profile := default_profile()
    for key in parsed.keys():
        profile[key] = parsed[key]
    if bool(profile.get("intro_seen", false)):
        var seen: Array = profile.get("seen_story_chapters", [])
        if not seen.has("chapter_01_pre"):
            seen.append("chapter_01_pre")
        profile["seen_story_chapters"] = seen
    _ensure_v9(profile)
    profile["version"] = 9
    return profile

static func _ensure_v9(profile: Dictionary) -> void:
    var progress: Dictionary = profile.get("player_progress", {})
    var defaults := _default_player_progress()
    for id in PLAYER_IDS:
        var current: Dictionary = progress.get(id, {})
        var fallback: Dictionary = defaults[id]
        for key in fallback.keys():
            if not current.has(key):
                current[key] = fallback[key].duplicate(true) if typeof(fallback[key]) == TYPE_DICTIONARY else fallback[key]
        current["level"] = level_from_xp(int(current.get("xp", 0)))
        var upgrades: Dictionary = current.get("upgrades", {})
        for stat in ["speed", "shooting", "passing", "defense", "strength"]:
            upgrades[stat] = int(upgrades.get(stat, 0))
        current["upgrades"] = upgrades
        var spent := 0
        for stat in upgrades.keys():
            spent += int(upgrades[stat])
        var earned := maxi(0, int(current["level"]) - 1)
        current["upgrade_points"] = maxi(int(current.get("upgrade_points", 0)), maxi(0, earned - spent))
        progress[id] = current
    profile["player_progress"] = progress

    var totals: Dictionary = profile.get("season_totals", {})
    var total_defaults := _default_season_totals()
    for id in PLAYER_IDS:
        var row: Dictionary = totals.get(id, {})
        var fallback_row: Dictionary = total_defaults[id]
        for key in fallback_row.keys():
            if not row.has(key):
                row[key] = fallback_row[key]
        totals[id] = row
    profile["season_totals"] = totals
    if not profile.has("last_progression"):
        profile["last_progression"] = []
    var adaptive = profile.get("adaptive_profile", {})
    if typeof(adaptive) != TYPE_DICTIONARY:
        profile["adaptive_profile"] = {
            "version": 1,
            "attempts": {},
            "successes": {}
        }
    else:
        if typeof(adaptive.get("attempts", {})) != TYPE_DICTIONARY:
            adaptive["attempts"] = {}
        if typeof(adaptive.get("successes", {})) != TYPE_DICTIONARY:
            adaptive["successes"] = {}
        adaptive["version"] = 1
        profile["adaptive_profile"] = adaptive
    var sequence = profile.get("sequence_profile", {})
    if typeof(sequence) != TYPE_DICTIONARY:
        profile["sequence_profile"] = {
            "version": 1,
            "transitions": {}
        }
    else:
        if typeof(sequence.get("transitions", {})) != TYPE_DICTIONARY:
            sequence["transitions"] = {}
        sequence["version"] = 1
        profile["sequence_profile"] = sequence
    var semifinal = profile.get("semifinal_profile", {})
    if typeof(semifinal) != TYPE_DICTIONARY:
        profile["semifinal_profile"] = {
            "version": 1,
            "games": 0,
            "best_composure_chain": 0,
            "roars_silenced": 0
        }
    else:
        semifinal["version"] = 1
        semifinal["games"] = clampi(int(semifinal.get("games", 0)), 0, 9999)
        semifinal["best_composure_chain"] = clampi(
            int(semifinal.get("best_composure_chain", 0)),
            0,
            999
        )
        semifinal["roars_silenced"] = clampi(
            int(semifinal.get("roars_silenced", 0)),
            0,
            9999
        )
        profile["semifinal_profile"] = semifinal
    var final_state = profile.get("final_profile", {})
    if typeof(final_state) != TYPE_DICTIONARY:
        profile["final_profile"] = {
            "version": 1,
            "games": 0,
            "best_edicts_broken": 0,
            "crowns_shattered": 0
        }
    else:
        final_state["version"] = 1
        final_state["games"] = clampi(int(final_state.get("games", 0)), 0, 9999)
        final_state["best_edicts_broken"] = clampi(
            int(final_state.get("best_edicts_broken", 0)),
            0,
            999
        )
        final_state["crowns_shattered"] = clampi(
            int(final_state.get("crowns_shattered", 0)),
            0,
            9999
        )
        profile["final_profile"] = final_state
    var completed: Array = profile.get("completed_matches", [])
    profile["campaign_completed"] = (
        bool(profile.get("campaign_completed", false))
        or completed.has("match_10")
    )

static func save_profile(profile: Dictionary) -> bool:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(profile, "  "))
    return true

static func mark_intro_seen(profile: Dictionary) -> Dictionary:
    profile["intro_seen"] = true
    return mark_story_seen(profile, "chapter_01_pre")

static func mark_story_seen(profile: Dictionary, story_id: String) -> Dictionary:
    var seen: Array = profile.get("seen_story_chapters", [])
    if not seen.has(story_id):
        seen.append(story_id)
    profile["seen_story_chapters"] = seen
    save_profile(profile)
    return profile

static func has_seen_story(profile: Dictionary, story_id: String) -> bool:
    var seen: Array = profile.get("seen_story_chapters", [])
    return seen.has(story_id)

static func mark_tutorial_completed(profile: Dictionary) -> Dictionary:
    profile["tutorial_completed"] = true
    save_profile(profile)
    return profile

static func set_preferred_trio(profile: Dictionary, ids: Array) -> Dictionary:
    if ids.size() == 3:
        profile["preferred_trio"] = ids.duplicate()
        save_profile(profile)
    return profile

static func set_options(profile: Dictionary, difficulty: String, shot_feedback: bool, reduced_fx: bool, high_contrast: bool) -> Dictionary:
    profile["difficulty"] = difficulty
    profile["shot_feedback"] = shot_feedback
    profile["reduced_fx"] = reduced_fx
    profile["high_contrast"] = high_contrast
    save_profile(profile)
    return profile

static func complete_match(profile: Dictionary, match_id: String, match_number: int, home_score: int, away_score: int, stats: Dictionary = {}) -> Dictionary:
    var completed: Array = profile.get("completed_matches", [])
    if not completed.has(match_id):
        completed.append(match_id)
    profile["completed_matches"] = completed
    if match_number == 1:
        profile["training_unlocked"] = true
    if match_number == 10:
        profile["campaign_completed"] = true
    profile["highest_unlocked_match"] = maxi(int(profile.get("highest_unlocked_match", 1)), mini(10, match_number + 1))

    var best_scores: Dictionary = profile.get("best_scores", {})
    var current_best := int(best_scores.get(match_id, -1))
    if home_score > current_best:
        best_scores[match_id] = home_score
    profile["best_scores"] = best_scores
    _apply_progression(profile, stats, true)
    profile["last_result"] = _result_dict(match_id, match_number, home_score, away_score, true, stats)
    _append_history(profile, profile["last_result"])
    save_profile(profile)
    return profile

static func record_defeat(profile: Dictionary, match_id: String, match_number: int, home_score: int, away_score: int, stats: Dictionary = {}) -> Dictionary:
    _apply_progression(profile, stats, false)
    profile["last_result"] = _result_dict(match_id, match_number, home_score, away_score, false, stats)
    _append_history(profile, profile["last_result"])
    save_profile(profile)
    return profile

static func level_from_xp(xp: int) -> int:
    var level := 1
    while level < 10 and xp >= xp_threshold_for_level(level + 1):
        level += 1
    return level

static func xp_threshold_for_level(level: int) -> int:
    if level <= 1:
        return 0
    var n := level - 1
    return 80 * n + int(25 * n * (n - 1) / 2)

static func xp_to_next_level(xp: int) -> int:
    var level := level_from_xp(xp)
    if level >= 10:
        return 0
    return maxi(0, xp_threshold_for_level(level + 1) - xp)

static func _apply_progression(profile: Dictionary, stats: Dictionary, won: bool) -> void:
    _ensure_v9(profile)
    var progress: Dictionary = profile.get("player_progress", {})
    var totals: Dictionary = profile.get("season_totals", {})
    var summary: Array = []
    var players: Array = stats.get("players", [])
    var mvp_id := String(stats.get("mvp_id", ""))

    for row_value in players:
        var row: Dictionary = row_value
        var id := String(row.get("id", ""))
        if not PLAYER_IDS.has(id) or not bool(row.get("played", false)):
            continue

        var state: Dictionary = progress.get(id, {"xp": 0, "level": 1, "mvp": 0, "upgrade_points": 0, "upgrades": {}})
        var old_level := level_from_xp(int(state.get("xp", 0)))
        var misses := maxi(0, int(row.get("fga", 0)) - int(row.get("fgm", 0)))
        var xp_gain := 10
        xp_gain += int(row.get("points", 0)) * 2
        xp_gain += int(row.get("assists", 0)) * 3
        xp_gain += int(row.get("rebounds", 0)) * 2
        xp_gain += int(row.get("steals", 0)) * 4
        xp_gain += int(row.get("blocks", 0)) * 4
        xp_gain += int(row.get("fgm", 0)) * 2
        xp_gain -= mini(8, misses)
        if won:
            xp_gain += 8
        if id == mvp_id:
            xp_gain += 12
            state["mvp"] = int(state.get("mvp", 0)) + 1
        xp_gain = maxi(6, xp_gain)

        state["xp"] = int(state.get("xp", 0)) + xp_gain
        state["level"] = level_from_xp(int(state["xp"]))
        var levels_gained := maxi(0, int(state["level"]) - old_level)
        state["upgrade_points"] = int(state.get("upgrade_points", 0)) + levels_gained
        progress[id] = state

        var season: Dictionary = totals.get(id, {})
        season["games"] = int(season.get("games", 0)) + 1
        for key in ["points", "assists", "rebounds", "steals", "blocks", "fgm", "fga", "3pm", "3pa", "ftm", "fta", "fouls", "turnovers"]:
            season[key] = int(season.get(key, 0)) + int(row.get(key, 0))
        totals[id] = season

        summary.append({
            "id": id,
            "name": String(row.get("name", PLAYER_NAMES.get(id, id))),
            "xp_gain": xp_gain,
            "old_level": old_level,
            "new_level": int(state["level"]),
            "total_xp": int(state["xp"]),
            "to_next": xp_to_next_level(int(state["xp"])),
            "mvp": id == mvp_id,
            "upgrade_points_gained": levels_gained,
            "upgrade_points": int(state.get("upgrade_points", 0))
        })

    profile["player_progress"] = progress
    profile["season_totals"] = totals
    profile["last_progression"] = summary
    var adaptive = stats.get("adaptive_profile", {})
    if typeof(adaptive) == TYPE_DICTIONARY and not adaptive.is_empty():
        profile["adaptive_profile"] = adaptive.duplicate(true)
    var sequence = stats.get("sequence_profile", {})
    if typeof(sequence) == TYPE_DICTIONARY and not sequence.is_empty():
        profile["sequence_profile"] = sequence.duplicate(true)
    var semifinal = stats.get("semifinal_profile", {})
    if typeof(semifinal) == TYPE_DICTIONARY and not semifinal.is_empty():
        profile["semifinal_profile"] = semifinal.duplicate(true)
    var final_state = stats.get("final_profile", {})
    if typeof(final_state) == TYPE_DICTIONARY and not final_state.is_empty():
        profile["final_profile"] = final_state.duplicate(true)
    _ensure_v9(profile)
    profile["version"] = 9

static func spend_upgrade_point(profile: Dictionary, player_id: String, stat: String) -> Dictionary:
    _ensure_v9(profile)
    if not PLAYER_IDS.has(player_id):
        return profile
    if not ["speed", "shooting", "passing", "defense", "strength"].has(stat):
        return profile
    var progress: Dictionary = profile.get("player_progress", {})
    var state: Dictionary = progress.get(player_id, {})
    var available := int(state.get("upgrade_points", 0))
    if available <= 0:
        return profile
    var upgrades: Dictionary = state.get("upgrades", {})
    var current := int(upgrades.get(stat, 0))
    if current >= 5:
        return profile
    upgrades[stat] = current + 1
    state["upgrades"] = upgrades
    state["upgrade_points"] = available - 1
    progress[player_id] = state
    profile["player_progress"] = progress
    save_profile(profile)
    return profile

static func _result_dict(match_id: String, match_number: int, home_score: int, away_score: int, won: bool, stats: Dictionary) -> Dictionary:
    return {
        "match_id": match_id,
        "match_number": match_number,
        "home_score": home_score,
        "away_score": away_score,
        "won": won,
        "stats": stats.duplicate(true)
    }

static func _append_history(profile: Dictionary, result: Dictionary) -> void:
    var history: Array = profile.get("match_history", [])
    history.append(result.duplicate(true))
    while history.size() > 20:
        history.pop_front()
    profile["match_history"] = history

static func erase_save() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
