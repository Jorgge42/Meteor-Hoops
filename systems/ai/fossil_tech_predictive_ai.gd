class_name FossilTechPredictiveAI
extends RefCounted

enum Difficulty { ADVENTURE, LEAGUE, METEOR }
enum DefensiveScheme {
    BALANCED,
    JUMP_PASS_LANE,
    WALL_PAINT,
    EARLY_CLOSEOUT,
    SWITCH_SCREEN,
}

const REACTION_SECONDS := {
    Difficulty.ADVENTURE: 0.72,
    Difficulty.LEAGUE: 0.56,
    Difficulty.METEOR: 0.44,
}
const REACTION_FLOOR := 0.36
const MIN_ACTIONABLE_CONFIDENCE := 0.52

var difficulty: int = Difficulty.LEAGUE
var model_broken := false
var _rng := RandomNumberGenerator.new()


func begin_match(match_seed: int) -> void:
    _rng.seed = match_seed


func reaction_time() -> float:
    var delay := float(
        REACTION_SECONDS.get(difficulty, REACTION_SECONDS[Difficulty.LEAGUE])
    )
    if model_broken:
        delay += 0.24
    return maxf(delay, REACTION_FLOOR)


func choose_defensive_scheme(forecast: Dictionary) -> Dictionary:
    var predicted := StringName(forecast.get("action", &""))
    var confidence := clampf(float(forecast.get("confidence", 0.0)), 0.0, 1.0)
    var usable := (
        bool(forecast.get("available", false))
        and confidence >= MIN_ACTIONABLE_CONFIDENCE
        and not model_broken
    )
    var scheme: int = DefensiveScheme.BALANCED
    if usable:
        if predicted in [&"normal_pass", &"cross_court_pass", &"lob_pass"]:
            scheme = DefensiveScheme.JUMP_PASS_LANE
        elif predicted in [&"drive", &"post_move"]:
            scheme = DefensiveScheme.WALL_PAINT
        elif predicted == &"jump_shot":
            scheme = DefensiveScheme.EARLY_CLOSEOUT
        elif predicted == &"screen":
            scheme = DefensiveScheme.SWITCH_SCREEN

    return {
        "scheme": scheme,
        "prediction": predicted if usable else &"",
        "confidence": confidence if usable else 0.0,
        "reaction_delay": reaction_time(),
        "reason": _reason_for(scheme, predicted),
        "counterplay": counterplay_hint(scheme),
    }


func choose_offensive_action(context: Dictionary) -> Dictionary:
    var scores := {
        &"finish": float(context.get("finish_ev", -1.0)),
        &"shot": float(context.get("shot_ev", -1.0)),
        &"pass": float(context.get("pass_ev", -1.0)),
    }
    var best_action := &"pass"
    var best_score := -INF
    for action in scores.keys():
        var score := float(scores[action]) + _rng.randf_range(-0.018, 0.018)
        if score > best_score:
            best_score = score
            best_action = StringName(action)
    return {
        "action": best_action,
        "expected_value": best_score,
        "scores": scores,
    }


func counterplay_hint(scheme: int) -> String:
    match scheme:
        DefensiveScheme.JUMP_PASS_LANE:
            return "Mostre o passe e ataque o espaço abandonado."
        DefensiveScheme.WALL_PAINT:
            return "Pare fora do garrafão ou encontre o lado fraco."
        DefensiveScheme.EARLY_CLOSEOUT:
            return "Finta o arremesso e infiltre após o closeout."
        DefensiveScheme.SWITCH_SCREEN:
            return "Recuse o bloqueio ou explore o mismatch."
        _:
            return "Varie a sequência para negar confiança ao modelo."


func scheme_name(scheme: int) -> StringName:
    match scheme:
        DefensiveScheme.JUMP_PASS_LANE:
            return &"jump_pass_lane"
        DefensiveScheme.WALL_PAINT:
            return &"wall_paint"
        DefensiveScheme.EARLY_CLOSEOUT:
            return &"early_closeout"
        DefensiveScheme.SWITCH_SCREEN:
            return &"switch_screen"
        _:
            return &"balanced"


func _reason_for(scheme: int, predicted: StringName) -> String:
    if model_broken:
        return "O modelo perdeu confiança e voltou à marcação base."
    match scheme:
        DefensiveScheme.JUMP_PASS_LANE:
            return "A próxima ação calculada é um passe: %s." % String(predicted)
        DefensiveScheme.WALL_PAINT:
            return "A próxima ação calculada ataca o aro."
        DefensiveScheme.EARLY_CLOSEOUT:
            return "A próxima ação calculada é um arremesso."
        DefensiveScheme.SWITCH_SCREEN:
            return "A próxima ação calculada usa um corta-luz."
        _:
            return "Ainda não há evidência suficiente para antecipar a jogada."
