extends SceneTree

const TendencyModel = preload("res://systems/ai/player_tendency_model.gd")
const LaneAnalyzer = preload("res://systems/ai/passing_lane_analyzer.gd")
const NightclawAI = preload("res://systems/ai/nightclaw_utility_ai.gd")
const FairDirector = preload("res://systems/ai/fair_match_director.gd")
const SequenceModel = preload("res://systems/ai/sequence_prediction_model.gd")
const FossilAI = preload("res://systems/ai/fossil_tech_predictive_ai.gd")
const ApexAI = preload("res://systems/ai/apex_coordination_ai.gd")
const Composure = preload("res://systems/ai/composure_tracker.gd")
const Catalog = preload("res://data/match_catalog.gd")
const Saves = preload("res://systems/save_manager.gd")

var failures: Array[String] = []
var checks := 0


func _init() -> void:
    _test_tendency_requires_evidence()
    _test_tendency_round_trip_is_bounded()
    _test_lane_geometry()
    _test_nightclaw_reaction_floor()
    _test_high_risk_lane_is_denied()
    _test_director_never_changes_hidden_outcomes()
    _test_game_seven_and_save_contract()
    _test_sequence_prediction_requires_context_evidence()
    _test_sequence_prediction_can_be_broken()
    _test_sequence_profile_round_trip_is_bounded()
    _test_fossil_reaction_and_counterplay_contract()
    _test_fossil_expected_value_choice()
    _test_game_eight_and_save_contract()
    _test_composure_rewards_variety_not_repetition()
    _test_composure_profile_round_trip_is_bounded()
    _test_apex_plan_and_fairness_contract()
    _test_game_nine_and_save_contract()

    if failures.is_empty():
        print("AI CONTRACTS: %d checks passed" % checks)
        quit(0)
        return
    for failure in failures:
        push_error("AI CONTRACT FAILED: %s" % failure)
    print("AI CONTRACTS: %d failure(s), %d checks" % [failures.size(), checks])
    quit(1)


func _test_tendency_requires_evidence() -> void:
    var model = TendencyModel.new()
    model.observe(&"drive", true)
    model.observe(&"drive", true)
    _expect(
        model.dominant_tendency() == &"",
        "A tendência não pode ser revelada antes da evidência mínima."
    )
    model.observe(&"normal_pass", true)
    _expect(
        model.dominant_tendency() == &"drive",
        "A ação com maior peso deve virar a tendência dominante."
    )


func _test_tendency_round_trip_is_bounded() -> void:
    var model = TendencyModel.new()
    model.from_dictionary({
        "attempts": {"drive": 4.0},
        "successes": {"drive": 99.0},
    })
    _expect(
        is_equal_approx(model.success_rate(&"drive"), 1.0),
        "Dados salvos não podem produzir taxa de sucesso acima de 100%."
    )
    var restored = TendencyModel.new()
    restored.from_dictionary(model.to_dictionary())
    _expect(
        restored.dominant_tendency() == &"drive",
        "O perfil adaptativo deve sobreviver ao round-trip do save."
    )


func _test_lane_geometry() -> void:
    var result := LaneAnalyzer.distance_to_segment(
        Vector3(5.0, 0.0, 1.0),
        Vector3.ZERO,
        Vector3(10.0, 0.0, 0.0)
    )
    _expect(
        is_equal_approx(float(result.get("distance", -1.0)), 1.0),
        "A distância lateral até a linha de passe deve ser geométrica."
    )
    _expect(
        is_equal_approx(float(result.get("projection", -1.0)), 0.5),
        "A projeção deve localizar o defensor no meio do segmento."
    )
    _expect(
        LaneAnalyzer.is_cross_court(Vector3(-4.0, 0.0, 0.0), Vector3(4.0, 0.0, 0.0)),
        "Uma inversão longa entre lados deve ser reconhecida."
    )


func _test_nightclaw_reaction_floor() -> void:
    var ai = NightclawAI.new()
    ai.begin_match(42)
    ai.takeover_active = true
    for difficulty in [
        NightclawAI.Difficulty.ADVENTURE,
        NightclawAI.Difficulty.LEAGUE,
        NightclawAI.Difficulty.METEOR,
    ]:
        ai.difficulty = difficulty
        _expect(
            ai.reaction_time() >= 0.30,
            "A IA nunca pode reagir abaixo do piso humano legível."
        )


