extends SceneTree

const TendencyModel = preload("res://systems/ai/player_tendency_model.gd")
const LaneAnalyzer = preload("res://systems/ai/passing_lane_analyzer.gd")
const NightclawAI = preload("res://systems/ai/nightclaw_utility_ai.gd")
const FairDirector = preload("res://systems/ai/fair_match_director.gd")
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
    _expect(int(profile.get("version", 0)) == 6, "O save padrão deve usar a versão 6.")
    _expect(
        typeof(profile.get("adaptive_profile")) == TYPE_DICTIONARY,
        "O save deve conter um perfil adaptativo local."
    )


func _expect(condition: bool, message: String) -> void:
    checks += 1
    if not condition:
        failures.append(message)
