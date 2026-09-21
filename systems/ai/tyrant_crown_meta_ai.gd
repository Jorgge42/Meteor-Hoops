class_name TyrantCrownMetaAI
extends RefCounted

enum Difficulty { ADVENTURE, LEAGUE, METEOR }
enum Edict { BALANCED, IRON_THRONE, NIGHT_HUNT, WRITTEN_FATE, ROYAL_COMMAND }

const REACTION_SECONDS := {
    Difficulty.ADVENTURE: 0.72,
    Difficulty.LEAGUE: 0.56,
    Difficulty.METEOR: 0.44,
}
const REACTION_FLOOR := 0.32

var difficulty: int = Difficulty.LEAGUE
var crown_shattered := false
var _last_edict: int = Edict.BALANCED
var _rng := RandomNumberGenerator.new()


func begin_match(match_seed: int) -> void:
    _rng.seed = match_seed
    _last_edict = Edict.BALANCED


func reaction_time() -> float:
    var delay := float(
        REACTION_SECONDS.get(difficulty, REACTION_SECONDS[Difficulty.LEAGUE])
    )
    if crown_shattered:
        delay += 0.24
    return maxf(delay, REACTION_FLOOR)


func choose_edict(
    context: Dictionary,
    unavailable_edicts: Array = []
) -> Dictionary:
    if crown_shattered:
        return _decision(Edict.BALANCED, "A Coroa perdeu a formação especial.")

    var drive_threat := _unit(context.get("drive_threat", 0.0))
    var post_threat := _unit(context.get("post_threat", 0.0))
    var paint_frequency := _unit(context.get("paint_frequency", 0.0))
    var pass_tendency := _unit(context.get("pass_tendency", 0.0))
    var lane_risk := _unit(context.get("lane_risk", 0.0))
    var turnover_pressure := _unit(context.get("turnover_pressure", 0.0))
    var prediction_available := bool(context.get("prediction_available", false))
    var prediction_confidence := _unit(context.get("prediction_confidence", 0.0))
    var screen_active := bool(context.get("screen_active", false))
    var clock_pressure := _unit(context.get("clock_pressure", 0.0))
    var rebound_priority := _unit(context.get("rebound_priority", 0.0))
    var scores := {
        Edict.BALANCED: 0.34,
        Edict.IRON_THRONE: (
            0.14
            + drive_threat * 0.58
            + post_threat * 0.72
            + paint_frequency * 0.42
            + rebound_priority * 0.22
        ),
        Edict.NIGHT_HUNT: (
            0.12
            + pass_tendency * 0.68
            + lane_risk * 0.46
            + turnover_pressure * 0.38
        ),
        Edict.WRITTEN_FATE: (
            0.10 + prediction_confidence * 0.96
            if prediction_available
            else -0.12
        ),
        Edict.ROYAL_COMMAND: (
            0.16
            + (0.88 if screen_active else 0.0)
            + clock_pressure * 0.42
            + rebound_priority * 0.34
        ),
    }
    scores[_last_edict] = float(scores.get(_last_edict, 0.0)) - 0.18
    for blocked in unavailable_edicts:
        var blocked_edict := int(blocked)
        if blocked_edict != Edict.BALANCED:
            scores[blocked_edict] = -INF

    var chosen := _pick_edict(scores)
    _last_edict = chosen
    return _decision(chosen, _reason(chosen))


func edict_name(edict: int) -> String:
    match edict:
        Edict.IRON_THRONE:
            return "TRONO DE FERRO"
        Edict.NIGHT_HUNT:
            return "CAÇADA NOTURNA"
        Edict.WRITTEN_FATE:
            return "DESTINO ESCRITO"
        Edict.ROYAL_COMMAND:
            return "COMANDO REAL"
        _:
            return "COROA EQUILIBRADA"


func edict_key(edict: int) -> StringName:
    match edict:
        Edict.IRON_THRONE:
            return &"iron_throne"
        Edict.NIGHT_HUNT:
            return &"night_hunt"
        Edict.WRITTEN_FATE:
            return &"written_fate"
        Edict.ROYAL_COMMAND:
            return &"royal_command"
        _:
            return &"balanced"


func break_hint(edict: int) -> String:
    match edict:
        Edict.IRON_THRONE:
            return "Quebre: converta um arremesso fora do aro."
        Edict.NIGHT_HUNT:
            return "Quebre: use a finta e complete o passe seguinte."
        Edict.WRITTEN_FATE:
            return "Quebre: execute uma ação diferente da previsão."
        Edict.ROYAL_COMMAND:
            return "Quebre: encadeie três ações diferentes e pontue."
        _:
            return "Leia a quadra antes do próximo decreto."


func counterplay_hint(edict: int) -> String:
    match edict:
        Edict.IRON_THRONE:
            return "Abra a quadra para tirar o trono do garrafão."
        Edict.NIGHT_HUNT:
            return "Mostre um passe e entregue a bola por outra janela."
        Edict.WRITTEN_FATE:
            return "Mude a continuação da sequência mostrada no HUD."
        Edict.ROYAL_COMMAND:
            return "Varie o ataque antes que a rotação termine."
        _:
            return "Não entregue informação gratuita à Coroa."


func fairness_contract() -> Dictionary:
    return {
        "visible_edict": true,
        "visible_break_condition": true,
        "reaction_floor": REACTION_FLOOR,
        "shot_probability": false,
        "ball_physics": false,
        "hidden_attribute_boost": false,
        "future_input_read": false,
    }


func _decision(edict: int, reason: String) -> Dictionary:
    return {
        "edict": edict,
        "name": edict_name(edict),
        "reason": reason,
        "counterplay": counterplay_hint(edict),
        "break_hint": break_hint(edict),
        "reaction_delay": reaction_time(),
    }


func _pick_edict(scores: Dictionary) -> int:
    var best_edict: int = Edict.BALANCED
    var best_score := -INF
    for edict in scores.keys():
        var score := float(scores[edict]) + _rng.randf_range(-0.018, 0.018)
        if score > best_score:
            best_score = score
            best_edict = int(edict)
    return best_edict


func _reason(edict: int) -> String:
    match edict:
        Edict.IRON_THRONE:
            return "Drax fecha o aro e transforma força em posição."
        Edict.NIGHT_HUNT:
            return "A Coroa caça a linha de passe mais valiosa."
        Edict.WRITTEN_FATE:
            return "A sequência recente oferece uma previsão confiável."
        Edict.ROYAL_COMMAND:
            return "Os três defensores recebem uma única ordem de rotação."
        _:
            return "A Tyrant Crown observa antes de revelar a próxima arma."


func _unit(value: Variant) -> float:
    return clampf(float(value), 0.0, 1.0)