func _test_high_risk_lane_is_denied() -> void:
    var ai = NightclawAI.new()
    ai.begin_match(7)
    var decision: Dictionary = ai.choose_defensive_action({
        "pass_lane_risk": 1.0,
        "ball_pressure_value": 0.0,
        "transition_threat": 0.0,
        "help_available": false,
        "foul_risk": 0.0,
    })
    _expect(
        int(decision.get("action", -1)) == NightclawAI.DefensiveAction.DENY_LANE,
        "Uma linha claramente arriscada deve priorizar negação."
    )
    _expect(
        not String(decision.get("counterplay", "")).is_empty(),
        "Toda decisão especial deve expor uma contrajogada."
    )


func _test_director_never_changes_hidden_outcomes() -> void:
    var allowed: Dictionary = FairDirector.new().allowed_adjustments()
    for forbidden in ["shot_probability", "ball_physics", "hidden_attribute_boost"]:
        _expect(
            not bool(allowed.get(forbidden, true)),
            "O diretor não pode habilitar %s." % forbidden
        )
    _expect(
        bool(allowed.get("tutorial_hint", false)),
        "O diretor pode ajudar por meio de informação explícita."
    )


func _test_game_seven_and_save_contract() -> void:
    var match_seven: Dictionary = Catalog.get_match(7)
    _expect(bool(match_seven.get("playable", false)), "O Jogo 7 deve estar jogável.")
    _expect(
        ResourceLoader.exists(String(match_seven.get("pre_chapter", ""))),
        "A HQ pré-jogo do capítulo 7 deve existir."
    )
    _expect(
        ResourceLoader.exists(String(match_seven.get("post_chapter", ""))),
        "A HQ pós-jogo do capítulo 7 deve existir."
    )
    var profile: Dictionary = Saves.default_profile()
    _expect(int(profile.get("version", 0)) == 8, "O save padrão deve usar a versão 8.")
    _expect(
        typeof(profile.get("adaptive_profile")) == TYPE_DICTIONARY,
        "O save deve conter um perfil adaptativo local."
    )


func _test_sequence_prediction_requires_context_evidence() -> void:
    var model = SequenceModel.new()
    model.begin_possession()
    model.observe(&"screen")
    model.observe(&"drive")
    _expect(
        not bool(model.predict_next().get("available", true)),
        "Uma sequência isolada não pode liberar previsão confiante."
    )
    for _i in range(2):
        model.begin_possession()
        model.observe(&"screen")
        model.observe(&"drive")
    model.begin_possession()
    model.observe(&"screen")
    var forecast: Dictionary = model.predict_next()
    _expect(
        bool(forecast.get("available", false)) and StringName(forecast.get("action", &"")) == &"drive",
        "Três sequências iguais devem permitir prever drive após o corta-luz."
    )
    _expect(
        float(forecast.get("confidence", 0.0)) <= 1.0,
        "A confiança da sequência deve permanecer limitada a 100%."
    )


func _test_sequence_prediction_can_be_broken() -> void:
    var model = SequenceModel.new()
    for _i in range(3):
        model.begin_possession()
        model.observe(&"drive")
    model.begin_possession()
    var result: Dictionary = model.observe(&"jump_shot")
    _expect(
        bool(result.get("had_prediction", false)),
        "O modelo deve declarar a previsão antes de avaliar a ação real."
    )
    _expect(
        not bool(result.get("correct", true)),
        "Uma ação inesperada deve quebrar a previsão, não ser reclassificada depois."
    )
    _expect(
        StringName(result.get("predicted", &"")) == &"drive",
        "O erro deve preservar qual ação havia sido prevista."
    )


