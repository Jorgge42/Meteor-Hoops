class_name NightclawUtilityAI
extends RefCounted

enum Difficulty { ADVENTURE, LEAGUE, METEOR }
enum DefensiveAction { CONTAIN, DENY_LANE, PRESSURE_BALL, TRAP, RETREAT }

const REACTION_SECONDS := {
    Difficulty.ADVENTURE: 0.62,
    Difficulty.LEAGUE: 0.46,
    Difficulty.METEOR: 0.34,
}

var difficulty: int = Difficulty.LEAGUE
var aggression := 0.55
var takeover_active := false
var player_model := PlayerTendencyModel.new()
var _rng := RandomNumberGenerator.new()


func begin_match(match_seed: int, saved_model: Dictionary = {}) -> void:
    _rng.seed = match_seed
    if not saved_model.is_empty():
        player_model.from_dictionary(saved_model)


func reaction_time() -> float:
    var base := float(REACTION_SECONDS.get(difficulty, REACTION_SECONDS[Difficulty.LEAGUE]))
    if takeover_active:
        base -= 0.06
    return maxf(base, 0.30)


func choose_defensive_action(context: Dictionary) -> Dictionary:
    var scores := {
        DefensiveAction.CONTAIN: 0.55,
        DefensiveAction.DENY_LANE: 0.10,
        DefensiveAction.PRESSURE_BALL: 0.15,
        DefensiveAction.TRAP: -0.10,
        DefensiveAction.RETREAT: 0.05,
    }
    var pass_lane_risk := clampf(float(context.get("pass_lane_risk", 0.0)), 0.0, 1.0)
    var ball_pressure_value := clampf(
        float(context.get("ball_pressure_value", 0.0)),
        0.0,
        1.0
    )
    var transition_threat := clampf(
        float(context.get("transition_threat", 0.0)),
        0.0,
        1.0
    )
    var help_available := bool(context.get("help_available", false))
    var foul_risk := clampf(float(context.get("foul_risk", 0.0)), 0.0, 1.0)

    scores[DefensiveAction.DENY_LANE] += pass_lane_risk * 0.75
    scores[DefensiveAction.PRESSURE_BALL] += ball_pressure_value * aggression
    scores[DefensiveAction.RETREAT] += transition_threat * 0.90
    if help_available:
        scores[DefensiveAction.TRAP] += aggression * 0.45
    scores[DefensiveAction.TRAP] -= foul_risk * 0.80

    var repeated := player_model.repeated_action()
    if repeated == &"cross_court_pass":
        scores[DefensiveAction.DENY_LANE] += 0.40
    elif repeated == &"drive":
        scores[DefensiveAction.CONTAIN] += 0.35
    elif repeated == &"protect_ball":
        scores[DefensiveAction.TRAP] += 0.20

    var dominant := player_model.dominant_tendency()
    if player_model.confidence(dominant) >= 0.55:
        if dominant in [&"cross_court_pass", &"normal_pass"]:
            scores[DefensiveAction.DENY_LANE] += 0.18
        elif dominant in [&"drive", &"post_move"]:
            scores[DefensiveAction.CONTAIN] += 0.16

    if takeover_active:
        scores[DefensiveAction.DENY_LANE] += 0.15
        scores[DefensiveAction.PRESSURE_BALL] += 0.15

    var chosen := _pick_high_score_with_controlled_variation(scores)
    return {
        "action": chosen,
        "reaction_delay": reaction_time(),
        "reason": _reason_for(chosen, repeated),
        "counterplay": counterplay_hint(chosen),
    }


func counterplay_hint(action: int) -> String:
    match action:
        DefensiveAction.DENY_LANE:
            return "Use uma finta ou corte nas costas do defensor."
        DefensiveAction.PRESSURE_BALL:
            return "Proteja a bola e ataque a lateral exposta."
        DefensiveAction.TRAP:
            return "Passe antes da segunda marcação fechar."
        DefensiveAction.RETREAT:
            return "Pare e encontre o arremesso livre."
        _:
            return "Mude o ritmo para deslocar a defesa."


func action_name(action: int) -> StringName:
    match action:
        DefensiveAction.DENY_LANE:
            return &"deny_lane"
        DefensiveAction.PRESSURE_BALL:
            return &"pressure_ball"
        DefensiveAction.TRAP:
            return &"trap"
        DefensiveAction.RETREAT:
            return &"retreat"
        _:
            return &"contain"


func _pick_high_score_with_controlled_variation(scores: Dictionary) -> int:
    var best_action: int = DefensiveAction.CONTAIN
    var best_score := -INF
    for action in scores.keys():
        var variation := _rng.randf_range(-0.035, 0.035)
        var score := float(scores[action]) + variation
        if score > best_score:
            best_score = score
            best_action = int(action)
    return best_action


func _reason_for(action: int, repeated: StringName) -> String:
    if repeated != &"":
        return "A Nightclaw reconheceu a repetição: %s" % String(repeated)
    match action:
        DefensiveAction.DENY_LANE:
            return "A linha de passe oferece valor defensivo."
        DefensiveAction.PRESSURE_BALL:
            return "O portador está vulnerável à pressão."
        DefensiveAction.TRAP:
            return "Há ajuda defensiva e baixo risco de falta."
        DefensiveAction.RETREAT:
            return "A prioridade é impedir a transição."
        _:
            return "A defesa mantém posição entre bola e cesta."
