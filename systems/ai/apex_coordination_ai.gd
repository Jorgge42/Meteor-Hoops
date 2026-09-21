class_name ApexCoordinationAI
extends RefCounted

enum Difficulty { ADVENTURE, LEAGUE, METEOR }
enum DefensivePlan { BALANCED, PRESS_BALL, SWITCH_ALL, PACK_PAINT, CONTROL_GLASS }
enum OffensivePlan { SPREAD, POWER_SCREEN, POST_HUB, CRASH_GLASS }

const REACTION_SECONDS := {
    Difficulty.ADVENTURE: 0.74,
    Difficulty.LEAGUE: 0.58,
    Difficulty.METEOR: 0.46,
}
const REACTION_FLOOR := 0.34

var difficulty: int = Difficulty.LEAGUE
var roar_active := false
var silenced_active := false
var _rng := RandomNumberGenerator.new()


func begin_match(match_seed: int) -> void:
    _rng.seed = match_seed


func reaction_time() -> float:
    var delay := float(
        REACTION_SECONDS.get(difficulty, REACTION_SECONDS[Difficulty.LEAGUE])
    )
    if roar_active:
        delay -= 0.08
    if silenced_active:
        delay += 0.18
    return maxf(delay, REACTION_FLOOR)


func choose_defensive_plan(context: Dictionary) -> Dictionary:
    var screen_active := bool(context.get("screen_active", false))
    var drive_threat := clampf(float(context.get("drive_threat", 0.0)), 0.0, 1.0)
    var post_threat := clampf(float(context.get("post_threat", 0.0)), 0.0, 1.0)
    var ball_pressure := clampf(float(context.get("ball_pressure", 0.0)), 0.0, 1.0)
    var clock_pressure := clampf(float(context.get("clock_pressure", 0.0)), 0.0, 1.0)
    var rebound_priority := clampf(float(context.get("rebound_priority", 0.0)), 0.0, 1.0)
    var foul_risk := clampf(float(context.get("foul_risk", 0.0)), 0.0, 1.0)

    var scores := {
        DefensivePlan.BALANCED: 0.38,
        DefensivePlan.PRESS_BALL: 0.12 + ball_pressure * 0.48 + clock_pressure * 0.72,
        DefensivePlan.SWITCH_ALL: 1.35 if screen_active else 0.08,
        DefensivePlan.PACK_PAINT: 0.16 + drive_threat * 0.82 + post_threat * 0.68,
        DefensivePlan.CONTROL_GLASS: 0.14 + rebound_priority * 0.88 + clock_pressure * 0.20,
    }
    scores[DefensivePlan.PRESS_BALL] -= foul_risk * 0.34
    scores[DefensivePlan.PACK_PAINT] -= foul_risk * 0.12
    if roar_active:
        scores[DefensivePlan.PRESS_BALL] += 0.16
        scores[DefensivePlan.SWITCH_ALL] += 0.10
        scores[DefensivePlan.CONTROL_GLASS] += 0.12
    if silenced_active:
        for plan in [
            DefensivePlan.PRESS_BALL,
            DefensivePlan.SWITCH_ALL,
            DefensivePlan.PACK_PAINT,
            DefensivePlan.CONTROL_GLASS,
        ]:
            scores[plan] = float(scores[plan]) - 0.18

    var chosen := _pick_plan(scores, DefensivePlan.BALANCED)
    return {
        "plan": chosen,
        "reaction_delay": reaction_time(),
        "reason": _defensive_reason(chosen),
        "counterplay": defensive_counterplay(chosen),
        "scores": scores,
    }