func _test_sequence_profile_round_trip_is_bounded() -> void:
    var model = SequenceModel.new()
    model.from_dictionary({
        "transitions": {
            "possession_start": {"screen": 999.0},
            "screen": {"drive": 4.0},
        }
    })
    model.begin_possession()
    var start_forecast: Dictionary = model.predict_next()
    _expect(
        float(start_forecast.get("evidence", 0.0)) <= SequenceModel.MAX_TRANSITION_WEIGHT,
        "Dados salvos não podem ultrapassar o peso máximo por transição."
    )
    var restored = SequenceModel.new()
    restored.from_dictionary(model.to_dictionary())
    restored.begin_possession()
    _expect(
        StringName(restored.predict_next().get("action", &"")) == &"screen",
        "O modelo de sequência deve sobreviver ao round-trip do save."
    )


func _test_fossil_reaction_and_counterplay_contract() -> void:
    var ai = FossilAI.new()
    ai.begin_match(808)
    for difficulty in [
        FossilAI.Difficulty.ADVENTURE,
        FossilAI.Difficulty.LEAGUE,
        FossilAI.Difficulty.METEOR,
    ]:
        ai.difficulty = difficulty
        _expect(
            ai.reaction_time() >= FossilAI.REACTION_FLOOR,
            "A Fossil Tech deve respeitar o piso de reação visível."
        )
    var decision: Dictionary = ai.choose_defensive_scheme({
        "available": true,
        "action": &"normal_pass",
        "confidence": 0.80,
    })
    _expect(
        int(decision.get("scheme", -1)) == FossilAI.DefensiveScheme.JUMP_PASS_LANE,
        "Uma previsão de passe deve deslocar a defesa para a linha prevista."
    )
    _expect(
        not String(decision.get("counterplay", "")).is_empty(),
        "Toda rotação preditiva deve informar uma contrajogada."
    )
    ai.model_broken = true
    decision = ai.choose_defensive_scheme({
        "available": true,
        "action": &"drive",
        "confidence": 1.0,
    })
    _expect(
        int(decision.get("scheme", -1)) == FossilAI.DefensiveScheme.BALANCED,
        "O estado Modelo Quebrado deve suspender a antecipação."
    )


func _test_fossil_expected_value_choice() -> void:
    var ai = FossilAI.new()
    ai.begin_match(42)
    var decision: Dictionary = ai.choose_offensive_action({
        "finish_ev": 0.30,
        "shot_ev": 2.10,
        "pass_ev": 0.90,
    })
    _expect(
        StringName(decision.get("action", &"")) == &"shot",
        "A Fossil Tech deve escolher o arremesso quando seu valor é claramente maior."
    )


func _test_game_eight_and_save_contract() -> void:
    var match_eight: Dictionary = Catalog.get_match(8)
    _expect(bool(match_eight.get("playable", false)), "O Jogo 8 deve estar jogável.")
    _expect(
        ResourceLoader.exists(String(match_eight.get("pre_chapter", ""))),
        "A HQ pré-jogo do capítulo 8 deve existir."
    )
    _expect(
        ResourceLoader.exists(String(match_eight.get("post_chapter", ""))),
        "A HQ pós-jogo do capítulo 8 deve existir."
    )
    var profile: Dictionary = Saves.default_profile()
    _expect(int(profile.get("version", 0)) == 8, "O save padrão deve usar a versão 8.")
    _expect(
        typeof(profile.get("sequence_profile")) == TYPE_DICTIONARY,
        "O save deve conter o perfil agregado de sequências."
    )


func _test_composure_rewards_variety_not_repetition() -> void:
    var tracker = Composure.new()
    tracker.start_match()
    var first: Dictionary = tracker.observe(&"drive")
    var repeated: Dictionary = tracker.observe(&"drive")
    _expect(
        bool(repeated.get("repeated", false)),
        "Repetir uma ação recente deve ser identificado pela Compostura."
    )
    _expect(
        float(repeated.get("meter", 0.0)) < float(first.get("meter", 0.0)),
        "Repetição não pode carregar Compostura."
    )
    tracker.begin_possession()
    tracker.observe(&"screen")
    tracker.observe(&"normal_pass")
    var varied: Dictionary = tracker.observe(&"jump_shot")
    _expect(
        int(varied.get("chain", 0)) == 3,
        "Três decisões distintas devem formar uma sequência de Compostura."
    )
    var activation: Dictionary = {}
    for _i in range(7):
        activation = tracker.reward_safe_possession()
    _expect(
        tracker.roars_silenced >= 1 or bool(activation.get("activated", false)),
        "Compostura cheia deve ativar o Silêncio da Vale."
    )


func _test_composure_profile_round_trip_is_bounded() -> void:
    var tracker = Composure.new()
    tracker.from_dictionary({
        "games": 999999,
        "best_composure_chain": 999999,
        "roars_silenced": 999999,
    })
    var saved: Dictionary = tracker.to_dictionary()
    _expect(int(saved.get("games", 0)) == 9999, "Partidas da semifinal devem ser limitadas no save.")
    _expect(
        int(saved.get("best_composure_chain", 0)) == 999,
        "A melhor sequência deve ser limitada no save."
    )
    var restored = Composure.new()
    restored.from_dictionary(saved)
    _expect(
        int(restored.to_dictionary().get("roars_silenced", 0)) == 9999,
        "O perfil da semifinal deve sobreviver ao round-trip."
    )


func _test_apex_plan_and_fairness_contract() -> void:
    var ai = ApexAI.new()
    ai.begin_match(909)
    ai.roar_active = true
    for difficulty in [
        ApexAI.Difficulty.ADVENTURE,
        ApexAI.Difficulty.LEAGUE,
        ApexAI.Difficulty.METEOR,
    ]:
        ai.difficulty = difficulty
        _expect(
            ai.reaction_time() >= ApexAI.REACTION_FLOOR,
            "O Rugido nunca pode quebrar o piso legível de reação."
        )
    ai.roar_active = false
    var switch_plan: Dictionary = ai.choose_defensive_plan({
        "screen_active": true,
        "drive_threat": 0.0,
        "post_threat": 0.0,
        "ball_pressure": 0.0,
        "clock_pressure": 0.0,
        "rebound_priority": 0.0,
        "foul_risk": 0.0,
    })
    _expect(
        int(switch_plan.get("plan", -1)) == ApexAI.DefensivePlan.SWITCH_ALL,
        "Um bloqueio ativo deve chamar a Troca Total."
    )
    var paint_plan: Dictionary = ai.choose_defensive_plan({
        "screen_active": false,
        "drive_threat": 1.0,
        "post_threat": 0.7,
        "ball_pressure": 0.0,
        "clock_pressure": 0.0,
        "rebound_priority": 0.0,
        "foul_risk": 0.0,
    })
    _expect(
        int(paint_plan.get("plan", -1)) == ApexAI.DefensivePlan.PACK_PAINT,
        "Uma ameaça clara ao aro deve chamar a Parede no Garrafão."
    )
    var contract: Dictionary = ai.fairness_contract()
    _expect(bool(contract.get("visible_plan", false)), "Todo plano Apex deve ser visível.")
    for forbidden in ["shot_probability", "ball_physics", "hidden_attribute_boost"]:
        _expect(
            not bool(contract.get(forbidden, true)),
            "A Apex não pode habilitar %s." % forbidden
        )


func _test_game_nine_and_save_contract() -> void:
    var match_nine: Dictionary = Catalog.get_match(9)
    _expect(bool(match_nine.get("playable", false)), "O Jogo 9 deve estar jogável.")
    _expect(
        ResourceLoader.exists(String(match_nine.get("pre_chapter", ""))),
        "A HQ pré-jogo do capítulo 9 deve existir."
    )
    _expect(
        ResourceLoader.exists(String(match_nine.get("post_chapter", ""))),
        "A HQ pós-jogo do capítulo 9 deve existir."
    )
    _expect(Catalog.away_roster(9).size() == 5, "A Apex Dominion deve ter cinco atletas.")
    var profile: Dictionary = Saves.default_profile()
    _expect(int(profile.get("version", 0)) == 8, "A semifinal deve usar o save v8.")
    _expect(
        typeof(profile.get("semifinal_profile")) == TYPE_DICTIONARY,
        "O save deve conter o perfil agregado da semifinal."
    )


func _expect(condition: bool, message: String) -> void:
    checks += 1
    if not condition:
        failures.append(message)