func choose_offensive_plan(context: Dictionary) -> Dictionary:
    var screen_ready := bool(context.get("screen_ready", false))
    var strength_edge := clampf(float(context.get("strength_edge", 0.0)), 0.0, 1.0)
    var rebound_edge := clampf(float(context.get("rebound_edge", 0.0)), 0.0, 1.0)
    var paint_crowding := clampf(float(context.get("paint_crowding", 0.0)), 0.0, 1.0)
    var scores := {
        OffensivePlan.SPREAD: 0.30 + paint_crowding * 0.78,
        OffensivePlan.POWER_SCREEN: 0.22 + (0.86 if screen_ready else 0.0),
        OffensivePlan.POST_HUB: 0.20 + strength_edge * 0.92,
        OffensivePlan.CRASH_GLASS: 0.24 + rebound_edge * 0.86,
    }
    if roar_active:
        scores[OffensivePlan.POWER_SCREEN] += 0.12
        scores[OffensivePlan.POST_HUB] += 0.12
        scores[OffensivePlan.CRASH_GLASS] += 0.14
    if silenced_active:
        scores[OffensivePlan.SPREAD] += 0.16

    var chosen := _pick_plan(scores, OffensivePlan.SPREAD)
    return {
        "plan": chosen,
        "reaction_delay": reaction_time(),
        "reason": _offensive_reason(chosen),
        "counterplay": offensive_counterplay(chosen),
        "scores": scores,
    }


func defensive_counterplay(plan: int) -> String:
    match plan:
        DefensivePlan.PRESS_BALL:
            return "Proteja a bola e use o passe de segurança."
        DefensivePlan.SWITCH_ALL:
            return "Recuse o bloqueio ou ataque o mismatch."
        DefensivePlan.PACK_PAINT:
            return "Abra a quadra e aceite o arremesso livre."
        DefensivePlan.CONTROL_GLASS:
            return "Volte para defender em vez de disputar todo rebote."
        _:
            return "Encadeie ações diferentes para construir Compostura."


func offensive_counterplay(plan: int) -> String:
    match plan:
        OffensivePlan.POWER_SCREEN:
            return "Antecipe a troca e impeça o roll."
        OffensivePlan.POST_HUB:
            return "Negue a posição antes do contato."
        OffensivePlan.CRASH_GLASS:
            return "Use box-out e feche a segunda chance."
        _:
            return "Mantenha ajuda curta e recupere no passe."


func defensive_plan_name(plan: int) -> String:
    match plan:
        DefensivePlan.PRESS_BALL:
            return "PRESSÃO NA BOLA"
        DefensivePlan.SWITCH_ALL:
            return "TROCA TOTAL"
        DefensivePlan.PACK_PAINT:
            return "PAREDE NO GARRAFÃO"
        DefensivePlan.CONTROL_GLASS:
            return "CONTROLE DO REBOTE"
        _:
            return "BASE EQUILIBRADA"


func offensive_plan_name(plan: int) -> String:
    match plan:
        OffensivePlan.POWER_SCREEN:
            return "BLOQUEIO DE POTÊNCIA"
        OffensivePlan.POST_HUB:
            return "EIXO NO POSTE"
        OffensivePlan.CRASH_GLASS:
            return "ATAQUE AO REBOTE"
        _:
            return "QUADRA ABERTA"


func fairness_contract() -> Dictionary:
    return {
        "visible_plan": true,
        "reaction_floor": REACTION_FLOOR,
        "shot_probability": false,
        "ball_physics": false,
        "hidden_attribute_boost": false,
        "normal_sprint_only": true,
    }


func _pick_plan(scores: Dictionary, fallback: int) -> int:
    var best_plan := fallback
    var best_score := -INF
    for plan in scores.keys():
        var score := float(scores[plan]) + _rng.randf_range(-0.015, 0.015)
        if score > best_score:
            best_score = score
            best_plan = int(plan)
    return best_plan


func _defensive_reason(plan: int) -> String:
    match plan:
        DefensivePlan.PRESS_BALL:
            return "A Apex encurta o relógio com pressão coordenada."
        DefensivePlan.SWITCH_ALL:
            return "Todos trocam responsabilidades no corta-luz."
        DefensivePlan.PACK_PAINT:
            return "O trio fecha o aro contra força e infiltração."
        DefensivePlan.CONTROL_GLASS:
            return "A prioridade coletiva é terminar a posse no rebote."
        _:
            return "A Apex mantém posição antes de revelar o plano."


func _offensive_reason(plan: int) -> String:
    match plan:
        OffensivePlan.POWER_SCREEN:
            return "Um bloqueio forte cria duas rotas para o aro."
        OffensivePlan.POST_HUB:
            return "A vantagem física organiza a posse pelo poste."
        OffensivePlan.CRASH_GLASS:
            return "Dois atletas preparam a segunda chance."
        _:
            return "A Apex abre espaço e lê a ajuda defensiva."
