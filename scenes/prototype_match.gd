class_name PrototypeMatch
extends Node3D

signal exit_requested
signal match_finished(home_won: bool, home_score: int, away_score: int)
signal tutorial_completed

const TEAM_HOME := 0
const TEAM_AWAY := 1
const HOME_COLOR := Color("38c7b4")

enum MatchState { LIVE, HALFTIME, FREE_THROW, FINISHED }

var training_mode := false
var match_config: Dictionary = {}
var match_number := 1
var match_id := "match_01"
var away_team_name := "QUARTZ ACADEMY"
var away_team_color := Color("8b5cf6")
var tutorial_enabled := true
var home_lineup_ids: Array = ["kiro", "luma", "bato"]
var player_progression: Dictionary = {}
var adaptive_profile: Dictionary = {}
var sequence_profile: Dictionary = {}
var semifinal_profile: Dictionary = {}
var final_profile: Dictionary = {}
var difficulty_name := "ADVENTURE"
var shot_feedback_enabled := true
var reduced_fx := false
var high_contrast := false
var match_stats: Dictionary = {}
var match_state := MatchState.LIVE
var dead_ball := false
var ball: MeteorBall
var home_players: Array = []
var away_players: Array = []
var all_players: Array = []
var home_bench: Array = []
var away_bench: Array = []
var controlled_player: DinoPlayer
var controlled_home_index := 0

var north_detector: BasketDetector
var south_detector: BasketDetector
var north_hoop_target := Vector3(0.0, GameTuning.HOOP_HEIGHT, -12.55)
var south_hoop_target := Vector3(0.0, GameTuning.HOOP_HEIGHT, 12.55)

var home_score := 0
var away_score := 0
var possession_team := TEAM_HOME
var period := 1
var overtime_count := 0
var period_time_left := GameTuning.STORY_PERIOD_SECONDS
var shot_clock_left := GameTuning.SHOT_CLOCK
var basket_locked := false
var last_shot_team := -1
var ai_action_cooldowns: Dictionary = {}
var rng := RandomNumberGenerator.new()
var instinct_meter := {TEAM_HOME: 0.0, TEAM_AWAY: 0.0}
var instinct_time_left := {TEAM_HOME: 0.0, TEAM_AWAY: 0.0}
var last_passer_by_team := {TEAM_HOME: null, TEAM_AWAY: null}
var last_shooter: DinoPlayer
var last_shot_value := 2
var last_shot_type := "JUMPER"
var play_calls := ["LIVRE", "GIVE & GO", "BACKDOOR", "ABRIR QUADRA"]
var play_call_index := 0
var home_cut_player: DinoPlayer
var home_cut_time_left := 0.0
var feedback_color_time_left := 0.0
var sfx_player: AudioStreamPlayer

# Nightclaw / adaptive match intelligence
var tendency_model := PlayerTendencyModel.new()
var nightclaw_ai := NightclawUtilityAI.new()
var match_director := FairMatchDirector.new()
var nightclaw_actions: Dictionary = {}
var nightclaw_decision_cooldowns: Dictionary = {}
var nightclaw_takeover_meter := 0.0
var nightclaw_takeover_left := 0.0
var adaptation_announce_cooldown := 0.0
var last_announced_adaptation := &""
var pass_fake_player: DinoPlayer
var pass_fake_time_left := 0.0
var pass_fake_safety_available := false
var fake_defender_targets: Dictionary = {}
var last_passer: DinoPlayer
var last_pass_origin := Vector3.ZERO
var last_pass_lane_risk := 0.0
var transition_team := -1
var transition_time_left := 0.0
var turnovers := {TEAM_HOME: 0, TEAM_AWAY: 0}
var points_off_turnovers := {TEAM_HOME: 0, TEAM_AWAY: 0}
var possession_count := 0
var turnover_happened_this_possession := false

# Fossil Tech / transparent sequence prediction
var sequence_model := SequencePredictionModel.new()
var fossil_ai := FossilTechPredictiveAI.new()
var fossil_actions: Dictionary = {}
var fossil_decision_cooldowns: Dictionary = {}
var fossil_disruption_meter := 0.0
var fossil_model_broken_left := 0.0
var fossil_predictions_seen := 0
var fossil_predictions_correct := 0
var fossil_predictions_evaded := 0
var fossil_announce_cooldown := 0.0
var fossil_last_announced_prediction := &""
var home_protection_observed_this_possession := false

# Apex Dominion / coordinated semifinal pressure
var apex_ai := ApexCoordinationAI.new()
var composure_tracker := ComposureTracker.new()
var apex_defensive_plan: int = ApexCoordinationAI.DefensivePlan.BALANCED
var apex_offensive_plan: int = ApexCoordinationAI.OffensivePlan.SPREAD
var apex_plan_cooldown := 0.0
var apex_roar_meter := 0.0
var apex_roar_left := 0.0
var apex_silence_left := 0.0
var apex_plan_announce_cooldown := 0.0
var apex_last_announced_plan := ""

# Tyrant Crown / final meta-strategy
var crown_ai := TyrantCrownMetaAI.new()
var crown_legacy := CrownLegacyTracker.new()
var crown_edict: int = TyrantCrownMetaAI.Edict.BALANCED
var crown_edict_left := 0.0
var crown_select_cooldown := 0.0
var crown_shattered_left := 0.0
var crown_announce_cooldown := 0.0
var crown_last_announced_edict := ""
var crown_predictions_seen := 0
var crown_predictions_correct := 0
var crown_predictions_evaded := 0

# Physical basketball / screen state
var team_fouls := {TEAM_HOME: 0, TEAM_AWAY: 0}
var screen_ballhandler: DinoPlayer
var screen_screener: DinoPlayer
var screen_defender: DinoPlayer
var screen_setup_left := 0.0
var screen_roll_left := 0.0
var screen_call_cooldown := 0.0
var screen_contact_done := false
var screen_target := Vector3.ZERO

# Free throw state
var free_throw_layer: CanvasLayer
var free_throw_label: Label
var free_throw_detail_label: Label
var free_throw_shooter: DinoPlayer
var free_throw_attempts_left := 0
var free_throw_attempts_total := 0
var free_throw_made := 0
var free_throw_hold_started_at := -1
var free_throw_ai_timer := 0.0
var free_throw_between_timer := 0.0
var free_throw_waiting_result := false

var score_label: Label
var timer_label: Label
var period_label: Label
var shot_clock_label: Label
var possession_label: Label
var fouls_label: Label
var play_label: Label
var player_label: Label
var stamina_bar: ProgressBar
var instinct_bar: ProgressBar
var instinct_label: Label
var feedback_label: Label
var tutorial_label: Label
var nightclaw_label: Label
var fossil_label: Label
var apex_label: Label
var crown_label: Label
var halftime_layer: CanvasLayer
var halftime_status_label: Label
var camera: Camera3D
var tutorial_flags := {"move": false, "pass": false, "shot": false, "switch": false}
var tutorial_done_emitted := false

func _ready() -> void:
    rng.seed = 20260920
    _apply_match_config()
    _setup_adaptive_ai()
    _build_world()
    _build_hud()
    _build_audio()
    _spawn_gameplay()
    _refresh_match_hud()
    _refresh_tutorial()

func _process(delta: float) -> void:
    for team in [TEAM_HOME, TEAM_AWAY]:
        instinct_time_left[team] = maxf(0.0, float(instinct_time_left[team]) - delta)

    home_cut_time_left = maxf(0.0, home_cut_time_left - delta)
    if home_cut_time_left <= 0.0:
        home_cut_player = null
    screen_call_cooldown = maxf(0.0, screen_call_cooldown - delta)
    nightclaw_takeover_left = maxf(0.0, nightclaw_takeover_left - delta)
    nightclaw_ai.takeover_active = nightclaw_takeover_left > 0.0
    fossil_model_broken_left = maxf(0.0, fossil_model_broken_left - delta)
    fossil_ai.model_broken = fossil_model_broken_left > 0.0
    apex_roar_left = maxf(0.0, apex_roar_left - delta)
    apex_silence_left = maxf(0.0, apex_silence_left - delta)
    apex_plan_cooldown = maxf(0.0, apex_plan_cooldown - delta)
    apex_plan_announce_cooldown = maxf(0.0, apex_plan_announce_cooldown - delta)
    apex_ai.roar_active = apex_roar_left > 0.0
    apex_ai.silenced_active = apex_silence_left > 0.0
    var crown_was_shattered := crown_shattered_left > 0.0
    crown_shattered_left = maxf(0.0, crown_shattered_left - delta)
    crown_select_cooldown = maxf(0.0, crown_select_cooldown - delta)
    crown_announce_cooldown = maxf(0.0, crown_announce_cooldown - delta)
    if crown_shattered_left <= 0.0:
        crown_edict_left = maxf(0.0, crown_edict_left - delta)
    crown_ai.crown_shattered = crown_shattered_left > 0.0
    if crown_was_shattered and crown_shattered_left <= 0.0:
        crown_edict = TyrantCrownMetaAI.Edict.BALANCED
        crown_select_cooldown = crown_ai.reaction_time()
    transition_time_left = maxf(0.0, transition_time_left - delta)
    adaptation_announce_cooldown = maxf(0.0, adaptation_announce_cooldown - delta)
    fossil_announce_cooldown = maxf(0.0, fossil_announce_cooldown - delta)
    pass_fake_time_left = maxf(0.0, pass_fake_time_left - delta)
    if pass_fake_time_left <= 0.0:
        pass_fake_player = null
        pass_fake_safety_available = false
        fake_defender_targets.clear()
    if transition_time_left <= 0.0:
        transition_team = -1

    feedback_color_time_left = maxf(0.0, feedback_color_time_left - delta)
    if feedback_color_time_left <= 0.0 and is_instance_valid(feedback_label):
        feedback_label.modulate = Color.WHITE

    for player in all_players:
        if is_instance_valid(player):
            player.set_instinct_visual(_is_player_energy_active(player) and not reduced_fx)

    if match_state == MatchState.FREE_THROW:
        _process_free_throw(delta)
        if Input.is_action_just_pressed("pause_menu"):
            exit_requested.emit()
        _refresh_match_hud()
        return

    if match_state == MatchState.LIVE and not dead_ball:
        if training_mode:
            timer_label.text = "TREINO LIVRE"
            shot_clock_label.text = "POSSE ∞"
        else:
            period_time_left = maxf(0.0, period_time_left - delta)
            if ball == null or ball.state != MeteorBall.BallState.SHOT:
                shot_clock_left = maxf(0.0, shot_clock_left - delta)
            if period_time_left <= 0.0:
                _handle_period_end()
                return
            if shot_clock_left <= 0.0:
                _shot_clock_violation()
                return

    if tutorial_enabled and match_state == MatchState.LIVE:
        var move_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
        if move_input.length() > 0.15 and not bool(tutorial_flags["move"]):
            tutorial_flags["move"] = true
            _refresh_tutorial()

    if is_instance_valid(controlled_player):
        stamina_bar.value = controlled_player.stamina
        instinct_bar.value = float(instinct_meter[TEAM_HOME])
        instinct_label.text = "INSTINTO METEORO%s" % (" • ATIVO %.1fs" % float(instinct_time_left[TEAM_HOME]) if is_instinct_active(TEAM_HOME) else "")
        var ball_tag := " • COM A BOLA" if controlled_player.has_ball else ""
        player_label.text = "%s  |  %s%s" % [controlled_player.data.display_name, controlled_player.data.role, ball_tag]

    if match_state == MatchState.LIVE and not dead_ball:
        if Input.is_action_just_pressed("switch_player"):
            _cycle_controlled_player()
        if Input.is_action_just_pressed("call_play"):
            _cycle_play_call()
        if training_mode and Input.is_action_just_pressed("reset_ball"):
            _start_possession(TEAM_HOME)

    if Input.is_action_just_pressed("pause_menu"):
        exit_requested.emit()

    if match_state == MatchState.LIVE and not dead_ball:
        _update_screen_action(delta)
        _update_ball_state_and_capture()
        _update_ai(delta)

    _refresh_match_hud()

func _build_world() -> void:
    var env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color("111724")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("b9c8dc")
    environment.ambient_light_energy = 0.68
    env.environment = environment
    add_child(env)

    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-55, -25, 0)
    light.light_energy = 1.4
    light.shadow_enabled = true
    add_child(light)

    _add_box(Vector3(0, -0.1, 0), Vector3(GameTuning.COURT_WIDTH, 0.2, GameTuning.COURT_LENGTH), Color("323a48"), true)
    _add_box(Vector3(0, 0.015, 0), Vector3(GameTuning.COURT_WIDTH, 0.02, 0.06), Color("d9e0e8"), false)
    _add_box(Vector3(-GameTuning.COURT_WIDTH / 2.0, 0.03, 0), Vector3(0.06, 0.04, GameTuning.COURT_LENGTH), Color("d9e0e8"), false)
    _add_box(Vector3(GameTuning.COURT_WIDTH / 2.0, 0.03, 0), Vector3(0.06, 0.04, GameTuning.COURT_LENGTH), Color("d9e0e8"), false)

    var home_line_color := Color("65fff0") if high_contrast else HOME_COLOR.darkened(0.35)
    var away_line_color := Color("ffcf4a") if high_contrast else away_team_color.darkened(0.35)
    _add_box(Vector3(0, 0.028, -6.2), Vector3(5.0, 0.025, 0.05), home_line_color, false)
    _add_box(Vector3(0, 0.028, 6.2), Vector3(5.0, 0.025, 0.05), away_line_color, false)
    _build_three_point_lines()

    north_detector = _build_hoop(Vector3(0.0, 0.0, -12.55), &"north")
    south_detector = _build_hoop(Vector3(0.0, 0.0, 12.55), &"south")

    camera = Camera3D.new()
    camera.position = Vector3(0.0, 20.0, 22.0)
    camera.fov = 52.0
    add_child(camera)
    camera.current = true
    camera.look_at(Vector3(0, 0.8, 0), Vector3.UP)

func _spawn_gameplay() -> void:
    ball = MeteorBall.new()
    ball.position = Vector3(0.0, 1.0, 6.0)
    add_child(ball)

    var home_roster_dicts := MatchCatalog.home_roster(player_progression)
    var home_by_id: Dictionary = {}
    for entry in home_roster_dicts:
        var pdata := _dict_to_player_data(entry)
        home_by_id[String(pdata.id)] = pdata
        _ensure_stat_row(pdata)
    if home_by_id.size() < 5:
        push_error("Meteor Hoops: elenco da Vale Fóssil incompleto")
        return

    var active_data: Array = []
    for selected_id in home_lineup_ids:
        if home_by_id.has(String(selected_id)) and active_data.size() < 3:
            active_data.append(home_by_id[String(selected_id)])
    for fallback in ["kiro", "luma", "bato", "nilo", "mako"]:
        if active_data.size() >= 3:
            break
        if home_by_id.has(fallback) and not active_data.has(home_by_id[fallback]):
            active_data.append(home_by_id[fallback])
    home_bench = []
    for entry in home_roster_dicts:
        var roster_id := String(entry.get("id", ""))
        if home_by_id.has(roster_id) and not active_data.has(home_by_id[roster_id]):
            home_bench.append(home_by_id[roster_id])

    home_players.append(_spawn_player(active_data[0], Vector3(0, 0, 7.0), TEAM_HOME, 0, HOME_COLOR))
    home_players.append(_spawn_player(active_data[1], Vector3(-4.0, 0, 4.8), TEAM_HOME, 1, HOME_COLOR))
    home_players.append(_spawn_player(active_data[2], Vector3(4.0, 0, 3.8), TEAM_HOME, 2, HOME_COLOR))

    var away_roster_dicts := MatchCatalog.away_roster(match_number)
    var away_roster: Array = []
    for entry in away_roster_dicts:
        away_roster.append(_dict_to_player_data(entry))
    if away_roster.size() < 5:
        push_error("Meteor Hoops: elenco adversário incompleto para o jogo %d" % match_number)
        return

    away_bench = [away_roster[3], away_roster[4]]
    away_players.append(_spawn_player(away_roster[0], Vector3(0, 0, -3.2), TEAM_AWAY, 0, away_team_color))
    away_players.append(_spawn_player(away_roster[1], Vector3(4.0, 0, -5.0), TEAM_AWAY, 1, away_team_color))
    away_players.append(_spawn_player(away_roster[2], Vector3(-4.0, 0, -4.2), TEAM_AWAY, 2, away_team_color))

    all_players = home_players + away_players
    _select_controlled(home_players[0])

    await get_tree().process_frame
    _start_possession(TEAM_HOME)

func _apply_match_config() -> void:
    if match_config.is_empty():
        match_config = MatchCatalog.get_match(1)
    match_number = int(match_config.get("number", 1))
    match_id = String(match_config.get("id", "match_01"))
    away_team_name = String(match_config.get("school", "QUARTZ ACADEMY"))
    away_team_color = Color(String(match_config.get("color", "8b5cf6")))


func _setup_adaptive_ai() -> void:
    if difficulty_name == "METEOR":
        nightclaw_ai.difficulty = NightclawUtilityAI.Difficulty.METEOR
    elif difficulty_name == "LEAGUE":
        nightclaw_ai.difficulty = NightclawUtilityAI.Difficulty.LEAGUE
    else:
        nightclaw_ai.difficulty = NightclawUtilityAI.Difficulty.ADVENTURE
    var match_seed := int(Time.get_unix_time_from_system()) + match_number * 9973
    nightclaw_ai.begin_match(match_seed, adaptive_profile)
    if not adaptive_profile.is_empty():
        tendency_model.from_dictionary(adaptive_profile)
    nightclaw_ai.player_model = tendency_model
    if difficulty_name == "METEOR":
        fossil_ai.difficulty = FossilTechPredictiveAI.Difficulty.METEOR
    elif difficulty_name == "LEAGUE":
        fossil_ai.difficulty = FossilTechPredictiveAI.Difficulty.LEAGUE
    else:
        fossil_ai.difficulty = FossilTechPredictiveAI.Difficulty.ADVENTURE
    fossil_ai.begin_match(match_seed + 808)
    if not sequence_profile.is_empty():
        sequence_model.from_dictionary(sequence_profile)
    if difficulty_name == "METEOR":
        apex_ai.difficulty = ApexCoordinationAI.Difficulty.METEOR
    elif difficulty_name == "LEAGUE":
        apex_ai.difficulty = ApexCoordinationAI.Difficulty.LEAGUE
    else:
        apex_ai.difficulty = ApexCoordinationAI.Difficulty.ADVENTURE
    apex_ai.begin_match(match_seed + 909)
    if match_number == 9:
        composure_tracker.start_match(semifinal_profile)
    else:
        composure_tracker.from_dictionary(semifinal_profile)
    if difficulty_name == "METEOR":
        crown_ai.difficulty = TyrantCrownMetaAI.Difficulty.METEOR
    elif difficulty_name == "LEAGUE":
        crown_ai.difficulty = TyrantCrownMetaAI.Difficulty.LEAGUE
    else:
        crown_ai.difficulty = TyrantCrownMetaAI.Difficulty.ADVENTURE
    crown_ai.begin_match(match_seed + 1010)
    if match_number == 10:
        crown_legacy.start_match(final_profile)
    else:
        crown_legacy.from_dictionary(final_profile)
    if not match_director.intervention_requested.is_connected(_on_director_intervention):
        match_director.intervention_requested.connect(_on_director_intervention)


func _on_director_intervention(intervention: Dictionary) -> void:
    if match_number != 7:
        return
    var intervention_type := String(intervention.get("type", ""))
    if intervention_type == "hint":
        _set_event_feedback(
            String(intervention.get("message", "MUDE O PADRÃO DA POSSE")),
            Color(0.58, 0.78, 1.0),
            2.4
        )
    elif intervention_type == "strategy_shift":
        var weight_delta := float(intervention.get("weight_delta", 0.0))
        if String(intervention.get("strategy", "")) == "protect_paint":
            nightclaw_ai.aggression -= weight_delta
        else:
            nightclaw_ai.aggression += weight_delta
        nightclaw_ai.aggression = clampf(nightclaw_ai.aggression, 0.35, 0.78)
        _set_event_feedback(
            "NIGHTCLAW AJUSTA A MARCAÇÃO • procure o lado fraco",
            Color(0.68, 0.58, 1.0),
            1.8
        )


func _is_player_energy_active(player: DinoPlayer) -> bool:
    if is_instinct_active(player.team_id):
        return true
    if match_number == 7 and player.team_id == TEAM_AWAY:
        return nightclaw_takeover_left > 0.0
    if match_number == 9:
        if player.team_id == TEAM_AWAY:
            return apex_roar_left > 0.0
        return apex_silence_left > 0.0
    if match_number == 10:
        if player.team_id == TEAM_AWAY:
            return crown_edict != TyrantCrownMetaAI.Edict.BALANCED
        return crown_shattered_left > 0.0
    return false

func _dict_to_player_data(entry: Dictionary) -> PlayerData:
    return _make_player_data(
        StringName(String(entry.get("id", "away"))),
        String(entry.get("display_name", "Rival")),
        String(entry.get("species", "Dinosaur")),
        String(entry.get("role", "Ala")),
        int(entry.get("speed", 70)),
        int(entry.get("shooting", 70)),
        int(entry.get("passing", 70)),
        int(entry.get("defense", 70)),
        int(entry.get("strength", 70)),
        float(entry.get("height", 1.85)),
        String(entry.get("instinct", "Instinto")),
        String(entry.get("bio", ""))
    )

func _spawn_player(data: PlayerData, pos: Vector3, team: int, index: int, color: Color) -> DinoPlayer:
    var player := DinoPlayer.new()
    player.position = pos
    add_child(player)
    player.setup(data, ball, self, team, index, color)
    if team == TEAM_HOME:
        _mark_played(data)
    return player

func _make_player_data(id_value: StringName, display_name: String, species: String, role: String, speed: int, shooting: int, passing: int, defense: int, strength: int, height: float, instinct: String, bio: String = "") -> PlayerData:
    var result := PlayerData.new()
    result.id = id_value
    result.display_name = display_name
    result.species = species
    result.role = role
    result.speed = speed
    result.shooting = shooting
    result.passing = passing
    result.defense = defense
    result.strength = strength
    result.gameplay_height = height
    result.instinct_name = instinct
    result.bio = bio
    return result

func _build_hoop(base: Vector3, basket_id: StringName) -> BasketDetector:
    var board_z := -0.62 if basket_id == &"north" else 0.62
    _add_box(base + Vector3(0, 3.5, board_z), Vector3(1.8, 1.05, 0.08), Color("eef3f7"), true)

    for i in range(16):
        var angle := TAU * float(i) / 16.0
        var p := base + Vector3(cos(angle) * GameTuning.RIM_RADIUS, GameTuning.HOOP_HEIGHT, sin(angle) * GameTuning.RIM_RADIUS)
        _add_sphere(p, 0.035, Color("f97316"), true)

    var detector := BasketDetector.new()
    detector.position = base
    detector.setup(basket_id)
    detector.basket_scored.connect(_on_basket_scored)
    add_child(detector)
    return detector

func _build_hud() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)

    var panel := PanelContainer.new()
    panel.position = Vector2(22, 18)
    panel.size = Vector2(430, 335)
    layer.add_child(panel)

    var vbox := VBoxContainer.new()
    panel.add_child(vbox)

    score_label = Label.new()
    score_label.text = "VALE FÓSSIL  0  —  0  %s" % away_team_name
    score_label.add_theme_font_size_override("font_size", 26)
    vbox.add_child(score_label)

    var clock_row := HBoxContainer.new()
    vbox.add_child(clock_row)

    period_label = Label.new()
    period_label.custom_minimum_size = Vector2(110, 28)
    clock_row.add_child(period_label)

    timer_label = Label.new()
    timer_label.custom_minimum_size = Vector2(110, 28)
    timer_label.add_theme_font_size_override("font_size", 20)
    clock_row.add_child(timer_label)

    shot_clock_label = Label.new()
    shot_clock_label.custom_minimum_size = Vector2(130, 28)
    shot_clock_label.add_theme_font_size_override("font_size", 20)
    clock_row.add_child(shot_clock_label)

    possession_label = Label.new()
    possession_label.text = "POSSE: VALE FÓSSIL"
    possession_label.modulate = Color(0.82, 0.88, 0.95)
    vbox.add_child(possession_label)

    fouls_label = Label.new()
    fouls_label.text = "FALTAS: 0 — 0"
    fouls_label.modulate = Color(0.95, 0.72, 0.30)
    vbox.add_child(fouls_label)

    play_label = Label.new()
    play_label.text = "JOGADA: LIVRE"
    play_label.modulate = Color(0.45, 0.9, 1.0)
    vbox.add_child(play_label)

    player_label = Label.new()
    player_label.text = "Kiro | Armador"
    vbox.add_child(player_label)

    stamina_bar = ProgressBar.new()
    stamina_bar.max_value = GameTuning.STAMINA_MAX
    stamina_bar.value = GameTuning.STAMINA_MAX
    stamina_bar.show_percentage = false
    stamina_bar.custom_minimum_size = Vector2(395, 16)
    vbox.add_child(stamina_bar)

    instinct_label = Label.new()
    instinct_label.text = "INSTINTO METEORO"
    instinct_label.modulate = Color(0.95, 0.72, 0.22)
    vbox.add_child(instinct_label)

    instinct_bar = ProgressBar.new()
    instinct_bar.max_value = GameTuning.INSTINCT_MAX
    instinct_bar.value = 0.0
    instinct_bar.show_percentage = false
    instinct_bar.custom_minimum_size = Vector2(395, 13)
    vbox.add_child(instinct_bar)

    var help := Label.new()
    help.text = "WASD mover • SHIFT sprint • ESPAÇO passe/roubo • V finta • L lob • J arremesso\nK finalizar/toco/rebote • E proteger/box-out • G bloqueio • H post • F Instinto • Q/TAB troca"
    help.position = Vector2(22, 338)
    help.modulate = Color(0.86, 0.9, 0.95)
    layer.add_child(help)

    feedback_label = Label.new()
    feedback_label.position = Vector2(470, 34)
    feedback_label.size = Vector2(520, 100)
    feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    feedback_label.add_theme_font_size_override("font_size", 25)
    layer.add_child(feedback_label)

    tutorial_label = Label.new()
    tutorial_label.position = Vector2(985, 24)
    tutorial_label.size = Vector2(270, 190)
    tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    tutorial_label.add_theme_font_size_override("font_size", 17)
    layer.add_child(tutorial_label)

    nightclaw_label = Label.new()
    nightclaw_label.position = Vector2(935, 225)
    nightclaw_label.size = Vector2(320, 110)
    nightclaw_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    nightclaw_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    nightclaw_label.modulate = Color(0.58, 0.52, 1.0)
    nightclaw_label.visible = match_number == 7
    layer.add_child(nightclaw_label)

    fossil_label = Label.new()
    fossil_label.position = Vector2(875, 215)
    fossil_label.size = Vector2(380, 145)
    fossil_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    fossil_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    fossil_label.modulate = Color(0.25, 0.92, 0.78)
    fossil_label.visible = match_number == 8
    layer.add_child(fossil_label)

    apex_label = Label.new()
    apex_label.position = Vector2(855, 205)
    apex_label.size = Vector2(400, 170)
    apex_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    apex_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    apex_label.modulate = Color(1.0, 0.78, 0.24)
    apex_label.visible = match_number == 9
    layer.add_child(apex_label)

    crown_label = Label.new()
    crown_label.position = Vector2(835, 195)
    crown_label.size = Vector2(420, 185)
    crown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    crown_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    crown_label.modulate = Color(1.0, 0.32, 0.28)
    crown_label.visible = match_number == 10
    layer.add_child(crown_label)

func request_pass(passer: DinoPlayer, input_dir: Vector2) -> void:
    if passer == null or not passer.has_ball or not is_gameplay_live():
        return
    var receiver := _select_pass_target(passer, input_dir)
    if receiver == null:
        feedback_label.text = "SEM LINHA DE PASSE"
        return

    var pass_context := _prepare_pass_context(passer, receiver, false)
    last_passer_by_team[passer.team_id] = passer
    if passer.team_id == TEAM_HOME and _current_play_call() == "GIVE & GO":
        home_cut_player = passer
        home_cut_time_left = GameTuning.GIVE_GO_CUT_SECONDS
    passer.release_ball()
    var pass_speed := lerpf(GameTuning.PASS_SPEED, GameTuning.STRONG_PASS_SPEED, float(passer.data.passing) / 100.0)
    ball.launch_pass(receiver.global_position + Vector3.UP * 1.02, receiver, pass_speed, passer.team_id)
    possession_team = passer.team_id
    if passer.controlled and tutorial_enabled:
        tutorial_flags["pass"] = true
        _refresh_tutorial()
    feedback_label.text = "PASSE → %s" % receiver.data.display_name
    if match_number == 7 and shot_feedback_enabled:
        feedback_label.text += " • RISCO %d%%" % roundi(
            float(pass_context.get("risk", 0.0)) * 100.0
        )

func request_lob(passer: DinoPlayer, input_dir: Vector2 = Vector2.ZERO) -> void:
    if passer == null or not passer.has_ball or not is_gameplay_live():
        return
    var receiver := _best_lob_target(passer, input_dir)
    if receiver == null:
        feedback_label.text = "SEM ALVO PARA O LOB"
        return

    _prepare_pass_context(passer, receiver, true)
    last_passer_by_team[passer.team_id] = passer
    passer.release_ball()
    possession_team = passer.team_id
    var hoop := _attack_hoop(passer.team_id)
    var target := receiver.global_position + Vector3.UP * 2.05
    if _flat_distance(receiver.global_position, hoop) <= GameTuning.ALLEY_TARGET_MAX_DISTANCE:
        var hoop_floor := Vector3(hoop.x, 0.0, hoop.z)
        target = receiver.global_position.lerp(hoop_floor, 0.28) + Vector3.UP * 2.35
    ball.launch_lob(target, receiver, GameTuning.LOB_PASS_FLIGHT, passer.team_id)
    feedback_label.text = "LOB → %s" % receiver.data.display_name


func request_pass_fake(passer: DinoPlayer, input_dir: Vector2) -> void:
    if passer == null or not passer.has_ball or not is_gameplay_live():
        return
    if not passer.can_attempt_pass_fake():
        feedback_label.text = "ESPERE PARA FINTAR NOVAMENTE"
        return
    passer.consume_pass_fake()
    passer.play_action_visual("PASS_FAKE")
    pass_fake_player = passer
    pass_fake_time_left = GameTuning.PASS_FAKE_DURATION
    pass_fake_safety_available = true
    fake_defender_targets.clear()

    var direction := Vector3(input_dir.x, 0.0, input_dir.y)
    if direction.length() <= 0.25:
        var suggested := _select_pass_target(passer, Vector2.ZERO)
        if suggested != null:
            direction = suggested.global_position - passer.global_position
            direction.y = 0.0
    if direction.length() <= 0.05:
        direction = Vector3(1.0, 0.0, 0.0)
    direction = direction.normalized()
    var fake_target := passer.global_position + direction * 7.0

    if match_number in [7, 8, 9, 10] and passer.team_id == TEAM_HOME:
        for defender_value in away_players:
            var defender := defender_value as DinoPlayer
            var lane := PassingLaneAnalyzer.distance_to_segment(
                defender.global_position,
                passer.global_position,
                fake_target
            )
            if float(lane.get("distance", INF)) <= 3.0:
                var closest: Vector3 = lane.get("closest", defender.global_position)
                var bait_direction := closest - defender.global_position
                bait_direction.y = 0.0
                if bait_direction.length() > 0.05:
                    closest += bait_direction.normalized() * GameTuning.PASS_FAKE_BAIT_STEP
                fake_defender_targets[defender.get_instance_id()] = closest
        _observe_home_action(&"pass_fake", true)
    _set_event_feedback(
        "FINTA DE PASSE • leia a reação antes de soltar a bola",
        Color(0.48, 0.88, 1.0),
        0.9
    )


func notify_ball_protection(player: DinoPlayer) -> void:
    if (
        player != null
        and player.team_id == TEAM_HOME
        and not home_protection_observed_this_possession
    ):
        home_protection_observed_this_possession = true
        _observe_home_action(&"protect_ball", true)


func _prepare_pass_context(
    passer: DinoPlayer,
    receiver: DinoPlayer,
    is_lob: bool
) -> Dictionary:
    var safety_bonus := 0.0
    if passer == pass_fake_player and pass_fake_safety_available:
        safety_bonus = GameTuning.PASS_FAKE_SAFETY_BONUS
        pass_fake_safety_available = false
        pass_fake_time_left = minf(pass_fake_time_left, 0.28)
    var context := PassingLaneAnalyzer.analyze(
        passer.global_position,
        receiver.global_position,
        _team_players(1 - passer.team_id),
        passer.data.passing,
        safety_bonus,
        is_lob
    )
    last_passer = passer
    last_pass_origin = passer.global_position
    last_pass_lane_risk = float(context.get("risk", 0.0))
    if passer.team_id == TEAM_HOME:
        var action := &"lob_pass" if is_lob else &"normal_pass"
        if bool(context.get("cross_court", false)):
            action = &"cross_court_pass"
        _observe_home_action(action, true)
    return context


func _observe_home_action(action: StringName, succeeded: bool) -> void:
    if match_number == 7:
        tendency_model.observe(action, succeeded)
    elif match_number == 8:
        var result := sequence_model.observe(action)
        _resolve_fossil_prediction(result)
    elif match_number == 9 and succeeded:
        _resolve_composure_event(composure_tracker.observe(action))
    elif match_number == 10 and succeeded:
        tendency_model.observe(action, true)
        var prediction_result := sequence_model.observe(action)
        var prediction_broken := false
        if bool(prediction_result.get("had_prediction", false)):
            crown_predictions_seen += 1
            if bool(prediction_result.get("correct", false)):
                crown_predictions_correct += 1
            else:
                crown_predictions_evaded += 1
                prediction_broken = true
        _resolve_crown_legacy(
            crown_legacy.observe_action(action, prediction_broken)
        )


func _resolve_crown_legacy(result: Dictionary) -> void:
    if match_number != 10 or not bool(result.get("broken", false)):
        return
    var broken_key := StringName(result.get("edict", &"balanced"))
    crown_edict = TyrantCrownMetaAI.Edict.BALANCED
    crown_edict_left = 0.0
    crown_legacy.set_edict(&"balanced")
    crown_last_announced_edict = ""
    if bool(result.get("shattered", false)):
        crown_shattered_left = GameTuning.CROWN_SHATTERED_DURATION
        crown_ai.crown_shattered = true
        crown_select_cooldown = crown_shattered_left
        _set_event_feedback(
            "☄ COROA PARTIDA ☄ • três decretos dominados • formação especial suspensa",
            Color(0.34, 1.0, 0.82),
            2.4
        )
    else:
        crown_select_cooldown = (
            GameTuning.CROWN_RESELECT_DELAY + crown_ai.reaction_time()
        )
        _set_event_feedback(
            "DECRETO QUEBRADO: %s • LEGADO %d%%" % [
                _crown_edict_name_from_key(broken_key),
                roundi(crown_legacy.legacy_meter),
            ],
            Color(1.0, 0.72, 0.24),
            2.0
        )


func _crown_edict_name_from_key(key: StringName) -> String:
    match key:
        &"iron_throne":
            return "TRONO DE FERRO"
        &"night_hunt":
            return "CAÇADA NOTURNA"
        &"written_fate":
            return "DESTINO ESCRITO"
        &"royal_command":
            return "COMANDO REAL"
        _:
            return "COROA EQUILIBRADA"


func _resolve_composure_event(result: Dictionary) -> void:
    if match_number != 9 or not bool(result.get("recorded", false)):
        return
    if bool(result.get("activated", false)):
        apex_silence_left = GameTuning.APEX_SILENCE_DURATION
        apex_roar_left = 0.0
        apex_roar_meter = 0.0
        apex_ai.roar_active = false
        apex_ai.silenced_active = true
        apex_plan_cooldown = apex_ai.reaction_time() + 0.85
        _set_event_feedback(
            "◇ SILÊNCIO DA VALE ◇ • os planos da Apex demoram mais para mudar",
            Color(0.42, 1.0, 0.86),
            2.2
        )


func _gain_apex_roar(amount: float, source: String) -> void:
    if (
        match_number != 9
        or amount <= 0.0
        or apex_roar_left > 0.0
        or apex_silence_left > 0.0
    ):
        return
    apex_roar_meter = clampf(
        apex_roar_meter + amount,
        0.0,
        GameTuning.APEX_ROAR_MAX
    )
    if apex_roar_meter < GameTuning.APEX_ROAR_MAX:
        return
    apex_roar_meter = 0.0
    apex_roar_left = GameTuning.APEX_ROAR_DURATION
    apex_ai.roar_active = true
    apex_plan_cooldown = 0.0
    _set_event_feedback(
        "◆ RUGIDO DA DOMINION ◆ • %s • planos acelerados, sem bônus ocultos" % source,
        Color(1.0, 0.63, 0.12),
        2.2
    )


func _resolve_fossil_prediction(result: Dictionary) -> void:
    if fossil_model_broken_left > 0.0:
        return
    if not bool(result.get("had_prediction", false)):
        for id in fossil_actions.keys():
            fossil_decision_cooldowns[id] = maxf(
                float(fossil_decision_cooldowns.get(id, 0.0)),
                fossil_ai.reaction_time()
            )
        return
    var model_just_broken := false
    fossil_predictions_seen += 1
    var predicted := StringName(result.get("predicted", &""))
    var actual := StringName(result.get("actual", &""))
    var confidence := clampf(float(result.get("confidence", 0.0)), 0.0, 1.0)
    if bool(result.get("correct", false)):
        fossil_predictions_correct += 1
        fossil_disruption_meter = maxf(0.0, fossil_disruption_meter - 12.0)
        if fossil_announce_cooldown <= 0.0:
            _set_event_feedback(
                "FOSSIL TECH CONFIRMOU %s • varie a próxima decisão" % _tendency_label(actual),
                Color(0.35, 0.92, 0.78),
                1.25
            )
            fossil_announce_cooldown = 3.0
    else:
        fossil_predictions_evaded += 1
        var disruption_gain := 20.0 + confidence * 22.0
        disruption_gain *= clampf(float(result.get("surprise", 0.5)) + 0.45, 0.75, 1.35)
        fossil_disruption_meter = minf(
            GameTuning.FOSSIL_DISRUPTION_MAX,
            fossil_disruption_meter + disruption_gain
        )
        _set_event_feedback(
            "PREVISÃO QUEBRADA • esperava %s, recebeu %s" % [
                _tendency_label(predicted),
                _tendency_label(actual),
            ],
            Color(1.0, 0.78, 0.28),
            1.7
        )
        if fossil_disruption_meter >= GameTuning.FOSSIL_DISRUPTION_MAX:
            fossil_disruption_meter = 0.0
            fossil_model_broken_left = GameTuning.FOSSIL_MODEL_BROKEN_DURATION
            fossil_ai.model_broken = true
            model_just_broken = true
            _set_event_feedback(
                "◆ MODELO QUEBRADO ◆ • previsões suspensas por %.0fs" % GameTuning.FOSSIL_MODEL_BROKEN_DURATION,
                Color(1.0, 0.72, 0.22),
                2.2
            )
    if model_just_broken:
        fossil_actions.clear()
        fossil_decision_cooldowns.clear()
    else:
        for id in fossil_actions.keys():
            fossil_decision_cooldowns[id] = maxf(
                float(fossil_decision_cooldowns.get(id, 0.0)),
                fossil_ai.reaction_time()
            )

func request_screen(ballhandler: DinoPlayer) -> void:
    if ballhandler == null or not ballhandler.has_ball or not is_gameplay_live():
        return
    if screen_call_cooldown > 0.0:
        feedback_label.text = "BLOQUEIO AINDA NÃO ESTÁ PRONTO"
        return

    var defender := _closest_defender_to_player(ballhandler)
    if defender == null:
        feedback_label.text = "SEM DEFENSOR PARA BLOQUEAR"
        return

    var best: DinoPlayer = null
    var best_score := -9999.0
    for candidate_value in _team_players(ballhandler.team_id):
        var candidate := candidate_value as DinoPlayer
        if candidate == ballhandler:
            continue
        var score := float(candidate.data.strength) - candidate.global_position.distance_to(defender.global_position) * 7.0
        if score > best_score:
            best_score = score
            best = candidate
    if best == null:
        return

    var toward_handler := ballhandler.global_position - defender.global_position
    toward_handler.y = 0.0
    if toward_handler.length() < 0.05:
        toward_handler = Vector3(0.0, 0.0, 1.0)
    toward_handler = toward_handler.normalized()
    var lateral := Vector3(-toward_handler.z, 0.0, toward_handler.x)
    screen_target = defender.global_position + toward_handler * 0.72 + lateral * 0.32
    screen_target.x = clampf(screen_target.x, -6.2, 6.2)
    screen_target.z = clampf(screen_target.z, -11.4, 11.4)

    screen_ballhandler = ballhandler
    screen_screener = best
    screen_defender = defender
    screen_setup_left = GameTuning.SCREEN_SETUP_SECONDS
    screen_roll_left = 0.0
    screen_call_cooldown = GameTuning.SCREEN_CALL_COOLDOWN
    screen_contact_done = false
    best.set_ai_target(screen_target, false)
    best.play_action_visual("SCREEN")
    if ballhandler.team_id == TEAM_HOME:
        _observe_home_action(&"screen", true)
    _set_event_feedback("BLOQUEIO → %s" % best.data.display_name, Color(0.85, 0.76, 0.58), 0.8)

func request_post_move(ballhandler: DinoPlayer) -> void:
    if ballhandler == null or not ballhandler.has_ball or not is_gameplay_live():
        return
    if not ballhandler.can_attempt_post_move():
        feedback_label.text = "SEM STAMINA PARA JOGO DE COSTAS"
        return
    var hoop := _attack_hoop(ballhandler.team_id)
    if _flat_distance(ballhandler.global_position, hoop) > GameTuning.POST_MAX_DISTANCE:
        feedback_label.text = "ENTRE NO POSTE PARA USAR O JOGO DE COSTAS"
        return
    var defender := _closest_defender_to_player(ballhandler)
    if defender == null or ballhandler.global_position.distance_to(defender.global_position) > GameTuning.POST_CONTACT_RADIUS:
        feedback_label.text = "SEM CONTATO PARA O BACKDOWN"
        return

    ballhandler.consume_post_move()
    ballhandler.play_action_visual("POST")
    if ballhandler.team_id == TEAM_HOME:
        _observe_home_action(&"post_move", true)
    var attack_strength := float(ballhandler.data.strength)
    var defense_strength := float(defender.data.strength)
    var defense_skill := float(defender.data.defense)
    var advantage := attack_strength - (defense_strength * 0.62 + defense_skill * 0.38)

    var charge_chance := GameTuning.POST_CHARGE_BASE_CHANCE + maxf(0.0, -advantage) * 0.0022
    if ballhandler.data.instinct_name == "Carga Tríplice" or ballhandler.data.instinct_name == "Aríete":
        charge_chance *= 0.72
    if not training_mode and rng.randf() <= charge_chance:
        _call_offensive_foul(ballhandler, "FALTA DE ATAQUE • CARGA")
        return

    var defensive_foul_chance := GameTuning.POST_DEFENSIVE_FOUL_CHANCE + maxf(0.0, advantage) * 0.0025
    defensive_foul_chance = clampf(defensive_foul_chance, 0.06, 0.28)
    if not training_mode and rng.randf() <= defensive_foul_chance:
        _call_nonshooting_foul(defender, ballhandler, "FALTA NO POSTE")
        return

    var toward_hoop := hoop - ballhandler.global_position
    toward_hoop.y = 0.0
    if toward_hoop.length() < 0.05:
        return
    toward_hoop = toward_hoop.normalized()
    var gain := clampf(0.68 + advantage / 90.0, 0.35, 1.18)
    var step := GameTuning.POST_BACKDOWN_STEP * gain
    ballhandler.global_position += toward_hoop * step
    defender.global_position += toward_hoop * step * 0.42
    _set_event_feedback("JOGO DE COSTAS • %s GANHA %.1fm" % [ballhandler.data.display_name, step], Color(0.9, 0.72, 0.45), 0.7)
    if match_number == 9 and ballhandler.team_id == TEAM_AWAY:
        _gain_apex_roar(GameTuning.APEX_POST_GAIN, "vantagem no poste")

func request_shot(shooter: DinoPlayer, held_seconds: float) -> void:
    if shooter == null or not shooter.has_ball or not is_gameplay_live():
        return
    var timing_error := absf(held_seconds - GameTuning.SHOT_IDEAL_HOLD)
    var timing_quality := clampf(1.0 - timing_error / GameTuning.SHOT_TIMING_RANGE, 0.0, 1.0)
    if shooter.controlled and tutorial_enabled:
        tutorial_flags["shot"] = true
        _refresh_tutorial()
    if shooter.team_id == TEAM_HOME:
        _observe_home_action(&"jump_shot", true)
    _release_shot(shooter, timing_quality, held_seconds)

func request_finish(shooter: DinoPlayer) -> void:
    if shooter == null or not shooter.has_ball or not is_gameplay_live():
        return
    var hoop := _attack_hoop(shooter.team_id)
    var flat_distance := _flat_distance(shooter.global_position, hoop)
    if flat_distance > GameTuning.FINISH_MAX_DISTANCE:
        feedback_label.text = "LONGE DEMAIS PARA FINALIZAR"
        return
    if shooter.team_id == TEAM_HOME:
        _observe_home_action(&"drive", true)

    var dunk_rating := float(shooter.data.strength) * 0.65 + shooter.data.gameplay_height * 18.0
    var is_dunk := flat_distance <= GameTuning.DUNK_MAX_DISTANCE and dunk_rating >= 92.0
    var contest := _calculate_contest(shooter, hoop)
    var contact_defender := _closest_defender_to_player(shooter)
    if not training_mode and contact_defender != null and shooter.global_position.distance_to(contact_defender.global_position) <= GameTuning.POST_CONTACT_RADIUS:
        var foul_chance := GameTuning.FINISH_FOUL_BASE_CHANCE + contest * 0.14
        var attack_edge := maxf(0.0, float(shooter.data.strength - contact_defender.data.defense))
        foul_chance += attack_edge * 0.0015
        if rng.randf() <= clampf(foul_chance, 0.10, 0.34):
            _start_free_throws(shooter, 2, contact_defender, "FALTA NA FINALIZAÇÃO")
            return
    var skill := float(shooter.data.shooting) / 100.0
    var strength := float(shooter.data.strength) / 100.0
    var quality := 0.68 + skill * 0.16 + strength * 0.12 - contest * 0.22
    if is_dunk:
        quality += 0.08
    if shooter.data.instinct_name == "Carga Tríplice":
        quality += 0.06
    if is_instinct_active(shooter.team_id):
        quality += GameTuning.INSTINCT_SHOT_BONUS
    quality = clampf(quality, 0.35, 0.99)

    _record_shot_attempt(shooter, 2)
    shooter.play_action_visual("DUNK" if is_dunk else "LAYUP")
    shooter.release_ball()
    possession_team = shooter.team_id
    last_shot_team = shooter.team_id
    last_shooter = shooter
    last_shot_value = 2
    last_shot_type = "DUNK" if is_dunk else "LAYUP"

    var miss_strength := pow(1.0 - quality, 1.4) * (0.42 if is_dunk else 0.62)
    var angle := rng.randf_range(0.0, TAU)
    var miss := Vector3(cos(angle) * miss_strength, 0.0, sin(angle) * miss_strength)
    var flight := GameTuning.DUNK_FLIGHT if is_dunk else GameTuning.LAYUP_FLIGHT
    ball.launch_arc(hoop + miss, flight, shooter.team_id, shooter, 2, last_shot_type)
    feedback_label.text = ("%s • %s • Q %d%%" % [last_shot_type, _contest_label(contest), roundi(quality * 100.0)]) if shot_feedback_enabled else last_shot_type

func request_block(defender: DinoPlayer) -> void:
    if defender == null or not is_gameplay_live() or not defender.can_attempt_block():
        return
    defender.consume_block_attempt()
    if ball.state != MeteorBall.BallState.SHOT or not is_instance_valid(last_shooter):
        feedback_label.text = "TOCO FORA DE TEMPO"
        return
    if defender.team_id == last_shooter.team_id:
        return
    if ball.state_age_seconds() > GameTuning.BLOCK_WINDOW:
        feedback_label.text = "TOCO ATRASADO"
        return

    var shooter_distance := defender.global_position.distance_to(last_shooter.global_position)
    var ball_distance := defender.global_position.distance_to(ball.global_position)
    if shooter_distance > GameTuning.BLOCK_REACH and ball_distance > GameTuning.BLOCK_BALL_RADIUS:
        feedback_label.text = "FORA DO ALCANCE"
        return

    var defense := float(defender.data.defense) / 100.0
    var strength := float(defender.data.strength) / 100.0
    var height_edge := clampf((defender.data.gameplay_height - last_shooter.data.gameplay_height) * 0.22, -0.08, 0.10)
    var chance := clampf(0.24 + defense * 0.28 + strength * 0.14 + height_edge, 0.20, 0.72)
    if defender.data.instinct_name == "Muralha Fóssil":
        chance += 0.12
    if rng.randf() <= chance:
        var swat_dir := ball.global_position - defender.global_position
        swat_dir.y = 0.15
        ball.swat(swat_dir, defender.team_id)
        last_shot_team = -1
        defender.play_action_visual("BLOCK")
        _stat_inc(defender, "blocks", 1)
        _gain_instinct(defender.team_id, GameTuning.INSTINCT_BLOCK_GAIN)
        if match_number == 7 and defender.team_id == TEAM_AWAY:
            _gain_nightclaw_takeover(GameTuning.NIGHT_TAKEOVER_BLOCK_GAIN)
        _set_event_feedback("TOCO! • %s" % defender.data.display_name, Color(0.35, 0.9, 1.0), 0.9)
        if match_number == 9 and defender.team_id == TEAM_AWAY:
            _gain_apex_roar(GameTuning.APEX_BLOCK_GAIN, "toco da muralha")
        _play_sfx("res://audio/sfx/block.wav")
    else:
        var foul_chance := GameTuning.BLOCK_FOUL_CHANCE + maxf(0.0, 0.7 - defense) * 0.10
        if not training_mode and rng.randf() <= clampf(foul_chance, 0.10, 0.30):
            _start_free_throws(last_shooter, maxi(2, last_shot_value), defender, "FALTA NO TOCO")
        else:
            feedback_label.text = "QUASE TOCOU"

func request_rebound(player: DinoPlayer) -> void:
    if player == null or not is_gameplay_live() or not player.can_attempt_rebound():
        return
    if ball.state != MeteorBall.BallState.SHOT and ball.state != MeteorBall.BallState.LOOSE:
        return
    if ball.state == MeteorBall.BallState.SHOT and ball.linear_velocity.y >= 0.0:
        feedback_label.text = "ESPERE A BOLA DESCER"
        return
    if ball.global_position.y > GameTuning.REBOUND_TIMING_MAX_HEIGHT:
        feedback_label.text = "BOLA AINDA ALTA"
        return

    var horizontal_distance := _flat_distance(player.global_position, ball.global_position)
    if horizontal_distance > GameTuning.REBOUND_JUMP_REACH:
        feedback_label.text = "FORA DA ZONA DE REBOTE"
        return

    player.consume_rebound_attempt()
    player.play_action_visual("REBOUND")
    var timing := clampf(1.0 - absf(ball.global_position.y - GameTuning.REBOUND_IDEAL_HEIGHT) / GameTuning.REBOUND_TIMING_RANGE, 0.0, 1.0)
    var height_score := clampf((player.data.gameplay_height - GameTuning.MIN_GAMEPLAY_HEIGHT) / (GameTuning.MAX_GAMEPLAY_HEIGHT - GameTuning.MIN_GAMEPLAY_HEIGHT), 0.0, 1.0)
    var physical := float(player.data.strength + player.data.defense) / 200.0
    var chance := clampf(0.22 + timing * 0.46 + physical * 0.20 + height_score * 0.12, 0.18, 0.96)
    if player.boxing_out:
        chance += GameTuning.BOX_OUT_REBOUND_BONUS
    if player.data.instinct_name == "Muralha Fóssil":
        chance += 0.10
    if match_number == 6 and player.team_id == TEAM_AWAY:
        chance += 0.08
    var rebounding_opponent := _closest_defender_to_player(player)
    if rebounding_opponent != null and rebounding_opponent.boxing_out and player.global_position.distance_to(rebounding_opponent.global_position) <= GameTuning.BOX_OUT_CONTACT_RADIUS:
        chance -= 0.13
    chance = clampf(chance, 0.12, 0.98)

    if rng.randf() <= chance:
        ball.make_loose()
        _give_ball_to(player, "REBOTE NO TEMPO")
        _set_event_feedback("▲ REBOTE NO TEMPO • %s" % player.data.display_name, Color(0.45, 0.9, 1.0), 0.75)
    else:
        var timing_word := "CEDO" if ball.global_position.y > GameTuning.REBOUND_IDEAL_HEIGHT else "TARDE"
        feedback_label.text = "REBOTE %s • timing %d%%" % [timing_word, roundi(timing * 100.0)]

func request_instinct(player: DinoPlayer) -> void:
    if player == null or not is_gameplay_live():
        return
    var team := player.team_id
    if is_instinct_active(team):
        feedback_label.text = "INSTINTO JÁ ESTÁ ATIVO"
        return
    if float(instinct_meter[team]) < GameTuning.INSTINCT_MAX:
        feedback_label.text = "INSTINTO %d%%" % roundi(float(instinct_meter[team]))
        return
    instinct_meter[team] = 0.0
    instinct_time_left[team] = GameTuning.INSTINCT_DURATION
    _set_event_feedback("☄ INSTINTO METEORO • %s" % player.data.instinct_name, Color(1.0, 0.55, 0.15), 1.4)
    _play_sfx("res://audio/sfx/instinct.wav")

func request_pickup_or_steal(player: DinoPlayer) -> void:
    if player == null or player.has_ball:
        return

    if ball.state == MeteorBall.BallState.LOOSE and player.global_position.distance_to(ball.global_position) <= GameTuning.REBOUND_PICKUP_RADIUS:
        _give_ball_to(player, "REBOTE")
        return

    if ball.state != MeteorBall.BallState.HELD or not is_instance_valid(ball.holder):
        return
    if not (ball.holder is DinoPlayer):
        return

    var holder := ball.holder as DinoPlayer
    if holder.team_id == player.team_id:
        return
    if player.global_position.distance_to(holder.global_position) > GameTuning.STEAL_REACH:
        return
    if not player.can_attempt_steal():
        return

    player.consume_steal_attempt()
    var defense_factor := float(player.data.defense) / 100.0
    var protection_factor := float(holder.data.passing + holder.data.strength) / 200.0
    if holder.protecting_ball:
        protection_factor += 0.42
    if holder.data.instinct_name == "Carga Tríplice":
        protection_factor += 0.10
    var chance := clampf(0.18 + defense_factor * 0.38 - protection_factor * 0.20, 0.08, 0.48)
    if rng.randf() <= chance:
        _register_turnover(holder, "ROUBO", player.team_id)
        holder.release_ball()
        _stat_inc(player, "steals", 1)
        _gain_instinct(player.team_id, GameTuning.INSTINCT_STEAL_GAIN)
        _give_ball_to(player, "ROUBO!")
        if match_number == 7 and player.team_id == TEAM_AWAY:
            _gain_nightclaw_takeover(GameTuning.NIGHT_TAKEOVER_STEAL_GAIN)
    else:
        var foul_chance := GameTuning.STEAL_REACH_FOUL_CHANCE + maxf(0.0, 0.70 - defense_factor) * 0.10
        if not training_mode and rng.randf() <= clampf(foul_chance, 0.08, 0.24):
            _call_nonshooting_foul(player, holder, "FALTA NA TENTATIVA DE ROUBO")
        else:
            feedback_label.text = "MÃO VAZIA"

func _release_shot(shooter: DinoPlayer, timing_quality: float, held_seconds: float = GameTuning.SHOT_IDEAL_HOLD) -> void:
    var target_hoop := _attack_hoop(shooter.team_id)
    var contest := _calculate_contest(shooter, target_hoop)
    var openness := 1.0 - contest
    var skill := float(shooter.data.shooting) / 100.0
    var fatigue_penalty := clampf((45.0 - shooter.stamina) / 45.0, 0.0, 1.0) * 0.16
    var quality := skill * 0.45 + timing_quality * 0.35 + openness * 0.20 - fatigue_penalty
    if shooter.data.instinct_name == "Eco Lunar" and contest < 0.25:
        quality += 0.05
    if is_instinct_active(shooter.team_id):
        quality += GameTuning.INSTINCT_SHOT_BONUS
    quality = clampf(quality, 0.0, 1.0)

    var distance := _flat_distance(shooter.global_position, target_hoop)
    last_shot_value = 3 if distance >= GameTuning.THREE_POINT_DISTANCE else 2
    _record_shot_attempt(shooter, last_shot_value)
    shooter.play_action_visual("SHOT")
    shooter.release_ball()
    possession_team = shooter.team_id
    last_shot_team = shooter.team_id
    last_shooter = shooter

    last_shot_type = "3PT" if last_shot_value == 3 else "JUMPER"
    var flight := clampf(GameTuning.SHOT_MIN_FLIGHT + distance * 0.012, GameTuning.SHOT_MIN_FLIGHT, GameTuning.SHOT_MAX_FLIGHT)
    var miss_strength := pow(1.0 - quality, 1.35) * 0.78
    if quality > 0.91:
        miss_strength *= 0.35
    var angle := rng.randf_range(0.0, TAU)
    var miss := Vector3(cos(angle) * miss_strength, 0.0, sin(angle) * miss_strength * 0.82)
    ball.launch_arc(target_hoop + miss, flight, shooter.team_id, shooter, last_shot_value, last_shot_type)

    if shooter.controlled:
        var is_green := absf(held_seconds - GameTuning.SHOT_IDEAL_HOLD) <= _green_window()
        var timing_label := "PERFEITO" if is_green else ("CEDO" if held_seconds < GameTuning.SHOT_IDEAL_HOLD else "TARDE")
        var shot_text := "%s • %dPT" % [timing_label, last_shot_value]
        if shot_feedback_enabled:
            shot_text += " • %s • Q %d%%" % [_contest_label(contest), roundi(quality * 100.0)]
        if is_green:
            _set_event_feedback("◆ GREEN RELEASE ◆  " + shot_text, Color(0.35, 1.0, 0.52), 1.0)
            _play_sfx("res://audio/sfx/green.wav")
        else:
            feedback_label.text = shot_text

func _select_pass_target(passer: DinoPlayer, input_dir: Vector2) -> DinoPlayer:
    var teammates := _team_players(passer.team_id)
    var candidates: Array = []
    for candidate in teammates:
        if candidate != passer:
            candidates.append(candidate)
    if candidates.is_empty():
        return null

    var desired := Vector3(input_dir.x, 0.0, input_dir.y)
    var use_direction := desired.length() > 0.25
    if use_direction:
        desired = desired.normalized()

    var best: DinoPlayer = candidates[0]
    var best_score := -10000.0
    for candidate in candidates:
        var to_candidate := candidate.global_position - passer.global_position
        to_candidate.y = 0.0
        var distance := maxf(0.01, to_candidate.length())
        var direction_score := 0.0
        if use_direction:
            direction_score = desired.dot(to_candidate.normalized()) * 4.0
        else:
            direction_score = _openness_score(candidate) * 2.5
        var score := direction_score - distance * 0.06 + _openness_score(candidate)
        if score > best_score:
            best_score = score
            best = candidate
    return best

func _best_lob_target(passer: DinoPlayer, input_dir: Vector2 = Vector2.ZERO) -> DinoPlayer:
    var candidates: Array = []
    for candidate in _team_players(passer.team_id):
        if candidate != passer:
            candidates.append(candidate)
    if candidates.is_empty():
        return null

    var desired := Vector3(input_dir.x, 0.0, input_dir.y)
    var use_direction := desired.length() > 0.25
    if use_direction:
        desired = desired.normalized()
    var hoop := _attack_hoop(passer.team_id)
    var best: DinoPlayer = null
    var best_score := -999.0
    for candidate in candidates:
        var to_candidate := candidate.global_position - passer.global_position
        to_candidate.y = 0.0
        var hoop_distance := _flat_distance(candidate.global_position, hoop)
        var score := (GameTuning.ALLEY_TARGET_MAX_DISTANCE - hoop_distance) * 0.75
        score += _openness_score(candidate) * 1.15
        score += float(candidate.data.strength) / 100.0
        if use_direction and to_candidate.length() > 0.01:
            score += desired.dot(to_candidate.normalized()) * 2.2
        if score > best_score:
            best_score = score
            best = candidate
    return best

func _complete_alley_oop(receiver: DinoPlayer) -> void:
    if receiver == null:
        return
    var hoop := _attack_hoop(receiver.team_id)
    if _flat_distance(receiver.global_position, hoop) > GameTuning.ALLEY_TARGET_MAX_DISTANCE:
        _give_ball_to(receiver, "PASSE ALTO")
        return

    var contest := _calculate_contest(receiver, hoop)
    var physical := float(receiver.data.strength) / 100.0
    var height_score := clampf((receiver.data.gameplay_height - GameTuning.MIN_GAMEPLAY_HEIGHT) / (GameTuning.MAX_GAMEPLAY_HEIGHT - GameTuning.MIN_GAMEPLAY_HEIGHT), 0.0, 1.0)
    var quality := clampf(0.64 + physical * 0.16 + height_score * 0.14 - contest * 0.20, 0.40, 0.98)
    if receiver.data.instinct_name == "Turbina Óssea":
        quality += 0.08
    quality = clampf(quality, 0.0, 0.99)

    _record_shot_attempt(receiver, 2)
    receiver.play_action_visual("ALLEY")
    possession_team = receiver.team_id
    last_shot_team = receiver.team_id
    last_shooter = receiver
    last_shot_value = 2
    last_shot_type = "ALLEY-OOP"

    var miss_strength := pow(1.0 - quality, 1.5) * 0.40
    var angle := rng.randf_range(0.0, TAU)
    var miss := Vector3(cos(angle) * miss_strength, 0.0, sin(angle) * miss_strength)
    ball.launch_arc(hoop + miss, GameTuning.DUNK_FLIGHT, receiver.team_id, receiver, 2, last_shot_type)
    _set_event_feedback("△ ALLEY-OOP • %s" % receiver.data.display_name, Color(0.4, 0.86, 1.0), 0.9)

func _update_ball_state_and_capture() -> void:
    if not is_instance_valid(ball):
        return

    if ball.state == MeteorBall.BallState.PASS:
        if is_instance_valid(ball.intended_receiver):
            var receiver := ball.intended_receiver as DinoPlayer
            if receiver != null and ball.pass_style == "LOB":
                var lob_distance := receiver.global_position.distance_to(ball.global_position)
                if lob_distance <= GameTuning.ALLEY_CATCH_RADIUS and ball.global_position.y >= GameTuning.ALLEY_MIN_BALL_HEIGHT and ball.global_position.y <= GameTuning.ALLEY_MAX_BALL_HEIGHT:
                    _complete_alley_oop(receiver)
                    return
                if lob_distance <= GameTuning.PASS_RECEIVE_RADIUS * 1.15 and ball.global_position.y <= 2.20:
                    _give_ball_to(receiver, "PASSE ALTO")
                    return
            elif receiver != null and receiver.global_position.distance_to(ball.global_position) <= GameTuning.PASS_RECEIVE_RADIUS and ball.global_position.y <= 2.15:
                _give_ball_to(receiver, "RECEPÇÃO")
                return

        var intercept_radius := GameTuning.INTERCEPT_RADIUS * (0.78 if ball.pass_style == "LOB" else 1.0)
        var reaction_ready := true
        if match_number == 7 and ball.last_touch_team == TEAM_HOME:
            intercept_radius *= lerpf(0.72, 1.15, last_pass_lane_risk)
            intercept_radius += GameTuning.NIGHT_INTERCEPT_RADIUS_BONUS
            if nightclaw_takeover_left > 0.0:
                intercept_radius += GameTuning.NIGHT_TAKEOVER_INTERCEPT_BONUS
            reaction_ready = ball.state_age_seconds() >= nightclaw_ai.reaction_time()
        elif (
            match_number == 10
            and ball.last_touch_team == TEAM_HOME
            and crown_edict in [
                TyrantCrownMetaAI.Edict.NIGHT_HUNT,
                TyrantCrownMetaAI.Edict.WRITTEN_FATE,
            ]
        ):
            # The Crown reacts sooner when its visible decree calls for a read,
            # but keeps the standard interception radius and ball physics.
            reaction_ready = ball.state_age_seconds() >= crown_ai.reaction_time()
        var interceptor: DinoPlayer = null
        if reaction_ready:
            interceptor = _closest_opponent_to_ball(ball.last_touch_team, intercept_radius)
        if interceptor != null and ball.global_position.y <= (2.15 if ball.pass_style == "LOB" else 1.65) and ball.state_age_seconds() > 0.12:
            _register_turnover(last_passer, "PASSE INTERCEPTADO", interceptor.team_id)
            _give_ball_to(interceptor, "INTERCEPTAÇÃO")
            if match_number == 7 and interceptor.team_id == TEAM_AWAY:
                _gain_nightclaw_takeover(GameTuning.NIGHT_TAKEOVER_INTERCEPTION_GAIN)
            return

        if ball.state_age_seconds() > 1.45 or (ball.global_position.y < 0.42 and ball.linear_velocity.y <= 0.0):
            ball.make_loose()

    if ball.state == MeteorBall.BallState.SHOT:
        if ball.state_age_seconds() > 0.48 and ball.linear_velocity.y < 0.0 and ball.global_position.y <= GameTuning.LOOSE_BALL_HEIGHT:
            ball.make_loose()

    if ball.state == MeteorBall.BallState.LOOSE and ball.state_age_seconds() >= GameTuning.REBOUND_AUTO_DELAY:
        var rebounder := _nearest_player_to_ball(GameTuning.REBOUND_PICKUP_RADIUS)
        if rebounder != null and ball.global_position.y <= GameTuning.LOOSE_BALL_HEIGHT:
            _give_ball_to(rebounder, "REBOTE")

func _update_screen_action(delta: float) -> void:
    if not is_instance_valid(screen_screener) or not is_instance_valid(screen_ballhandler) or not is_instance_valid(screen_defender):
        _clear_screen_state()
        return
    if screen_ballhandler.team_id != possession_team or not screen_ballhandler.has_ball:
        _clear_screen_state()
        return

    if screen_setup_left > 0.0:
        screen_setup_left = maxf(0.0, screen_setup_left - delta)
        screen_screener.set_ai_target(screen_target, false)
        if not screen_contact_done and screen_screener.global_position.distance_to(screen_defender.global_position) <= GameTuning.SCREEN_CONTACT_RADIUS:
            screen_contact_done = true
            screen_defender.apply_movement_slow(GameTuning.SCREEN_SLOW_SECONDS, GameTuning.SCREEN_SLOW_MULTIPLIER)
            screen_setup_left = 0.0
            screen_roll_left = GameTuning.SCREEN_ROLL_SECONDS
            screen_screener.play_action_visual("SCREEN")
            _set_event_feedback("BLOQUEIO PEGOU! • %s ROLA PARA O ARO" % screen_screener.data.display_name, Color(0.95, 0.78, 0.42), 0.8)
            if match_number == 9 and screen_screener.team_id == TEAM_AWAY:
                _gain_apex_roar(GameTuning.APEX_SCREEN_GAIN, "bloqueio de potência")
        elif screen_setup_left <= 0.0:
            _clear_screen_state()
        return

    if screen_roll_left > 0.0:
        screen_roll_left = maxf(0.0, screen_roll_left - delta)
        var hoop := _attack_hoop(screen_screener.team_id)
        var roll_target := Vector3(hoop.x, 0.0, hoop.z)
        var offset_sign := -1.0 if screen_screener.roster_index % 2 == 0 else 1.0
        roll_target.x += 1.15 * offset_sign
        roll_target.z += 1.6 if screen_screener.team_id == TEAM_HOME else -1.6
        screen_screener.set_ai_target(roll_target, true)
        if screen_roll_left <= 0.0:
            _clear_screen_state()

func _clear_screen_state() -> void:
    screen_ballhandler = null
    screen_screener = null
    screen_defender = null
    screen_setup_left = 0.0
    screen_roll_left = 0.0
    screen_contact_done = false

func _update_ai(delta: float) -> void:
    for key in ai_action_cooldowns.keys():
        ai_action_cooldowns[key] = maxf(0.0, float(ai_action_cooldowns[key]) - delta)
    for key in nightclaw_decision_cooldowns.keys():
        nightclaw_decision_cooldowns[key] = maxf(
            0.0,
            float(nightclaw_decision_cooldowns[key]) - delta
        )
    for key in fossil_decision_cooldowns.keys():
        fossil_decision_cooldowns[key] = maxf(
            0.0,
            float(fossil_decision_cooldowns[key]) - delta
        )

    for value in all_players:
        var ai_player := value as DinoPlayer
        if ai_player != controlled_player:
            ai_player.set_ai_box_out(false)

    var rebound_window := (ball.state == MeteorBall.BallState.SHOT and ball.linear_velocity.y < 0.0) or ball.state == MeteorBall.BallState.LOOSE
    if rebound_window:
        for value in all_players:
            var rebound_player := value as DinoPlayer
            if rebound_player == controlled_player:
                continue
            var defended_hoop := _defended_hoop(rebound_player.team_id)
            var close_to_paint := _flat_distance(rebound_player.global_position, defended_hoop) <= 5.2
            var defensive_rebounder := last_shot_team in [TEAM_HOME, TEAM_AWAY] and rebound_player.team_id != last_shot_team
            var ironhorn_habit := match_number == 6 and rebound_player.team_id == TEAM_AWAY
            var apex_glass_habit := (
                match_number == 9
                and rebound_player.team_id == TEAM_AWAY
                and apex_defensive_plan == ApexCoordinationAI.DefensivePlan.CONTROL_GLASS
            )
            var crown_glass_habit := (
                match_number == 10
                and rebound_player.team_id == TEAM_AWAY
                and crown_edict in [
                    TyrantCrownMetaAI.Edict.IRON_THRONE,
                    TyrantCrownMetaAI.Edict.ROYAL_COMMAND,
                ]
            )
            if close_to_paint and defensive_rebounder and (ironhorn_habit or apex_glass_habit or crown_glass_habit or float(rebound_player.data.strength) >= 88.0):
                rebound_player.set_ai_box_out(true)

    if match_number == 9 and ball.state == MeteorBall.BallState.LOOSE:
        _update_apex_plan(null, rebound_window)
    if match_number == 10 and ball.state == MeteorBall.BallState.LOOSE:
        _update_crown_edict(null, rebound_window)
    if ball.state == MeteorBall.BallState.LOOSE:
        for player in all_players:
            if player == controlled_player:
                continue
            if player.ai_box_out:
                var opponent := _closest_defender_to_player(player)
                if opponent != null:
                    var defended := _defended_hoop(player.team_id)
                    var seal_dir := defended - opponent.global_position
                    seal_dir.y = 0.0
                    if seal_dir.length() > 0.05:
                        player.set_ai_target(opponent.global_position + seal_dir.normalized() * 0.65, false)
                    else:
                        player.set_ai_target(player.global_position, false)
                else:
                    player.set_ai_target(player.global_position, false)
            else:
                player.set_ai_target(ball.global_position, true)
        return

    var offense := _team_players(possession_team)
    var defense := _team_players(1 - possession_team)
    var holder: DinoPlayer = null
    if ball.state == MeteorBall.BallState.HELD and ball.holder is DinoPlayer:
        holder = ball.holder as DinoPlayer
    if match_number == 9:
        _update_apex_plan(holder, rebound_window)
    if match_number == 10:
        _update_crown_edict(holder, rebound_window)

    for player in offense:
        if player == controlled_player:
            continue
        if player == holder:
            _update_ai_ballhandler(player)
        elif player == screen_screener and (screen_setup_left > 0.0 or screen_roll_left > 0.0):
            pass
        elif player.team_id == TEAM_HOME and player == home_cut_player and home_cut_time_left > 0.0:
            var cut_target := _attack_hoop(TEAM_HOME) + Vector3(0.0, -GameTuning.HOOP_HEIGHT, 1.8)
            player.set_ai_target(cut_target, true)
        elif match_number == 9 and player.team_id == TEAM_AWAY:
            player.set_ai_target(
                _apex_offball_anchor(player),
                apex_offensive_plan == ApexCoordinationAI.OffensivePlan.CRASH_GLASS
            )
        elif match_number == 10 and player.team_id == TEAM_AWAY:
            player.set_ai_target(
                _crown_offball_anchor(player),
                crown_edict == TyrantCrownMetaAI.Edict.ROYAL_COMMAND
            )
        else:
            player.set_ai_target(_spacing_anchor(player.team_id, player.roster_index), false)

    for defender in defense:
        if defender == controlled_player:
            continue
        var assignment := offense[defender.roster_index % offense.size()] as DinoPlayer
        var night_defense := match_number == 7 and defender.team_id == TEAM_AWAY
        var fossil_defense := match_number == 8 and defender.team_id == TEAM_AWAY
        var apex_defense := match_number == 9 and defender.team_id == TEAM_AWAY
        var crown_defense := match_number == 10 and defender.team_id == TEAM_AWAY
        var defender_id := defender.get_instance_id()
        var crown_bites_fake := (
            crown_defense
            and crown_edict == TyrantCrownMetaAI.Edict.NIGHT_HUNT
        )
        if (night_defense or fossil_defense or crown_bites_fake) and fake_defender_targets.has(defender_id):
            var fake_target: Vector3 = fake_defender_targets[defender_id]
            defender.set_ai_target(
                fake_target,
                false
            )
            continue
        if defender.ai_box_out:
            var defended_hoop := _defended_hoop(defender.team_id)
            var seal_dir := defended_hoop - assignment.global_position
            seal_dir.y = 0.0
            var seal_target := assignment.global_position
            if seal_dir.length() > 0.05:
                seal_target += seal_dir.normalized() * 0.65
            defender.set_ai_target(seal_target, false)
            continue
        var hoop := _attack_hoop(possession_team)
        var toward_hoop := hoop - assignment.global_position
        toward_hoop.y = 0.0
        var contain := assignment.global_position
        var contain_gap := GameTuning.AI_CONTAIN_GAP
        var ember_press := match_number == 3 and defender.team_id == TEAM_AWAY
        var tide_rotate := match_number == 4 and defender.team_id == TEAM_AWAY
        var iron_body := match_number == 6 and defender.team_id == TEAM_AWAY
        if ember_press:
            contain_gap = GameTuning.EMBER_PRESS_GAP
        if iron_body:
            contain_gap = GameTuning.IRON_CONTAIN_GAP
        if tide_rotate:
            contain_gap *= 0.92
            contain.x += sin(float(Time.get_ticks_msec()) / 650.0 + float(defender.roster_index)) * 0.38
        if night_defense:
            var decision := _nightclaw_decision_for(defender, assignment, holder)
            var action := int(decision.get(
                "action",
                NightclawUtilityAI.DefensiveAction.CONTAIN
            ))
            var night_target := _nightclaw_defensive_target(
                defender,
                assignment,
                holder,
                action,
                contain,
                toward_hoop
            )
            var sprint_to_target := action in [
                NightclawUtilityAI.DefensiveAction.PRESSURE_BALL,
                NightclawUtilityAI.DefensiveAction.TRAP,
                NightclawUtilityAI.DefensiveAction.RETREAT,
            ]
            defender.set_ai_target(night_target, sprint_to_target)
            continue
        if fossil_defense:
            var fossil_decision := _fossil_decision_for(defender)
            var scheme := int(fossil_decision.get(
                "scheme",
                FossilTechPredictiveAI.DefensiveScheme.BALANCED
            ))
            var fossil_target := _fossil_defensive_target(
                defender,
                assignment,
                holder,
                scheme,
                contain,
                toward_hoop
            )
            var fossil_sprint := scheme in [
                FossilTechPredictiveAI.DefensiveScheme.JUMP_PASS_LANE,
                FossilTechPredictiveAI.DefensiveScheme.EARLY_CLOSEOUT,
                FossilTechPredictiveAI.DefensiveScheme.SWITCH_SCREEN,
            ]
            defender.set_ai_target(fossil_target, fossil_sprint)
            continue
        if apex_defense:
            var apex_target := _apex_defensive_target(
                defender,
                assignment,
                holder,
                contain,
                toward_hoop
            )
            var apex_sprint := apex_defensive_plan in [
                ApexCoordinationAI.DefensivePlan.PRESS_BALL,
                ApexCoordinationAI.DefensivePlan.SWITCH_ALL,
            ]
            defender.set_ai_target(apex_target, apex_sprint)
            continue
        if crown_defense:
            var crown_target := _crown_defensive_target(
                defender,
                assignment,
                holder,
                contain,
                toward_hoop
            )
            var crown_sprint := crown_edict in [
                TyrantCrownMetaAI.Edict.NIGHT_HUNT,
                TyrantCrownMetaAI.Edict.WRITTEN_FATE,
                TyrantCrownMetaAI.Edict.ROYAL_COMMAND,
            ]
            defender.set_ai_target(crown_target, crown_sprint)
            continue
        if toward_hoop.length() > 0.01:
            contain += toward_hoop.normalized() * contain_gap
        defender.set_ai_target(contain, assignment == holder or ember_press)


func _update_crown_edict(holder: DinoPlayer, rebound_window: bool) -> void:
    if (
        match_number != 10
        or possession_team != TEAM_HOME
        or crown_shattered_left > 0.0
        or crown_select_cooldown > 0.0
        or crown_edict_left > 0.0
    ):
        return

    var hoop := _attack_hoop(TEAM_HOME)
    var holder_distance := 9.0
    var holder_strength := 50.0
    if holder != null and holder.team_id == TEAM_HOME:
        holder_distance = _flat_distance(holder.global_position, hoop)
        holder_strength = float(holder.data.strength)
    var drive_threat := clampf(1.0 - holder_distance / 8.5, 0.0, 1.0)
    var post_threat := 0.0
    if holder_distance <= GameTuning.POST_MAX_DISTANCE + 1.0:
        post_threat = clampf((holder_strength - 42.0) / 58.0, 0.0, 1.0)
    var paint_frequency := clampf(
        tendency_model.tendency(&"drive")
        + tendency_model.tendency(&"post_move")
        + tendency_model.tendency(&"finish"),
        0.0,
        1.0
    )
    var pass_tendency := clampf(
        tendency_model.tendency(&"normal_pass")
        + tendency_model.tendency(&"cross_court_pass")
        + tendency_model.tendency(&"lob_pass"),
        0.0,
        1.0
    )
    var forecast := sequence_model.predict_next()
    var unavailable: Array = []
    for key in crown_legacy.broken_edict_keys():
        unavailable.append(_crown_edict_from_key(key))
    var decision := crown_ai.choose_edict({
        "drive_threat": drive_threat,
        "post_threat": post_threat,
        "paint_frequency": paint_frequency,
        "pass_tendency": pass_tendency,
        "lane_risk": last_pass_lane_risk,
        "turnover_pressure": clampf(
            float(turnovers[TEAM_HOME]) / maxf(1.0, float(possession_count)),
            0.0,
            1.0
        ),
        "prediction_available": bool(forecast.get("available", false)),
        "prediction_confidence": float(forecast.get("confidence", 0.0)),
        "screen_active": is_instance_valid(screen_screener),
        "clock_pressure": clampf(
            1.0 - shot_clock_left / GameTuning.SHOT_CLOCK,
            0.0,
            1.0
        ),
        "rebound_priority": 1.0 if rebound_window else 0.10,
    }, unavailable)
    var next_edict := int(decision.get(
        "edict",
        TyrantCrownMetaAI.Edict.BALANCED
    ))
    var changed := next_edict != crown_edict
    crown_edict = next_edict
    crown_edict_left = (
        5.0
        if crown_edict == TyrantCrownMetaAI.Edict.BALANCED
        else GameTuning.CROWN_EDICT_DURATION
    )
    crown_select_cooldown = float(
        decision.get("reaction_delay", crown_ai.reaction_time())
    )
    crown_legacy.set_edict(crown_ai.edict_key(crown_edict))
    _announce_crown_edict(decision, changed)


func _announce_crown_edict(decision: Dictionary, changed: bool) -> void:
    var name := crown_ai.edict_name(crown_edict)
    if (
        crown_edict == TyrantCrownMetaAI.Edict.BALANCED
        or not changed
        or crown_announce_cooldown > 0.0
        or name == crown_last_announced_edict
    ):
        return
    crown_last_announced_edict = name
    crown_announce_cooldown = 2.6
    _set_event_feedback(
        "DRAX DECRETA: %s • %s" % [
            name,
            String(decision.get("counterplay", "leia a ordem da Coroa")),
        ],
        Color(1.0, 0.28, 0.24),
        2.2
    )


func _crown_edict_from_key(key: StringName) -> int:
    match key:
        &"iron_throne":
            return TyrantCrownMetaAI.Edict.IRON_THRONE
        &"night_hunt":
            return TyrantCrownMetaAI.Edict.NIGHT_HUNT
        &"written_fate":
            return TyrantCrownMetaAI.Edict.WRITTEN_FATE
        &"royal_command":
            return TyrantCrownMetaAI.Edict.ROYAL_COMMAND
        _:
            return TyrantCrownMetaAI.Edict.BALANCED


func _crown_defensive_target(
    defender: DinoPlayer,
    assignment: DinoPlayer,
    holder: DinoPlayer,
    contain: Vector3,
    toward_hoop: Vector3
) -> Vector3:
    var target := contain
    var protected_hoop := _defended_hoop(defender.team_id)
    var active_edict := crown_edict
    if crown_shattered_left > 0.0:
        active_edict = TyrantCrownMetaAI.Edict.BALANCED
    match active_edict:
        TyrantCrownMetaAI.Edict.IRON_THRONE:
            var paint_threat := holder if holder != null and assignment == holder else assignment
            target = paint_threat.global_position
            var paint_direction := protected_hoop - target
            paint_direction.y = 0.0
            if paint_direction.length() > 0.05:
                target += paint_direction.normalized() * GameTuning.CROWN_PAINT_GAP
        TyrantCrownMetaAI.Edict.NIGHT_HUNT:
            if holder != null and assignment == holder:
                target = holder.global_position
                var pressure_direction := _attack_hoop(holder.team_id) - target
                pressure_direction.y = 0.0
                if pressure_direction.length() > 0.05:
                    target += pressure_direction.normalized() * GameTuning.CROWN_PRESS_GAP
            elif holder != null:
                target = holder.global_position.lerp(assignment.global_position, 0.62)
                target.y = 0.0
        TyrantCrownMetaAI.Edict.WRITTEN_FATE:
            var forecast := sequence_model.predict_next()
            var predicted := StringName(forecast.get("action", &""))
            if bool(forecast.get("available", false)) and String(predicted).contains("pass") and holder != null and assignment != holder:
                target = holder.global_position.lerp(assignment.global_position, 0.58)
                target.y = 0.0
            elif predicted in [&"drive", &"post_move", &"finish"]:
                target = assignment.global_position.lerp(protected_hoop, 0.32)
                target.y = 0.0
            elif predicted == &"screen" and is_instance_valid(screen_ballhandler) and is_instance_valid(screen_screener):
                if assignment == screen_ballhandler:
                    target = screen_screener.global_position
                elif assignment == screen_screener:
                    target = screen_ballhandler.global_position
            elif predicted in [&"jump_shot", &"three_point_shot"]:
                target = assignment.global_position
                if toward_hoop.length() > 0.05:
                    target += toward_hoop.normalized() * 0.42
            elif toward_hoop.length() > 0.05:
                target += toward_hoop.normalized() * GameTuning.AI_CONTAIN_GAP
        TyrantCrownMetaAI.Edict.ROYAL_COMMAND:
            if is_instance_valid(screen_ballhandler) and is_instance_valid(screen_screener):
                if assignment == screen_ballhandler:
                    target = screen_screener.global_position
                elif assignment == screen_screener:
                    target = screen_ballhandler.global_position
            elif holder != null and assignment == holder:
                target = holder.global_position
                var command_direction := _attack_hoop(holder.team_id) - target
                command_direction.y = 0.0
                if command_direction.length() > 0.05:
                    target += command_direction.normalized() * GameTuning.CROWN_PRESS_GAP
            else:
                target = assignment.global_position.lerp(protected_hoop, 0.22)
                target.y = 0.0
        _:
            if toward_hoop.length() > 0.05:
                target += toward_hoop.normalized() * GameTuning.AI_CONTAIN_GAP
    target.x = clampf(target.x, -6.2, 6.2)
    target.z = clampf(target.z, -11.4, 11.4)
    return target


func _crown_offball_anchor(player: DinoPlayer) -> Vector3:
    var index := player.roster_index
    match crown_edict:
        TyrantCrownMetaAI.Edict.IRON_THRONE:
            if index == 2:
                return Vector3(-1.3, 0.0, 9.5)
            return Vector3(4.7 if index == 1 else -4.7, 0.0, 6.2)
        TyrantCrownMetaAI.Edict.NIGHT_HUNT:
            if index == 1:
                return Vector3(5.2, 0.0, 5.8)
            return Vector3(-5.2, 0.0, 6.8)
        TyrantCrownMetaAI.Edict.WRITTEN_FATE:
            if index == 1:
                return Vector3(4.4, 0.0, 6.0)
            return Vector3(-4.4, 0.0, 7.0)
        TyrantCrownMetaAI.Edict.ROYAL_COMMAND:
            if index == 1:
                return Vector3(2.5, 0.0, 8.7)
            return Vector3(-2.1, 0.0, 9.2)
        _:
            return _spacing_anchor(TEAM_AWAY, index)


func _update_apex_plan(holder: DinoPlayer, rebound_window: bool) -> void:
    if match_number != 9 or apex_plan_cooldown > 0.0:
        return

    var decision: Dictionary
    var plan_changed := false
    var plan_name := ""
    if possession_team == TEAM_HOME:
        var hoop := _attack_hoop(TEAM_HOME)
        var holder_distance := 9.0
        var holder_strength := 50.0
        if holder != null:
            holder_distance = _flat_distance(holder.global_position, hoop)
            holder_strength = float(holder.data.strength)
        var drive_threat := clampf(1.0 - holder_distance / 8.5, 0.0, 1.0)
        var post_threat := 0.0
        if holder_distance <= GameTuning.POST_MAX_DISTANCE + 1.0:
            post_threat = clampf((holder_strength - 45.0) / 55.0, 0.0, 1.0)
        var clock_pressure := clampf(
            1.0 - shot_clock_left / GameTuning.SHOT_CLOCK,
            0.0,
            1.0
        )
        decision = apex_ai.choose_defensive_plan({
            "screen_active": is_instance_valid(screen_screener),
            "drive_threat": drive_threat,
            "post_threat": post_threat,
            "ball_pressure": clock_pressure,
            "clock_pressure": clock_pressure,
            "rebound_priority": 1.0 if rebound_window else 0.12,
            "foul_risk": clampf(float(team_fouls[TEAM_AWAY]) / 6.0, 0.0, 1.0),
        })
        var next_defensive_plan := int(decision.get(
            "plan",
            ApexCoordinationAI.DefensivePlan.BALANCED
        ))
        plan_changed = next_defensive_plan != apex_defensive_plan
        apex_defensive_plan = next_defensive_plan
        plan_name = apex_ai.defensive_plan_name(apex_defensive_plan)
    else:
        var strength_edge := 0.5
        if holder != null:
            var marker := _closest_defender_to_player(holder)
            if marker != null:
                strength_edge = clampf(
                    0.5 + float(holder.data.strength - marker.data.strength) / 80.0,
                    0.0,
                    1.0
                )
        var apex_strength := 0.0
        var home_strength := 0.0
        for value in away_players:
            apex_strength += float((value as DinoPlayer).data.strength)
        for value in home_players:
            home_strength += float((value as DinoPlayer).data.strength)
        apex_strength /= maxf(1.0, float(away_players.size()))
        home_strength /= maxf(1.0, float(home_players.size()))
        var rebound_edge := clampf(
            0.5 + (apex_strength - home_strength) / 90.0,
            0.0,
            1.0
        )
        var paint_crowding := 0.0
        var attack_hoop := _attack_hoop(TEAM_AWAY)
        for value in home_players:
            var home_player := value as DinoPlayer
            if _flat_distance(home_player.global_position, attack_hoop) <= 4.8:
                paint_crowding += 1.0 / maxf(1.0, float(home_players.size()))
        decision = apex_ai.choose_offensive_plan({
            "screen_ready": screen_call_cooldown <= 0.0 and holder != null,
            "strength_edge": strength_edge,
            "rebound_edge": rebound_edge + (0.20 if rebound_window else 0.0),
            "paint_crowding": paint_crowding,
        })
        var next_offensive_plan := int(decision.get(
            "plan",
            ApexCoordinationAI.OffensivePlan.SPREAD
        ))
        plan_changed = next_offensive_plan != apex_offensive_plan
        apex_offensive_plan = next_offensive_plan
        plan_name = apex_ai.offensive_plan_name(apex_offensive_plan)

    var plan_pause := 0.45 if apex_roar_left > 0.0 else 0.85
    apex_plan_cooldown = float(
        decision.get("reaction_delay", apex_ai.reaction_time())
    ) + plan_pause
    _announce_apex_plan(plan_name, decision, plan_changed)


func _announce_apex_plan(
    plan_name: String,
    decision: Dictionary,
    plan_changed: bool
) -> void:
    if (
        not plan_changed
        or apex_plan_announce_cooldown > 0.0
        or plan_name == apex_last_announced_plan
    ):
        return
    apex_last_announced_plan = plan_name
    apex_plan_announce_cooldown = 2.8
    _set_event_feedback(
        "APEX: %s • %s" % [
            plan_name,
            String(decision.get("counterplay", "mantenha a compostura")),
        ],
        Color(1.0, 0.76, 0.22),
        1.9
    )


func _apex_defensive_target(
    defender: DinoPlayer,
    assignment: DinoPlayer,
    holder: DinoPlayer,
    contain: Vector3,
    toward_hoop: Vector3
) -> Vector3:
    var target := contain
    var protected_hoop := _defended_hoop(defender.team_id)
    match apex_defensive_plan:
        ApexCoordinationAI.DefensivePlan.PRESS_BALL:
            if holder != null and assignment == holder:
                target = holder.global_position
                var pressure_lane := _attack_hoop(holder.team_id) - target
                pressure_lane.y = 0.0
                if pressure_lane.length() > 0.05:
                    target += pressure_lane.normalized() * GameTuning.APEX_PRESS_GAP
            elif holder != null:
                target = assignment.global_position.lerp(holder.global_position, 0.18)
        ApexCoordinationAI.DefensivePlan.SWITCH_ALL:
            if is_instance_valid(screen_ballhandler) and is_instance_valid(screen_screener):
                if assignment == screen_ballhandler:
                    target = screen_screener.global_position
                elif assignment == screen_screener:
                    target = screen_ballhandler.global_position
                elif toward_hoop.length() > 0.05:
                    target += toward_hoop.normalized() * GameTuning.AI_CONTAIN_GAP
            elif toward_hoop.length() > 0.05:
                target += toward_hoop.normalized() * GameTuning.AI_CONTAIN_GAP
        ApexCoordinationAI.DefensivePlan.PACK_PAINT:
            var paint_threat := holder if holder != null and assignment == holder else assignment
            target = paint_threat.global_position
            var paint_direction := protected_hoop - target
            paint_direction.y = 0.0
            if paint_direction.length() > 0.05:
                target += paint_direction.normalized() * GameTuning.APEX_PACK_PAINT_GAP
        ApexCoordinationAI.DefensivePlan.CONTROL_GLASS:
            target = assignment.global_position.lerp(protected_hoop, 0.44)
            target.y = 0.0
        _:
            if toward_hoop.length() > 0.05:
                target += toward_hoop.normalized() * GameTuning.AI_CONTAIN_GAP
    target.x = clampf(target.x, -6.2, 6.2)
    target.z = clampf(target.z, -11.4, 11.4)
    return target


func _apex_offball_anchor(player: DinoPlayer) -> Vector3:
    var index := player.roster_index
    match apex_offensive_plan:
        ApexCoordinationAI.OffensivePlan.POWER_SCREEN:
            if index == 1:
                return Vector3(4.8, 0.0, 6.2)
            return Vector3(-2.4, 0.0, 8.4)
        ApexCoordinationAI.OffensivePlan.POST_HUB:
            if index == 2:
                return Vector3(-1.25, 0.0, 9.4)
            return Vector3(5.0 if index == 1 else -5.0, 0.0, 6.0)
        ApexCoordinationAI.OffensivePlan.CRASH_GLASS:
            if index == 1:
                return Vector3(2.6, 0.0, 8.7)
            return Vector3(-1.8, 0.0, 9.6)
        _:
            if index == 1:
                return Vector3(5.4, 0.0, 5.8)
            if index == 2:
                return Vector3(-5.2, 0.0, 6.8)
            return Vector3(0.0, 0.0, 4.4)


func _nightclaw_decision_for(
    defender: DinoPlayer,
    assignment: DinoPlayer,
    holder: DinoPlayer
) -> Dictionary:
    var id := defender.get_instance_id()
    if not nightclaw_actions.has(id):
        var initial_delay := nightclaw_ai.reaction_time()
        var initial_decision := {
            "action": NightclawUtilityAI.DefensiveAction.CONTAIN,
            "reaction_delay": initial_delay,
            "reason": "A defesa lê a formação antes de ajustar.",
            "counterplay": nightclaw_ai.counterplay_hint(
                NightclawUtilityAI.DefensiveAction.CONTAIN
            ),
        }
        nightclaw_actions[id] = initial_decision
        nightclaw_decision_cooldowns[id] = initial_delay
        return initial_decision
    if (
        float(nightclaw_decision_cooldowns.get(id, 0.0)) > 0.0
    ):
        return nightclaw_actions[id]

    var lane_risk := 0.0
    if holder != null and assignment != holder:
        var lane := PassingLaneAnalyzer.analyze(
            holder.global_position,
            assignment.global_position,
            [defender],
            holder.data.passing
        )
        lane_risk = float(lane.get("risk", 0.0))
    var ball_pressure_value := 0.0
    if holder != null:
        ball_pressure_value = 1.0 - clampf(
            defender.global_position.distance_to(holder.global_position) / 4.0,
            0.0,
            1.0
        )
        if assignment != holder:
            ball_pressure_value *= 0.35
    var context := {
        "pass_lane_risk": lane_risk,
        "ball_pressure_value": ball_pressure_value,
        "transition_threat": 1.0 if (
            transition_team == TEAM_HOME and transition_time_left > 0.0
        ) else 0.0,
        "help_available": _nightclaw_help_available(defender, holder),
        "foul_risk": clampf(float(team_fouls[TEAM_AWAY]) / 6.0, 0.0, 1.0),
    }
    var decision := nightclaw_ai.choose_defensive_action(context)
    nightclaw_actions[id] = decision
    nightclaw_decision_cooldowns[id] = float(
        decision.get("reaction_delay", nightclaw_ai.reaction_time())
    )
    _announce_nightclaw_adaptation(decision)
    return decision


func _nightclaw_help_available(defender: DinoPlayer, holder: DinoPlayer) -> bool:
    if holder == null:
        return false
    for teammate_value in away_players:
        var teammate := teammate_value as DinoPlayer
        if teammate == defender:
            continue
        if teammate.global_position.distance_to(holder.global_position) <= 2.7:
            return true
    return false


func _nightclaw_defensive_target(
    defender: DinoPlayer,
    assignment: DinoPlayer,
    holder: DinoPlayer,
    action: int,
    contain: Vector3,
    toward_hoop: Vector3
) -> Vector3:
    var target := contain
    match action:
        NightclawUtilityAI.DefensiveAction.DENY_LANE:
            if holder != null and assignment != holder:
                var lane := PassingLaneAnalyzer.distance_to_segment(
                    defender.global_position,
                    holder.global_position,
                    assignment.global_position
                )
                var closest_point: Vector3 = lane.get("closest", contain)
                target = closest_point
                var receiver_direction := assignment.global_position - target
                receiver_direction.y = 0.0
                if receiver_direction.length() > 0.05:
                    target += receiver_direction.normalized() * 0.25
            elif toward_hoop.length() > 0.01:
                target += toward_hoop.normalized() * GameTuning.NIGHT_CONTAIN_GAP
        NightclawUtilityAI.DefensiveAction.PRESSURE_BALL:
            if holder != null:
                target = holder.global_position
                var pressure_direction := _attack_hoop(holder.team_id) - target
                pressure_direction.y = 0.0
                if pressure_direction.length() > 0.05:
                    target += pressure_direction.normalized() * 0.55
        NightclawUtilityAI.DefensiveAction.TRAP:
            if holder != null:
                var side := -1.0 if defender.roster_index % 2 == 0 else 1.0
                target = holder.global_position + Vector3(side * 0.55, 0.0, 0.25)
        NightclawUtilityAI.DefensiveAction.RETREAT:
            var protected_hoop := _defended_hoop(defender.team_id)
            if holder != null:
                target = holder.global_position.lerp(protected_hoop, 0.58)
                target.y = 0.0
            else:
                target = Vector3(protected_hoop.x, 0.0, protected_hoop.z)
        _:
            if toward_hoop.length() > 0.01:
                target += toward_hoop.normalized() * GameTuning.NIGHT_CONTAIN_GAP
    target.x = clampf(target.x, -6.2, 6.2)
    target.z = clampf(target.z, -11.4, 11.4)
    return target


func _announce_nightclaw_adaptation(decision: Dictionary) -> void:
    if adaptation_announce_cooldown > 0.0:
        return
    var repeated := tendency_model.repeated_action()
    if repeated == &"" or repeated == last_announced_adaptation:
        return
    last_announced_adaptation = repeated
    adaptation_announce_cooldown = 5.0
    _set_event_feedback(
        "NIGHTCLAW LEU SEU PADRÃO • %s" % String(
            decision.get("counterplay", "mude o ritmo")
        ),
        Color(0.68, 0.56, 1.0),
        2.2
    )


func _fossil_decision_for(defender: DinoPlayer) -> Dictionary:
    var id := defender.get_instance_id()
    if not fossil_actions.has(id):
        var initial_delay := fossil_ai.reaction_time()
        var initial := {
            "scheme": FossilTechPredictiveAI.DefensiveScheme.BALANCED,
            "prediction": &"",
            "confidence": 0.0,
            "reaction_delay": initial_delay,
            "reason": "A Fossil Tech aguarda evidência antes de rotacionar.",
            "counterplay": fossil_ai.counterplay_hint(
                FossilTechPredictiveAI.DefensiveScheme.BALANCED
            ),
        }
        fossil_actions[id] = initial
        fossil_decision_cooldowns[id] = initial_delay
        return initial
    if float(fossil_decision_cooldowns.get(id, 0.0)) > 0.0:
        return fossil_actions[id]

    var decision := fossil_ai.choose_defensive_scheme(sequence_model.predict_next())
    fossil_actions[id] = decision
    fossil_decision_cooldowns[id] = float(
        decision.get("reaction_delay", fossil_ai.reaction_time())
    )
    _announce_fossil_prediction(decision)
    return decision


func _fossil_defensive_target(
    defender: DinoPlayer,
    assignment: DinoPlayer,
    holder: DinoPlayer,
    scheme: int,
    contain: Vector3,
    toward_hoop: Vector3
) -> Vector3:
    var target := contain
    match scheme:
        FossilTechPredictiveAI.DefensiveScheme.JUMP_PASS_LANE:
            if holder != null and assignment != holder:
                var lane := PassingLaneAnalyzer.distance_to_segment(
                    defender.global_position,
                    holder.global_position,
                    assignment.global_position
                )
                target = lane.get("closest", contain)
                var toward_receiver := assignment.global_position - target
                toward_receiver.y = 0.0
                if toward_receiver.length() > 0.05:
                    target += toward_receiver.normalized() * 0.32
            elif holder != null:
                target = holder.global_position
                var shade := _attack_hoop(holder.team_id) - holder.global_position
                shade.y = 0.0
                if shade.length() > 0.05:
                    target += shade.normalized() * 0.72
        FossilTechPredictiveAI.DefensiveScheme.WALL_PAINT:
            var protected_hoop := _defended_hoop(defender.team_id)
            var threat := holder if holder != null and assignment == holder else assignment
            target = threat.global_position.lerp(protected_hoop, 0.34)
            target.y = 0.0
        FossilTechPredictiveAI.DefensiveScheme.EARLY_CLOSEOUT:
            target = assignment.global_position
            if toward_hoop.length() > 0.05:
                target += toward_hoop.normalized() * 0.48
        FossilTechPredictiveAI.DefensiveScheme.SWITCH_SCREEN:
            if is_instance_valid(screen_ballhandler) and is_instance_valid(screen_screener):
                if assignment == screen_ballhandler:
                    target = screen_screener.global_position
                elif assignment == screen_screener:
                    target = screen_ballhandler.global_position
                elif toward_hoop.length() > 0.05:
                    target += toward_hoop.normalized() * GameTuning.FOSSIL_CONTAIN_GAP
            elif toward_hoop.length() > 0.05:
                target += toward_hoop.normalized() * GameTuning.FOSSIL_CONTAIN_GAP
        _:
            if toward_hoop.length() > 0.05:
                target += toward_hoop.normalized() * GameTuning.FOSSIL_CONTAIN_GAP
    target.x = clampf(target.x, -6.2, 6.2)
    target.z = clampf(target.z, -11.4, 11.4)
    return target


func _announce_fossil_prediction(decision: Dictionary) -> void:
    if fossil_announce_cooldown > 0.0 or fossil_model_broken_left > 0.0:
        return
    var predicted := StringName(decision.get("prediction", &""))
    if predicted == &"" or predicted == fossil_last_announced_prediction:
        return
    fossil_last_announced_prediction = predicted
    fossil_announce_cooldown = 4.0
    _set_event_feedback(
        "FOSSIL TECH PROJETA %s • %s" % [
            _tendency_label(predicted),
            String(decision.get("counterplay", "varie a sequência")),
        ],
        Color(0.30, 0.92, 0.78),
        2.2
    )

func _update_ai_ballhandler(player: DinoPlayer) -> void:
    if float(instinct_meter[player.team_id]) >= GameTuning.INSTINCT_MAX and not is_instinct_active(player.team_id):
        request_instinct(player)
    var hoop := _attack_hoop(player.team_id)
    var to_hoop := hoop - player.global_position
    to_hoop.y = 0.0
    var ember_attack := match_number == 3 and player.team_id == TEAM_AWAY
    var tide_attack := match_number == 4 and player.team_id == TEAM_AWAY
    var sky_attack := match_number == 5 and player.team_id == TEAM_AWAY
    var iron_attack := match_number == 6 and player.team_id == TEAM_AWAY
    var night_attack := match_number == 7 and player.team_id == TEAM_AWAY
    var fossil_attack := match_number == 8 and player.team_id == TEAM_AWAY
    var apex_attack := match_number == 9 and player.team_id == TEAM_AWAY
    var crown_attack := match_number == 10 and player.team_id == TEAM_AWAY
    var night_transition := (
        night_attack
        and transition_team == TEAM_AWAY
        and transition_time_left > 0.0
    )
    var drive_target := player.global_position
    if to_hoop.length() > 0.01:
        var drive_step := GameTuning.EMBER_DRIVE_STEP if ember_attack else 3.0
        if night_transition:
            drive_step = 4.2
        drive_target += to_hoop.normalized() * drive_step
    drive_target.x = clampf(drive_target.x, -5.2, 5.2)
    player.set_ai_target(
        drive_target,
        ember_attack or night_transition or to_hoop.length() > 7.0
    )

    var delay_min := GameTuning.AI_ACTION_MIN_DELAY
    var delay_max := GameTuning.AI_ACTION_MAX_DELAY
    if ember_attack:
        delay_min = GameTuning.EMBER_AI_MIN_DELAY
        delay_max = GameTuning.EMBER_AI_MAX_DELAY
    elif tide_attack:
        delay_min = GameTuning.TIDE_AI_MIN_DELAY
        delay_max = GameTuning.TIDE_AI_MAX_DELAY
    elif sky_attack:
        delay_min = GameTuning.SKY_AI_MIN_DELAY
        delay_max = GameTuning.SKY_AI_MAX_DELAY
    elif iron_attack:
        delay_min = GameTuning.IRON_AI_MIN_DELAY
        delay_max = GameTuning.IRON_AI_MAX_DELAY
    elif night_attack:
        delay_min = GameTuning.NIGHT_AI_MIN_DELAY
        delay_max = GameTuning.NIGHT_AI_MAX_DELAY
        if night_transition:
            delay_min *= 0.82
            delay_max *= 0.82
    elif fossil_attack:
        delay_min = GameTuning.FOSSIL_AI_MIN_DELAY
        delay_max = GameTuning.FOSSIL_AI_MAX_DELAY
    elif apex_attack:
        delay_min = GameTuning.APEX_AI_MIN_DELAY
        delay_max = GameTuning.APEX_AI_MAX_DELAY
    elif crown_attack:
        delay_min = GameTuning.CROWN_AI_MIN_DELAY
        delay_max = GameTuning.CROWN_AI_MAX_DELAY
    var ai_factor := _difficulty_ai_multiplier() if player.team_id == TEAM_AWAY else 1.0
    delay_min /= ai_factor
    delay_max /= ai_factor
    var id := player.get_instance_id()
    if not ai_action_cooldowns.has(id):
        ai_action_cooldowns[id] = rng.randf_range(delay_min, delay_max)
    if float(ai_action_cooldowns[id]) > 0.0:
        return

    var contest := _calculate_contest(player, hoop)
    var finish_limit := 0.82 if ember_attack else 0.70
    var shot_range := 8.2 if ember_attack else 7.6
    var shot_contest_limit := 0.72 if ember_attack else 0.62
    var sky_target := _best_lob_target(player) if sky_attack else null
    var sky_lob_ready := sky_attack and sky_target != null and _flat_distance(sky_target.global_position, hoop) <= GameTuning.ALLEY_TARGET_MAX_DISTANCE
    if crown_attack and _execute_crown_offense(player, to_hoop, contest):
        ai_action_cooldowns[id] = rng.randf_range(delay_min, delay_max)
        return
    if apex_attack and _execute_apex_offense(player, to_hoop, contest):
        ai_action_cooldowns[id] = rng.randf_range(delay_min, delay_max)
        return
    if fossil_attack:
        var fossil_receiver := _best_ai_pass_target(player)
        var finish_ev := -1.0
        if to_hoop.length() <= GameTuning.FINISH_MAX_DISTANCE:
            var finish_quality := clampf(
                0.52
                + float(player.data.shooting) * 0.0022
                + float(player.data.strength) * 0.0014
                - contest * 0.34,
                0.18,
                0.96
            )
            finish_ev = finish_quality * 2.0
        var shot_ev := -1.0
        if to_hoop.length() <= 8.0:
            var shot_value := 3.0 if to_hoop.length() >= GameTuning.THREE_POINT_DISTANCE else 2.0
            var range_penalty := maxf(0.0, to_hoop.length() - 4.0) * 0.025
            var shot_quality := clampf(
                0.30
                + float(player.data.shooting) * 0.0052
                - contest * 0.48
                - range_penalty,
                0.12,
                0.88
            )
            shot_ev = shot_quality * shot_value
        var pass_ev := -1.0
        if fossil_receiver != null:
            var progress_gain := maxf(
                0.0,
                to_hoop.length() - _flat_distance(fossil_receiver.global_position, hoop)
            )
            pass_ev = (
                0.48
                + _openness_score(fossil_receiver) * 0.46
                + progress_gain * 0.035
                + float(player.data.passing) * 0.0015
            )
        var fossil_choice := fossil_ai.choose_offensive_action({
            "finish_ev": finish_ev,
            "shot_ev": shot_ev,
            "pass_ev": pass_ev,
        })
        match StringName(fossil_choice.get("action", &"pass")):
            &"finish":
                request_finish(player)
            &"shot":
                var fossil_timing := clampf(
                    0.62 + float(player.data.shooting) / 260.0 + rng.randf_range(-0.06, 0.06),
                    0.50,
                    0.97
                )
                _release_shot(player, fossil_timing)
            _:
                if fossil_receiver != null:
                    _prepare_pass_context(player, fossil_receiver, false)
                    last_passer_by_team[player.team_id] = player
                    player.release_ball()
                    var fossil_pass_speed := lerpf(
                        GameTuning.PASS_SPEED,
                        GameTuning.STRONG_PASS_SPEED,
                        float(player.data.passing) / 100.0
                    )
                    ball.launch_pass(
                        fossil_receiver.global_position + Vector3.UP * 1.02,
                        fossil_receiver,
                        fossil_pass_speed,
                        player.team_id
                    )
                    feedback_label.text = "FOSSIL TECH ESCOLHE O MAIOR VALOR"
        ai_action_cooldowns[id] = rng.randf_range(delay_min, delay_max)
        return
    if night_transition:
        var transition_receiver := _best_transition_target(player)
        if transition_receiver != null:
            _prepare_pass_context(player, transition_receiver, false)
            last_passer_by_team[player.team_id] = player
            player.release_ball()
            ball.launch_pass(
                transition_receiver.global_position + Vector3.UP * 1.02,
                transition_receiver,
                GameTuning.STRONG_PASS_SPEED,
                player.team_id
            )
            feedback_label.text = "NIGHTCLAW ACELERA A TRANSIÇÃO"
            ai_action_cooldowns[id] = rng.randf_range(delay_min, delay_max)
            return
        if to_hoop.length() <= GameTuning.FINISH_MAX_DISTANCE:
            request_finish(player)
            ai_action_cooldowns[id] = rng.randf_range(delay_min, delay_max)
            return
    if iron_attack and screen_call_cooldown <= 0.0 and screen_screener == null and to_hoop.length() > 4.2 and rng.randf() <= 0.38:
        request_screen(player)
        ai_action_cooldowns[id] = rng.randf_range(delay_min, delay_max)
        return
    if iron_attack and to_hoop.length() <= GameTuning.POST_MAX_DISTANCE and contest >= 0.18 and rng.randf() <= GameTuning.IRON_POST_BIAS:
        request_post_move(player)
        ai_action_cooldowns[id] = rng.randf_range(delay_min, delay_max)
        return
    if sky_lob_ready and rng.randf() <= GameTuning.SKY_LOB_BIAS:
        request_lob(player)
    elif to_hoop.length() <= GameTuning.FINISH_MAX_DISTANCE and contest < finish_limit:
        request_finish(player)
    elif tide_attack and contest > 0.16:
        var tide_receiver := _best_ai_pass_target(player)
        if tide_receiver != null:
            _prepare_pass_context(player, tide_receiver, false)
            last_passer_by_team[player.team_id] = player
            player.release_ball()
            ball.launch_pass(tide_receiver.global_position + Vector3.UP * 1.02, tide_receiver, GameTuning.STRONG_PASS_SPEED * GameTuning.TIDE_PASS_BONUS, player.team_id)
            feedback_label.text = "TIDEFANG INVERTE O LADO"
    elif to_hoop.length() <= shot_range and contest < shot_contest_limit:
        var base_timing := clampf(0.62 + float(player.data.shooting) / 260.0 + rng.randf_range(-0.08, 0.08), 0.48, 0.96)
        _release_shot(player, base_timing)
    else:
        var receiver := _best_ai_pass_target(player)
        if receiver != null:
            _prepare_pass_context(player, receiver, false)
            last_passer_by_team[player.team_id] = player
            player.release_ball()
            var pass_speed := lerpf(GameTuning.PASS_SPEED, GameTuning.STRONG_PASS_SPEED, float(player.data.passing) / 100.0)
            ball.launch_pass(receiver.global_position + Vector3.UP * 1.02, receiver, pass_speed, player.team_id)
            feedback_label.text = "%s movimenta a bola" % _team_name(player.team_id)

    ai_action_cooldowns[id] = rng.randf_range(delay_min, delay_max)


func _execute_apex_offense(
    player: DinoPlayer,
    to_hoop: Vector3,
    contest: float
) -> bool:
    if (
        apex_offensive_plan == ApexCoordinationAI.OffensivePlan.POWER_SCREEN
        and screen_call_cooldown <= 0.0
        and not is_instance_valid(screen_screener)
        and to_hoop.length() > 4.2
    ):
        request_screen(player)
        return true

    if (
        apex_offensive_plan == ApexCoordinationAI.OffensivePlan.POST_HUB
        and to_hoop.length() <= GameTuning.POST_MAX_DISTANCE
        and contest >= 0.12
    ):
        request_post_move(player)
        return true

    if (
        apex_offensive_plan == ApexCoordinationAI.OffensivePlan.CRASH_GLASS
        and to_hoop.length() <= GameTuning.FINISH_MAX_DISTANCE
        and contest < 0.76
    ):
        request_finish(player)
        return true

    var receiver := _best_ai_pass_target(player)
    if (
        apex_offensive_plan == ApexCoordinationAI.OffensivePlan.SPREAD
        and to_hoop.length() <= 7.8
        and contest < 0.42
    ):
        var spread_timing := clampf(
            0.62 + float(player.data.shooting) / 260.0 + rng.randf_range(-0.08, 0.08),
            0.48,
            0.96
        )
        _release_shot(player, spread_timing)
        return true

    if to_hoop.length() <= GameTuning.FINISH_MAX_DISTANCE and contest < 0.68:
        request_finish(player)
        return true
    if receiver != null and contest >= 0.34:
        _apex_pass_to(player, receiver)
        return true
    if to_hoop.length() <= 7.8 and contest < 0.62:
        var timing := clampf(
            0.62 + float(player.data.shooting) / 260.0 + rng.randf_range(-0.08, 0.08),
            0.48,
            0.96
        )
        _release_shot(player, timing)
        return true
    if receiver != null:
        _apex_pass_to(player, receiver)
        return true
    return false


func _apex_pass_to(passer: DinoPlayer, receiver: DinoPlayer) -> void:
    _prepare_pass_context(passer, receiver, false)
    last_passer_by_team[passer.team_id] = passer
    passer.release_ball()
    var pass_speed := lerpf(
        GameTuning.PASS_SPEED,
        GameTuning.STRONG_PASS_SPEED,
        float(passer.data.passing) / 100.0
    )
    ball.launch_pass(
        receiver.global_position + Vector3.UP * 1.02,
        receiver,
        pass_speed,
        passer.team_id
    )
    feedback_label.text = "APEX EXECUTA %s" % apex_ai.offensive_plan_name(
        apex_offensive_plan
    )


func _execute_crown_offense(
    player: DinoPlayer,
    to_hoop: Vector3,
    contest: float
) -> bool:
    if crown_shattered_left > 0.0:
        return false

    var receiver := _best_ai_pass_target(player)
    match crown_edict:
        TyrantCrownMetaAI.Edict.IRON_THRONE:
            if (
                screen_call_cooldown <= 0.0
                and not is_instance_valid(screen_screener)
                and to_hoop.length() > 4.2
            ):
                request_screen(player)
                return true
            if to_hoop.length() <= GameTuning.POST_MAX_DISTANCE and contest >= 0.12:
                request_post_move(player)
                return true
            if to_hoop.length() <= GameTuning.FINISH_MAX_DISTANCE and contest < 0.76:
                request_finish(player)
                return true
        TyrantCrownMetaAI.Edict.NIGHT_HUNT:
            var transition_receiver := _best_transition_target(player)
            if transition_receiver != null:
                _crown_pass_to(player, transition_receiver)
                return true
            if receiver != null and (contest >= 0.26 or _openness_score(receiver) >= 0.58):
                _crown_pass_to(player, receiver)
                return true
            if to_hoop.length() <= GameTuning.FINISH_MAX_DISTANCE and contest < 0.70:
                request_finish(player)
                return true
        TyrantCrownMetaAI.Edict.WRITTEN_FATE:
            var finish_ev := -1.0
            if to_hoop.length() <= GameTuning.FINISH_MAX_DISTANCE:
                finish_ev = clampf(
                    0.52
                    + float(player.data.shooting) * 0.0022
                    + float(player.data.strength) * 0.0014
                    - contest * 0.34,
                    0.18,
                    0.96
                ) * 2.0
            var shot_ev := -1.0
            if to_hoop.length() <= 8.0:
                var shot_value := 3.0 if to_hoop.length() >= GameTuning.THREE_POINT_DISTANCE else 2.0
                var range_penalty := maxf(0.0, to_hoop.length() - 4.0) * 0.025
                shot_ev = clampf(
                    0.30
                    + float(player.data.shooting) * 0.0052
                    - contest * 0.48
                    - range_penalty,
                    0.12,
                    0.88
                ) * shot_value
            var pass_ev := -1.0
            if receiver != null:
                pass_ev = (
                    0.48
                    + _openness_score(receiver) * 0.46
                    + float(player.data.passing) * 0.0015
                )
            var choice := fossil_ai.choose_offensive_action({
                "finish_ev": finish_ev,
                "shot_ev": shot_ev,
                "pass_ev": pass_ev,
            })
            match StringName(choice.get("action", &"pass")):
                &"finish":
                    request_finish(player)
                    return true
                &"shot":
                    var timing := clampf(
                        0.62
                        + float(player.data.shooting) / 260.0
                        + rng.randf_range(-0.06, 0.06),
                        0.50,
                        0.97
                    )
                    _release_shot(player, timing)
                    return true
                _:
                    if receiver != null:
                        _crown_pass_to(player, receiver)
                        return true
        TyrantCrownMetaAI.Edict.ROYAL_COMMAND:
            if (
                screen_call_cooldown <= 0.0
                and not is_instance_valid(screen_screener)
                and to_hoop.length() > 4.0
            ):
                request_screen(player)
                return true
            if receiver != null and contest >= 0.30:
                _crown_pass_to(player, receiver)
                return true
            if to_hoop.length() <= GameTuning.FINISH_MAX_DISTANCE and contest < 0.72:
                request_finish(player)
                return true
        _:
            return false

    if receiver != null:
        _crown_pass_to(player, receiver)
        return true
    return false


func _crown_pass_to(passer: DinoPlayer, receiver: DinoPlayer) -> void:
    _prepare_pass_context(passer, receiver, false)
    last_passer_by_team[passer.team_id] = passer
    passer.release_ball()
    var pass_speed := lerpf(
        GameTuning.PASS_SPEED,
        GameTuning.STRONG_PASS_SPEED,
        float(passer.data.passing) / 100.0
    )
    ball.launch_pass(
        receiver.global_position + Vector3.UP * 1.02,
        receiver,
        pass_speed,
        passer.team_id
    )
    feedback_label.text = "A COROA EXECUTA %s" % crown_ai.edict_name(crown_edict)


func _best_transition_target(passer: DinoPlayer) -> DinoPlayer:
    var hoop := _attack_hoop(passer.team_id)
    var passer_distance := _flat_distance(passer.global_position, hoop)
    var best: DinoPlayer = null
    var best_distance := passer_distance - 1.25
    for candidate_value in _team_players(passer.team_id):
        var candidate := candidate_value as DinoPlayer
        if candidate == passer:
            continue
        var distance := _flat_distance(candidate.global_position, hoop)
        if distance < best_distance and _openness_score(candidate) >= 0.35:
            best_distance = distance
            best = candidate
    return best

func _best_ai_pass_target(passer: DinoPlayer) -> DinoPlayer:
    var best: DinoPlayer = null
    var best_score := -1000.0
    for candidate in _team_players(passer.team_id):
        if candidate == passer:
            continue
        var score := _openness_score(candidate) * 2.0
        score -= passer.global_position.distance_to(candidate.global_position) * 0.04
        score -= candidate.global_position.distance_to(_attack_hoop(candidate.team_id)) * 0.015
        if score > best_score:
            best_score = score
            best = candidate
    return best

func _spacing_anchor(team: int, index: int) -> Vector3:
    var anchor := Vector3.ZERO
    if team == TEAM_HOME:
        if index == 0:
            anchor = Vector3(0.0, 0.0, -4.2)
        elif index == 1:
            anchor = Vector3(-4.4, 0.0, -5.8)
        else:
            anchor = Vector3(4.2, 0.0, -7.2)
    else:
        if index == 0:
            anchor = Vector3(0.0, 0.0, 4.2)
        elif index == 1:
            anchor = Vector3(4.4, 0.0, 5.8)
        else:
            anchor = Vector3(-4.2, 0.0, 7.2)

    # Playbook da Vale Fóssil. A jogada muda apenas os alvos dos jogadores sem bola.
    if team == TEAM_HOME:
        var play := _current_play_call()
        if play == "ABRIR QUADRA":
            if index == 1:
                anchor = Vector3(-5.6, 0.0, -6.2)
            elif index == 2:
                anchor = Vector3(5.6, 0.0, -6.2)
        elif play == "BACKDOOR" and index == 1:
            var cut_phase := (sin(float(Time.get_ticks_msec()) / 520.0) + 1.0) * 0.5
            anchor = Vector3(-4.6, 0.0, lerpf(-5.2, -10.2, cut_phase))

    # Ember Ridge identity: alas atacam mais fundo e a equipe mantém pressão constante.
    if match_number == 3 and team == TEAM_AWAY:
        var ember_phase := float(Time.get_ticks_msec()) / 1000.0 + float(index) * 1.7
        if index > 0:
            anchor.z += 1.15
            anchor.x += sin(ember_phase * 1.4) * 0.65

    # Canopy Institute identity: off-ball players keep exchanging lanes.
    if match_number == 2 and team == TEAM_AWAY:
        var phase := float(Time.get_ticks_msec()) / 1000.0 + float(index) * 2.1
        anchor.x += sin(phase * 1.15) * 1.35
        anchor.z += cos(phase * 0.82) * 0.65

    # Tidefang identity: players alternate weak side positions, teaching defensive rotation.
    if match_number == 4 and team == TEAM_AWAY:
        var tide_phase := floor(float(Time.get_ticks_msec()) / (GameTuning.TIDE_WEAKSIDE_SWING_SECONDS * 1000.0))
        var side := -1.0 if int(tide_phase + index) % 2 == 0 else 1.0
        if index == 1:
            anchor.x = 5.1 * side
            anchor.z = 6.0
        elif index == 2:
            anchor.x = -4.7 * side
            anchor.z = 7.4

    # Skycrest identity: cutters attack the vertical lane in waves, creating lob windows.
    if match_number == 5 and team == TEAM_AWAY:
        var sky_phase := float(Time.get_ticks_msec()) / 1000.0
        if index == 1:
            anchor.x = sin(sky_phase * 1.35) * 3.8
            anchor.z = lerpf(5.4, 10.3, (sin(sky_phase * 1.9) + 1.0) * 0.5)
        elif index == 2:
            anchor.x = cos(sky_phase * 1.15) * 2.2
            anchor.z = lerpf(6.2, 10.8, (cos(sky_phase * 1.55) + 1.0) * 0.5)

    # Ironhorn identity: compact spacing around the paint to create screens, seals and post entries.
    if match_number == 6 and team == TEAM_AWAY:
        if index == 1:
            anchor = Vector3(3.0, 0.0, 7.2)
        elif index == 2:
            anchor = Vector3(-2.0, 0.0, 9.1)

    # Nightclaw converts turnovers into three lanes and otherwise keeps passing lanes open.
    if match_number == 7 and team == TEAM_AWAY:
        if transition_team == TEAM_AWAY and transition_time_left > 0.0:
            if index == 1:
                anchor = Vector3(4.8, 0.0, 9.4)
            elif index == 2:
                anchor = Vector3(-4.6, 0.0, 8.6)
        elif index == 1:
            anchor = Vector3(5.2, 0.0, 5.8)
        elif index == 2:
            anchor = Vector3(-4.2, 0.0, 7.5)
    return anchor

func _calculate_contest(shooter: DinoPlayer, target_hoop: Vector3) -> float:
    var opponents := _team_players(1 - shooter.team_id)
    var nearest: DinoPlayer = null
    var nearest_distance := 999.0
    for defender in opponents:
        var distance := shooter.global_position.distance_to(defender.global_position)
        if distance < nearest_distance:
            nearest_distance = distance
            nearest = defender
    if nearest == null:
        return 0.0

    var hoop_dir := target_hoop - shooter.global_position
    hoop_dir.y = 0.0
    var defender_dir := nearest.global_position - shooter.global_position
    defender_dir.y = 0.0
    var in_front := false
    if hoop_dir.length() > 0.01 and defender_dir.length() > 0.01:
        in_front = hoop_dir.normalized().dot(defender_dir.normalized()) > 0.15

    if nearest_distance <= GameTuning.CONTEST_HEAVY_DISTANCE:
        return 0.88 if in_front else 0.68
    if nearest_distance <= GameTuning.CONTEST_MEDIUM_DISTANCE:
        return 0.58 if in_front else 0.42
    if nearest_distance <= GameTuning.CONTEST_LIGHT_DISTANCE:
        return 0.28 if in_front else 0.16
    return 0.0

func _contest_label(contest: float) -> String:
    if contest >= 0.70:
        return "MUITO CONTESTADO"
    if contest >= 0.45:
        return "CONTESTADO"
    if contest >= 0.18:
        return "PRESSÃO LEVE"
    return "ABERTO"

func _openness_score(player: DinoPlayer) -> float:
    var opponents := _team_players(1 - player.team_id)
    var nearest := 99.0
    for defender in opponents:
        nearest = minf(nearest, player.global_position.distance_to(defender.global_position))
    return clampf(nearest / 3.0, 0.0, 1.5)


func _register_turnover(
    responsible_player: DinoPlayer,
    reason: String,
    recovery_team: int
) -> void:
    var turnover_team := ball.last_touch_team
    if is_instance_valid(responsible_player):
        turnover_team = responsible_player.team_id
        _stat_inc(responsible_player, "turnovers", 1)
    if turnover_team not in [TEAM_HOME, TEAM_AWAY]:
        turnover_team = 1 - recovery_team
    turnovers[turnover_team] = int(turnovers.get(turnover_team, 0)) + 1
    turnover_happened_this_possession = true
    transition_team = recovery_team
    transition_time_left = GameTuning.TURNOVER_TRANSITION_SECONDS
    if match_number == 7 and turnover_team == TEAM_HOME:
        tendency_model.observe(&"turnover", false, 0.5)
        match_director.observe_event(&"turnover")
    _set_event_feedback(
        "%s • TRANSIÇÃO %s" % [reason, _team_name(recovery_team)],
        Color(0.72, 0.58, 1.0),
        1.0
    )
    if match_number == 9:
        if turnover_team == TEAM_HOME:
            _resolve_composure_event(composure_tracker.punish_turnover())
            _gain_apex_roar(
                GameTuning.APEX_FORCED_TURNOVER_GAIN,
                "erro forçado da Vale"
            )
        elif recovery_team == TEAM_HOME:
            _resolve_composure_event(composure_tracker.reward_defensive_stop())


func _gain_nightclaw_takeover(amount: float) -> void:
    if match_number != 7 or nightclaw_takeover_left > 0.0:
        return
    nightclaw_takeover_meter = clampf(
        nightclaw_takeover_meter + amount,
        0.0,
        GameTuning.NIGHT_TAKEOVER_MAX
    )
    if nightclaw_takeover_meter >= GameTuning.NIGHT_TAKEOVER_MAX:
        nightclaw_takeover_meter = 0.0
        nightclaw_takeover_left = GameTuning.NIGHT_TAKEOVER_DURATION
        nightclaw_ai.takeover_active = true
        _set_event_feedback(
            "◈ ECLIPSE DEFENSIVO ◈ • a Nightclaw fechou as linhas",
            Color(0.62, 0.46, 1.0),
            1.5
        )

func _give_ball_to(player: DinoPlayer, reason: String) -> void:
    if player == null:
        return
    var previous_possession := possession_team
    var shot_team_before := last_shot_team
    if is_instance_valid(ball.holder) and ball.holder is DinoPlayer:
        (ball.holder as DinoPlayer).release_ball()
    player.take_ball()
    possession_team = player.team_id
    if player.team_id != previous_possession:
        last_passer_by_team[player.team_id] = null
        if match_number == 9:
            composure_tracker.begin_possession()

    if not training_mode:
        if reason.begins_with("REBOTE") and player.team_id == last_shot_team:
            shot_clock_left = minf(GameTuning.OFFENSIVE_REBOUND_CLOCK, GameTuning.SHOT_CLOCK)
        elif player.team_id != previous_possession:
            shot_clock_left = GameTuning.SHOT_CLOCK
    if reason.begins_with("REBOTE"):
        _stat_inc(player, "rebounds", 1)
        last_passer_by_team[player.team_id] = null
        last_shot_team = -1
        var rebound_gain := GameTuning.INSTINCT_REBOUND_GAIN
        if player.data.instinct_name == "Muralha Fóssil":
            rebound_gain += 4.0
        _gain_instinct(player.team_id, rebound_gain)

    feedback_label.text = "%s • %s" % [reason, player.data.display_name]
    if match_number == 9 and reason.begins_with("REBOTE"):
        if player.team_id == TEAM_AWAY and shot_team_before == TEAM_AWAY:
            _gain_apex_roar(
                GameTuning.APEX_OFFENSIVE_REBOUND_GAIN,
                "segunda chance conquistada"
            )
        elif player.team_id == TEAM_HOME and shot_team_before == TEAM_AWAY:
            _resolve_composure_event(composure_tracker.reward_defensive_stop())
    if (
        match_number == 10
        and player.team_id == TEAM_HOME
        and reason in ["RECEPÇÃO", "PASSE ALTO"]
    ):
        _resolve_crown_legacy(crown_legacy.observe_completed_pass())
    if player.team_id == TEAM_HOME:
        _select_controlled(player)
    var id := player.get_instance_id()
    ai_action_cooldowns[id] = rng.randf_range(GameTuning.AI_ACTION_MIN_DELAY, GameTuning.AI_ACTION_MAX_DELAY)

func _nearest_player_to_ball(max_distance: float) -> DinoPlayer:
    var result: DinoPlayer = null
    var best_score := 999.0
    for player in all_players:
        var radius := max_distance
        if player.data != null and player.data.instinct_name == "Muralha Fóssil":
            radius += 0.22
        var distance := player.global_position.distance_to(ball.global_position)
        if distance <= radius:
            var normalized_distance := distance / maxf(0.01, radius)
            if player.boxing_out:
                normalized_distance -= 0.16
            if match_number == 6 and player.team_id == TEAM_AWAY:
                normalized_distance -= 0.08
            var opponent := _closest_defender_to_player(player)
            if opponent != null and opponent.boxing_out and player.global_position.distance_to(opponent.global_position) <= GameTuning.BOX_OUT_CONTACT_RADIUS:
                normalized_distance += 0.12
            if normalized_distance < best_score:
                best_score = normalized_distance
                result = player
    return result

func _closest_opponent_to_ball(team: int, max_distance: float) -> DinoPlayer:
    if team < 0:
        return null
    var result: DinoPlayer = null
    var best := max_distance
    for player in _team_players(1 - team):
        var distance := player.global_position.distance_to(ball.global_position)
        if distance <= best:
            best = distance
            result = player
    return result

func _cycle_controlled_player() -> void:
    if home_players.is_empty() or not is_gameplay_live():
        return
    controlled_home_index = (controlled_home_index + 1) % home_players.size()
    _select_controlled(home_players[controlled_home_index])
    if tutorial_enabled:
        tutorial_flags["switch"] = true
        _refresh_tutorial()
    feedback_label.text = "CONTROLE → %s" % controlled_player.data.display_name

func _select_controlled(player: DinoPlayer) -> void:
    if player == null:
        return
    for home_player in home_players:
        home_player.set_controlled(home_player == player)
    controlled_player = player
    controlled_home_index = player.roster_index

func _start_possession(team: int, new_clock: float = GameTuning.SHOT_CLOCK) -> void:
    if possession_count > 0 and match_number == 7:
        tendency_model.finish_possession()
        if not turnover_happened_this_possession:
            match_director.observe_event(&"safe_possession")
        match_director.observe_event(&"possession_end")
    if possession_count > 0 and match_number == 8:
        sequence_model.finish_possession()
    elif possession_count == 0 and match_number == 8:
        sequence_model.begin_possession()
    if match_number == 9:
        composure_tracker.begin_possession()
        apex_defensive_plan = ApexCoordinationAI.DefensivePlan.BALANCED
        apex_offensive_plan = ApexCoordinationAI.OffensivePlan.SPREAD
        apex_plan_cooldown = apex_ai.reaction_time()
    if possession_count > 0 and match_number == 10:
        tendency_model.finish_possession()
        sequence_model.finish_possession()
    elif possession_count == 0 and match_number == 10:
        sequence_model.begin_possession()
        crown_select_cooldown = crown_ai.reaction_time()
    if match_number == 10:
        crown_legacy.begin_possession()
    possession_count += 1
    turnover_happened_this_possession = false
    home_protection_observed_this_possession = false
    _clear_screen_state()
    possession_team = team
    last_passer_by_team[team] = null
    home_cut_player = null
    home_cut_time_left = 0.0
    basket_locked = false
    dead_ball = false
    last_shot_team = -1
    last_passer = null
    last_pass_lane_risk = 0.0
    ai_action_cooldowns.clear()
    nightclaw_actions.clear()
    nightclaw_decision_cooldowns.clear()
    fossil_actions.clear()
    fossil_decision_cooldowns.clear()
    pass_fake_player = null
    pass_fake_time_left = 0.0
    pass_fake_safety_available = false
    fake_defender_targets.clear()
    if not training_mode:
        shot_clock_left = new_clock

    var home_positions := [Vector3(0, 0, 7.2), Vector3(-4.0, 0, 4.8), Vector3(4.0, 0, 4.0)]
    var away_positions := [Vector3(0, 0, -7.2), Vector3(4.0, 0, -4.8), Vector3(-4.0, 0, -4.0)]

    if team == TEAM_AWAY:
        home_positions = [Vector3(0, 0, 3.2), Vector3(-4.0, 0, 5.0), Vector3(4.0, 0, 4.2)]
        away_positions = [Vector3(0, 0, -7.2), Vector3(4.0, 0, -4.8), Vector3(-4.0, 0, -4.0)]

    for i in range(home_players.size()):
        home_players[i].global_position = home_positions[i]
        home_players[i].velocity = Vector3.ZERO
        home_players[i].release_ball()
    for i in range(away_players.size()):
        away_players[i].global_position = away_positions[i]
        away_players[i].velocity = Vector3.ZERO
        away_players[i].release_ball()

    ball.freeze = true
    ball.linear_velocity = Vector3.ZERO
    ball.angular_velocity = Vector3.ZERO

    var handler := _team_players(team)[0] as DinoPlayer
    handler.take_ball()
    if team == TEAM_HOME:
        _select_controlled(handler)
    else:
        _select_controlled(_closest_home_defender_to(handler))
    feedback_label.text = "POSSE %s" % _team_name(team)

func _closest_home_defender_to(target: DinoPlayer) -> DinoPlayer:
    var best := home_players[0] as DinoPlayer
    var best_distance := 999.0
    for player in home_players:
        var distance := player.global_position.distance_to(target.global_position)
        if distance < best_distance:
            best_distance = distance
            best = player
    return best

func _closest_defender_to_player(player: DinoPlayer) -> DinoPlayer:
    if player == null:
        return null
    var best: DinoPlayer = null
    var best_distance := 999.0
    for value in _team_players(1 - player.team_id):
        var defender := value as DinoPlayer
        var distance := player.global_position.distance_to(defender.global_position)
        if distance < best_distance:
            best_distance = distance
            best = defender
    return best

func _register_foul(player: DinoPlayer, label_text: String) -> void:
    if player == null:
        return
    team_fouls[player.team_id] = int(team_fouls.get(player.team_id, 0)) + 1
    _stat_inc(player, "fouls", 1)
    _set_event_feedback("APITO • %s • %s" % [label_text, player.data.display_name], Color(1.0, 0.76, 0.32), 0.9)

func _call_nonshooting_foul(defender: DinoPlayer, offense_player: DinoPlayer, label_text: String) -> void:
    if defender == null or offense_player == null or match_state != MatchState.LIVE:
        return
    _register_foul(defender, label_text)
    dead_ball = true
    if is_instance_valid(ball.holder) and ball.holder is DinoPlayer:
        (ball.holder as DinoPlayer).release_ball()
    ball.make_loose()
    ball.freeze = true
    await get_tree().create_timer(GameTuning.FREE_THROW_DEAD_BALL_DELAY).timeout
    if is_inside_tree() and match_state == MatchState.LIVE:
        _start_possession(offense_player.team_id, minf(GameTuning.OFFENSIVE_REBOUND_CLOCK, maxf(shot_clock_left, 8.0)))

func _call_offensive_foul(attacker: DinoPlayer, label_text: String) -> void:
    if attacker == null or match_state != MatchState.LIVE:
        return
    _register_foul(attacker, label_text)
    dead_ball = true
    var next_team := 1 - attacker.team_id
    _register_turnover(attacker, "FALTA DE ATAQUE", next_team)
    attacker.release_ball()
    ball.make_loose()
    ball.freeze = true
    await get_tree().create_timer(GameTuning.FREE_THROW_DEAD_BALL_DELAY).timeout
    if is_inside_tree() and match_state == MatchState.LIVE:
        _start_possession(next_team)

func _start_free_throws(shooter: DinoPlayer, attempts: int, defender: DinoPlayer, reason: String) -> void:
    if shooter == null or attempts <= 0 or match_state != MatchState.LIVE:
        return
    if defender != null:
        _register_foul(defender, reason)
    _clear_screen_state()
    dead_ball = true
    match_state = MatchState.FREE_THROW
    free_throw_shooter = shooter
    free_throw_attempts_total = attempts
    free_throw_attempts_left = attempts
    free_throw_made = 0
    free_throw_hold_started_at = -1
    free_throw_ai_timer = 0.0
    free_throw_between_timer = 0.0
    free_throw_waiting_result = false
    possession_team = shooter.team_id

    if is_instance_valid(ball.holder) and ball.holder is DinoPlayer:
        (ball.holder as DinoPlayer).release_ball()
    ball.make_loose()
    ball.freeze = true

    var hoop := _attack_hoop(shooter.team_id)
    var hoop_floor := Vector3(hoop.x, 0.0, hoop.z)
    var direction := (Vector3.ZERO - hoop_floor).normalized()
    shooter.global_position = hoop_floor + direction * 4.55
    shooter.velocity = Vector3.ZERO
    shooter.take_ball()
    if shooter.team_id == TEAM_HOME:
        _select_controlled(shooter)
    else:
        _select_controlled(_closest_home_defender_to(shooter))
    _build_free_throw_overlay(reason)
    _refresh_free_throw_overlay()

func _build_free_throw_overlay(reason: String) -> void:
    if is_instance_valid(free_throw_layer):
        free_throw_layer.queue_free()
    free_throw_layer = CanvasLayer.new()
    free_throw_layer.layer = 18
    add_child(free_throw_layer)

    var shade := ColorRect.new()
    shade.color = Color(0.01, 0.015, 0.025, 0.64)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    free_throw_layer.add_child(shade)

    var panel := PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.position = Vector2(-285, -120)
    panel.size = Vector2(570, 240)
    free_throw_layer.add_child(panel)

    var box := VBoxContainer.new()
    box.alignment = BoxContainer.ALIGNMENT_CENTER
    box.add_theme_constant_override("separation", 12)
    panel.add_child(box)

    var title := Label.new()
    title.text = "LANCES LIVRES • %s" % reason
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 28)
    title.modulate = Color(1.0, 0.78, 0.32)
    box.add_child(title)

    free_throw_label = Label.new()
    free_throw_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    free_throw_label.add_theme_font_size_override("font_size", 24)
    box.add_child(free_throw_label)

    free_throw_detail_label = Label.new()
    free_throw_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    free_throw_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    free_throw_detail_label.custom_minimum_size = Vector2(520, 64)
    box.add_child(free_throw_detail_label)

func _refresh_free_throw_overlay() -> void:
    if not is_instance_valid(free_throw_label) or free_throw_shooter == null:
        return
    if is_instance_valid(free_throw_detail_label):
        free_throw_detail_label.modulate = Color.WHITE
    var attempt_number := free_throw_attempts_total - free_throw_attempts_left + 1
    attempt_number = clampi(attempt_number, 1, free_throw_attempts_total)
    free_throw_label.text = "%s • LANCE %d/%d" % [free_throw_shooter.data.display_name, attempt_number, free_throw_attempts_total]
    if free_throw_shooter.team_id == TEAM_HOME:
        free_throw_detail_label.text = "Segure J e solte perto de %.2fs. Green: ±%d ms." % [GameTuning.FREE_THROW_IDEAL_HOLD, roundi(GameTuning.FREE_THROW_GREEN_WINDOW * 1000.0)]
    else:
        free_throw_detail_label.text = "%s se prepara na linha..." % away_team_name

func _process_free_throw(delta: float) -> void:
    if free_throw_shooter == null:
        _end_free_throw_sequence()
        return
    if free_throw_waiting_result:
        free_throw_between_timer = maxf(0.0, free_throw_between_timer - delta)
        if free_throw_between_timer <= 0.0:
            free_throw_waiting_result = false
            if free_throw_attempts_left <= 0:
                _end_free_throw_sequence()
            else:
                free_throw_ai_timer = 0.0
                free_throw_hold_started_at = -1
                _refresh_free_throw_overlay()
        return

    if free_throw_shooter.team_id == TEAM_HOME:
        if Input.is_action_just_pressed("shoot"):
            free_throw_hold_started_at = Time.get_ticks_msec()
        if free_throw_hold_started_at >= 0 and Input.is_action_just_released("shoot"):
            var held := float(Time.get_ticks_msec() - free_throw_hold_started_at) / 1000.0
            free_throw_hold_started_at = -1
            _resolve_free_throw(held)
    else:
        free_throw_ai_timer += delta
        if free_throw_ai_timer >= GameTuning.FREE_THROW_AI_DELAY:
            var skill_center := GameTuning.FREE_THROW_IDEAL_HOLD
            var spread := lerpf(0.115, 0.035, float(free_throw_shooter.data.shooting) / 100.0)
            _resolve_free_throw(skill_center + rng.randf_range(-spread, spread))

func _resolve_free_throw(held_seconds: float) -> void:
    if free_throw_shooter == null or free_throw_attempts_left <= 0:
        return
    var timing_error := absf(held_seconds - GameTuning.FREE_THROW_IDEAL_HOLD)
    var timing_quality := clampf(1.0 - timing_error / GameTuning.FREE_THROW_TIMING_RANGE, 0.0, 1.0)
    var skill := float(free_throw_shooter.data.shooting) / 100.0
    var make_chance := clampf(skill * 0.68 + timing_quality * 0.32, 0.38, 0.97)
    var is_green := timing_error <= GameTuning.FREE_THROW_GREEN_WINDOW
    if is_green:
        make_chance = maxf(make_chance, 0.94)

    _stat_inc(free_throw_shooter, "fta", 1)
    var made := rng.randf() <= make_chance
    if made:
        free_throw_made += 1
        _stat_inc(free_throw_shooter, "ftm", 1)
        _stat_inc(free_throw_shooter, "points", 1)
        if free_throw_shooter.team_id == TEAM_HOME:
            home_score += 1
        else:
            away_score += 1
        _refresh_score()
    free_throw_shooter.play_action_visual("FREETHROW")
    free_throw_attempts_left -= 1
    free_throw_waiting_result = true
    free_throw_between_timer = GameTuning.FREE_THROW_DEAD_BALL_DELAY
    if is_instance_valid(free_throw_detail_label):
        var timing_word := "GREEN" if is_green else ("CEDO" if held_seconds < GameTuning.FREE_THROW_IDEAL_HOLD else "TARDE")
        free_throw_detail_label.text = "%s • %s • chance %d%%" % ["CONVERTEU" if made else "ERROU", timing_word, roundi(make_chance * 100.0)]
        free_throw_detail_label.modulate = Color(0.35, 1.0, 0.52) if made else Color(1.0, 0.48, 0.32)

func _end_free_throw_sequence() -> void:
    var shooting_team := free_throw_shooter.team_id if free_throw_shooter != null else possession_team
    if free_throw_shooter != null and free_throw_shooter.has_ball:
        free_throw_shooter.release_ball()
    if is_instance_valid(free_throw_layer):
        free_throw_layer.queue_free()
    free_throw_layer = null
    free_throw_label = null
    free_throw_detail_label = null
    free_throw_shooter = null
    free_throw_attempts_left = 0
    free_throw_attempts_total = 0
    free_throw_hold_started_at = -1
    free_throw_waiting_result = false
    match_state = MatchState.LIVE
    dead_ball = false
    if not training_mode and period_time_left <= 0.05:
        _handle_period_end()
        return
    _start_possession(1 - shooting_team)

func _on_basket_scored(_detector_points: int, basket_id: StringName) -> void:
    if basket_locked or match_state != MatchState.LIVE:
        return
    basket_locked = true
    dead_ball = true

    var scoring_team := TEAM_HOME if basket_id == &"north" else TEAM_AWAY
    var points := 2
    if ball.state == MeteorBall.BallState.SHOT:
        points = ball.shot_value
    if scoring_team == TEAM_HOME:
        home_score += points
    else:
        away_score += points
    if transition_team == scoring_team and transition_time_left > 0.0:
        points_off_turnovers[scoring_team] = int(
            points_off_turnovers.get(scoring_team, 0)
        ) + points
        if match_number == 7 and scoring_team == TEAM_HOME:
            match_director.observe_event(&"easy_score")
    elif match_number == 7 and scoring_team == TEAM_HOME:
        match_director.observe_event(&"safe_possession")
    transition_team = -1
    transition_time_left = 0.0
    if match_number == 7 and scoring_team == TEAM_HOME:
        nightclaw_takeover_meter = maxf(
            0.0,
            nightclaw_takeover_meter - GameTuning.NIGHT_TAKEOVER_BASKET_PENALTY
        )

    var scorer: DinoPlayer = (ball.shooter as DinoPlayer) if ball.shooter is DinoPlayer else last_shooter
    if is_instance_valid(scorer) and scorer.team_id == scoring_team:
        _stat_inc(scorer, "points", points)
        _stat_inc(scorer, "fgm", 1)
        if points == 3:
            _stat_inc(scorer, "3pm", 1)
    _gain_instinct(scoring_team, GameTuning.INSTINCT_MADE_BASKET_GAIN)
    var passer = last_passer_by_team.get(scoring_team, null)
    if is_instance_valid(passer) and passer != scorer:
        _stat_inc(passer, "assists", 1)
        _gain_instinct(scoring_team, GameTuning.INSTINCT_ASSIST_GAIN)
    last_passer_by_team[scoring_team] = null

    _refresh_score()
    _set_event_feedback("+%d  METEOR!  %s • %s" % [points, _team_name(scoring_team), ball.shot_type], Color(1.0, 0.78, 0.24), 0.8)
    if match_number == 9:
        if scoring_team == TEAM_HOME:
            apex_roar_meter = maxf(
                0.0,
                apex_roar_meter - GameTuning.APEX_HOME_SCORE_PENALTY
            )
            _resolve_composure_event(composure_tracker.reward_safe_possession())
        elif last_shot_type in ["DUNK", "LAYUP"]:
            _gain_apex_roar(GameTuning.APEX_PAINT_SCORE_GAIN, "cesta no garrafão")
    elif match_number == 10 and scoring_team == TEAM_HOME:
        _resolve_crown_legacy(
            crown_legacy.observe_home_score(last_shot_type)
        )
    _play_sfx("res://audio/sfx/basket.wav")

    await get_tree().create_timer(GameTuning.DEAD_BALL_DELAY).timeout
    if not is_inside_tree() or match_state != MatchState.LIVE:
        return
    if not training_mode and period_time_left <= 0.05:
        _handle_period_end()
        return
    _start_possession(1 - scoring_team)

func _refresh_score() -> void:
    score_label.text = "VALE FÓSSIL  %d  —  %d  %s" % [home_score, away_score, away_team_name]

func _team_players(team: int) -> Array:
    return home_players if team == TEAM_HOME else away_players

func _team_name(team: int) -> String:
    return "VALE FÓSSIL" if team == TEAM_HOME else away_team_name

func _attack_hoop(team: int) -> Vector3:
    return north_hoop_target if team == TEAM_HOME else south_hoop_target

func _defended_hoop(team: int) -> Vector3:
    return south_hoop_target if team == TEAM_HOME else north_hoop_target

func _flat_distance(a: Vector3, b: Vector3) -> float:
    var av := Vector2(a.x, a.z)
    var bv := Vector2(b.x, b.z)
    return av.distance_to(bv)

func _gain_instinct(team: int, amount: float) -> void:
    instinct_meter[team] = clampf(float(instinct_meter[team]) + amount, 0.0, GameTuning.INSTINCT_MAX)

func is_instinct_active(team: int) -> bool:
    return float(instinct_time_left.get(team, 0.0)) > 0.0

func speed_multiplier_for(player: DinoPlayer) -> float:
    var result := 1.0
    if is_instinct_active(player.team_id):
        result *= GameTuning.INSTINCT_SPEED_BONUS
    if player.data != null and player.data.instinct_name == "Rastro Meteoro":
        var hoop := _attack_hoop(player.team_id)
        if _flat_distance(player.global_position, hoop) > 8.0:
            result *= 1.05
    if player.data != null and player.data.instinct_name == "Faísca Fóssil":
        result *= 1.035
    return result

func _current_play_call() -> String:
    return String(play_calls[play_call_index % play_calls.size()])

func _cycle_play_call() -> void:
    if possession_team != TEAM_HOME and not training_mode:
        _set_event_feedback("CHAME A JOGADA QUANDO A VALE FÓSSIL TIVER A POSSE", Color(0.75, 0.82, 0.9), 0.7)
        return
    play_call_index = (play_call_index + 1) % play_calls.size()
    home_cut_player = null
    home_cut_time_left = 0.0
    _set_event_feedback("JOGADA → %s" % _current_play_call(), Color(0.35, 0.9, 1.0), 0.8)

func _build_audio() -> void:
    sfx_player = AudioStreamPlayer.new()
    sfx_player.volume_db = -7.0
    add_child(sfx_player)

func _play_sfx(path: String) -> void:
    if not is_instance_valid(sfx_player) or not ResourceLoader.exists(path):
        return
    sfx_player.stream = load(path) as AudioStream
    sfx_player.play()

func _set_event_feedback(text_value: String, color: Color, duration: float) -> void:
    if not is_instance_valid(feedback_label):
        return
    feedback_label.text = text_value
    feedback_label.modulate = color
    feedback_color_time_left = duration

func is_gameplay_live() -> bool:
    return match_state == MatchState.LIVE and not dead_ball

func _refresh_match_hud() -> void:
    if score_label == null:
        return
    _refresh_score()
    possession_label.text = "POSSE: %s" % _team_name(possession_team)
    if is_instance_valid(fouls_label):
        fouls_label.text = "FALTAS • VALE %d — %d %s" % [int(team_fouls[TEAM_HOME]), int(team_fouls[TEAM_AWAY]), away_team_name]
    if is_instance_valid(play_label):
        play_label.text = "JOGADA: %s  •  %s  •  C para trocar" % [_current_play_call(), difficulty_name]
    if is_instance_valid(nightclaw_label) and match_number == 7:
        var dominant := tendency_model.dominant_tendency()
        var reading := _tendency_label(dominant)
        if nightclaw_takeover_left > 0.0:
            nightclaw_label.text = "◈ ECLIPSE DEFENSIVO ATIVO ◈\n%.1fs • reação e rotação intensificadas\nSem bônus oculto de velocidade" % nightclaw_takeover_left
        else:
            nightclaw_label.text = "ECLIPSE DEFENSIVO • %d%%\nLEITURA: %s\nV: finta de passe" % [
                roundi(nightclaw_takeover_meter),
                reading,
            ]
    if is_instance_valid(fossil_label) and match_number == 8:
        var forecast := sequence_model.predict_next()
        var accuracy := 0
        if fossil_predictions_seen > 0:
            accuracy = roundi(
                float(fossil_predictions_correct) / float(fossil_predictions_seen) * 100.0
            )
        if fossil_model_broken_left > 0.0:
            fossil_label.text = "◆ MODELO QUEBRADO ◆\n%.1fs • rotações preditivas suspensas\nERROS FORÇADOS: %d" % [
                fossil_model_broken_left,
                fossil_predictions_evaded,
            ]
        elif bool(forecast.get("available", false)):
            fossil_label.text = "PRÓXIMA: %s • %d%%\nQUEBRAR MODELO: %d%%\nACERTO DO MODELO: %d%% • V cria isca" % [
                _tendency_label(StringName(forecast.get("action", &""))),
                roundi(float(forecast.get("confidence", 0.0)) * 100.0),
                roundi(fossil_disruption_meter),
                accuracy,
            ]
        else:
            fossil_label.text = "MODELO: COLETANDO SEQUÊNCIAS\nEVIDÊNCIA: %.1f/%.0f\nQUEBRAR MODELO: %d%% • varie ações" % [
                float(forecast.get("evidence", 0.0)),
                SequencePredictionModel.MIN_CONTEXT_EVIDENCE,
                roundi(fossil_disruption_meter),
            ]
    if is_instance_valid(apex_label) and match_number == 9:
        var apex_plan_name := apex_ai.defensive_plan_name(apex_defensive_plan)
        if possession_team == TEAM_AWAY:
            apex_plan_name = apex_ai.offensive_plan_name(apex_offensive_plan)
        if apex_roar_left > 0.0:
            apex_label.text = "◆ RUGIDO DA DOMINION ◆\n%.1fs • PLANO: %s\nReação coletiva rápida • sem bônus ocultos" % [
                apex_roar_left,
                apex_plan_name,
            ]
            apex_label.modulate = Color(1.0, 0.58, 0.10)
        elif apex_silence_left > 0.0:
            apex_label.text = "◇ SILÊNCIO DA VALE ◇\n%.1fs • PLANO: %s\nA Apex demora mais para reorganizar" % [
                apex_silence_left,
                apex_plan_name,
            ]
            apex_label.modulate = Color(0.38, 1.0, 0.82)
        else:
            apex_label.text = "PLANO APEX: %s\nRUGIDO: %d%% • COMPOSTURA: %d%%\nSEQUÊNCIA: x%d • varie ações" % [
                apex_plan_name,
                roundi(apex_roar_meter),
                roundi(composure_tracker.meter),
                composure_tracker.current_chain,
            ]
            apex_label.modulate = Color(1.0, 0.78, 0.24)
    if is_instance_valid(crown_label) and match_number == 10:
        var seals := crown_legacy.broken_edict_keys().size()
        if crown_shattered_left > 0.0:
            crown_label.text = "☄ COROA PARTIDA ☄\n%.1fs • DECRETOS SUSPENSOS\nLEGADO: %d%% • formação equilibrada\nAtaque agora: antes que Drax se reorganize" % [
                crown_shattered_left,
                roundi(crown_legacy.legacy_meter),
            ]
            crown_label.modulate = Color(0.34, 1.0, 0.82)
        elif crown_edict == TyrantCrownMetaAI.Edict.BALANCED:
            crown_label.text = "COROA EQUILIBRADA\nDrax está lendo a quadra…\nLEGADO: %d%% • SELOS: %d/3\nPróximo decreto em %.1fs" % [
                roundi(crown_legacy.legacy_meter),
                seals,
                maxf(crown_edict_left, crown_select_cooldown),
            ]
            crown_label.modulate = Color(1.0, 0.52, 0.42)
        else:
            var prediction_line := ""
            if crown_edict == TyrantCrownMetaAI.Edict.WRITTEN_FATE:
                var crown_forecast := sequence_model.predict_next()
                prediction_line = "\nPREVISÃO: %s • %d%%" % [
                    _tendency_label(StringName(crown_forecast.get("action", &""))),
                    roundi(float(crown_forecast.get("confidence", 0.0)) * 100.0),
                ]
            crown_label.text = "DRAX DECRETA: %s • %.1fs\nLEGADO: %d%% • SELOS: %d/3%s\n%s" % [
                crown_ai.edict_name(crown_edict),
                crown_edict_left,
                roundi(crown_legacy.legacy_meter),
                seals,
                prediction_line,
                crown_ai.break_hint(crown_edict),
            ]
            crown_label.modulate = Color(1.0, 0.28, 0.24)
    if match_state == MatchState.FREE_THROW:
        period_label.text = "LANCE LIVRE"
        timer_label.text = _format_time(period_time_left)
        shot_clock_label.text = "BOLA MORTA"
        shot_clock_label.modulate = Color(1.0, 0.78, 0.32)
    elif training_mode:
        period_label.text = "TREINO"
        timer_label.text = "∞"
        shot_clock_label.text = "POSSE ∞"
    else:
        period_label.text = "OT %d" % overtime_count if overtime_count > 0 else "%dº TEMPO" % period
        timer_label.text = _format_time(period_time_left)
        shot_clock_label.text = "POSSE %02d" % ceili(shot_clock_left)
        if shot_clock_left <= 5.0:
            shot_clock_label.modulate = Color(1.0, 0.35, 0.2)
        else:
            shot_clock_label.modulate = Color.WHITE

func _refresh_tutorial() -> void:
    if tutorial_label == null:
        return
    if not tutorial_enabled:
        tutorial_label.visible = false
        return
    tutorial_label.visible = true
    tutorial_label.text = "TUTORIAL DE ESTREIA\n%s Mover (WASD)\n%s Passar (ESPAÇO)\n%s Arremessar (J)\n%s Trocar jogador (Q/TAB)" % [
        _tutorial_mark("move"), _tutorial_mark("pass"), _tutorial_mark("shot"), _tutorial_mark("switch")
    ]
    var complete := true
    for key in tutorial_flags.keys():
        if not bool(tutorial_flags[key]):
            complete = false
            break
    if complete and not tutorial_done_emitted:
        tutorial_done_emitted = true
        tutorial_label.text += "\n\n✓ FUNDAMENTOS CONCLUÍDOS"
        tutorial_completed.emit()


func _tendency_label(action: StringName) -> String:
    match action:
        &"cross_court_pass":
            return "PASSE CRUZADO"
        &"normal_pass":
            return "PASSE CURTO"
        &"lob_pass":
            return "LOB"
        &"drive":
            return "ATAQUE AO ARO"
        &"jump_shot":
            return "ARREMESSO"
        &"post_move":
            return "JOGO DE COSTAS"
        &"screen":
            return "CORTA-LUZ"
        &"pass_fake":
            return "FINTA DE PASSE"
        &"protect_ball":
            return "PROTEÇÃO DE BOLA"
        _:
            return "COLETANDO PADRÕES"

func _tutorial_mark(key: String) -> String:
    return "✓" if bool(tutorial_flags.get(key, false)) else "○"

func _shot_clock_violation() -> void:
    if training_mode or dead_ball or match_state != MatchState.LIVE:
        return
    dead_ball = true
    var violating_team := possession_team
    var responsible: DinoPlayer = null
    if ball.state == MeteorBall.BallState.HELD and ball.holder is DinoPlayer:
        responsible = ball.holder as DinoPlayer
    _register_turnover(
        responsible,
        "VIOLAÇÃO DE 18 SEGUNDOS",
        1 - violating_team
    )
    if match_number == 7 and violating_team == TEAM_HOME:
        _gain_nightclaw_takeover(GameTuning.NIGHT_TAKEOVER_SHOT_CLOCK_GAIN)
    feedback_label.text = "VIOLAÇÃO DE 18 SEGUNDOS • BOLA %s" % _team_name(1 - violating_team)
    await get_tree().create_timer(GameTuning.DEAD_BALL_DELAY).timeout
    if is_inside_tree() and match_state == MatchState.LIVE:
        _start_possession(1 - violating_team)

func _handle_period_end() -> void:
    if training_mode or match_state != MatchState.LIVE:
        return
    dead_ball = true
    if period == 1 and overtime_count == 0:
        match_state = MatchState.HALFTIME
        feedback_label.text = "INTERVALO • HORA DAS TROCAS"
        _show_halftime()
        return

    if home_score == away_score:
        _start_overtime()
    else:
        _finish_match()

func _start_overtime() -> void:
    overtime_count += 1
    period = 2
    period_time_left = GameTuning.OVERTIME_SECONDS
    match_state = MatchState.LIVE
    feedback_label.text = "PRORROGAÇÃO %d • 1 MINUTO" % overtime_count
    _recover_stamina(14.0)
    _start_possession(TEAM_HOME if overtime_count % 2 == 1 else TEAM_AWAY)

func _show_halftime() -> void:
    if match_number == 7:
        tendency_model.reset_short_term_memory()
        nightclaw_actions.clear()
        nightclaw_decision_cooldowns.clear()
    elif match_number == 8:
        sequence_model.reset_short_term_memory()
        fossil_actions.clear()
        fossil_decision_cooldowns.clear()
    elif match_number == 9:
        composure_tracker.reset_short_term_memory()
        apex_roar_meter *= 0.50
        apex_roar_left = 0.0
        apex_silence_left = 0.0
        apex_ai.roar_active = false
        apex_ai.silenced_active = false
        apex_defensive_plan = ApexCoordinationAI.DefensivePlan.BALANCED
        apex_offensive_plan = ApexCoordinationAI.OffensivePlan.SPREAD
        apex_plan_cooldown = 0.0
    elif match_number == 10:
        tendency_model.reset_short_term_memory()
        sequence_model.reset_short_term_memory()
        crown_legacy.reset_short_term_memory()
        crown_legacy.set_edict(&"balanced")
        crown_edict = TyrantCrownMetaAI.Edict.BALANCED
        crown_edict_left = 0.0
        crown_select_cooldown = crown_ai.reaction_time()
        crown_shattered_left = 0.0
        crown_ai.crown_shattered = false
        crown_last_announced_edict = ""
    if is_instance_valid(halftime_layer):
        halftime_layer.queue_free()
    halftime_layer = CanvasLayer.new()
    halftime_layer.layer = 15
    add_child(halftime_layer)

    var shade := ColorRect.new()
    shade.color = Color(0.01, 0.015, 0.025, 0.88)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    halftime_layer.add_child(shade)

    var panel := PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.position = Vector2(-285, -235)
    panel.size = Vector2(570, 470)
    halftime_layer.add_child(panel)

    var box := VBoxContainer.new()
    box.alignment = BoxContainer.ALIGNMENT_CENTER
    box.add_theme_constant_override("separation", 12)
    panel.add_child(box)

    var title := Label.new()
    title.text = "INTERVALO • %d — %d" % [home_score, away_score]
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 32)
    box.add_child(title)

    var info := Label.new()
    info.text = "Seu trio pode mudar agora. Jogadores que entram do banco chegam com stamina cheia."
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    info.custom_minimum_size = Vector2(510, 62)
    box.add_child(info)

    halftime_status_label = Label.new()
    halftime_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    halftime_status_label.custom_minimum_size = Vector2(510, 44)
    box.add_child(halftime_status_label)

    var swap_ala := Button.new()
    swap_ala.name = "SwapAla"
    swap_ala.custom_minimum_size = Vector2(500, 48)
    swap_ala.pressed.connect(func(): _swap_home_bench(1, 0))
    box.add_child(swap_ala)

    var swap_pivo := Button.new()
    swap_pivo.name = "SwapPivo"
    swap_pivo.custom_minimum_size = Vector2(500, 48)
    swap_pivo.pressed.connect(func(): _swap_home_bench(2, 1))
    box.add_child(swap_pivo)

    var continue_button := Button.new()
    continue_button.text = "COMEÇAR 2º TEMPO"
    continue_button.custom_minimum_size = Vector2(500, 52)
    continue_button.pressed.connect(_continue_second_half)
    box.add_child(continue_button)

    _recover_stamina(GameTuning.HALFTIME_STAMINA_RECOVERY)
    _auto_away_halftime_substitution()
    _refresh_halftime_buttons()

func _swap_home_bench(active_slot: int, bench_slot: int) -> void:
    if active_slot >= home_players.size() or bench_slot >= home_bench.size():
        return
    var active_player := home_players[active_slot] as DinoPlayer
    var outgoing := active_player.data
    var incoming := home_bench[bench_slot] as PlayerData
    active_player.replace_data(incoming, true)
    _mark_played(incoming)
    home_bench[bench_slot] = outgoing
    halftime_status_label.text = "%s entra no lugar de %s." % [incoming.display_name, outgoing.display_name]
    _refresh_halftime_buttons()

func _refresh_halftime_buttons() -> void:
    if not is_instance_valid(halftime_layer):
        return
    var ala_button := halftime_layer.find_child("SwapAla", true, false) as Button
    var pivo_button := halftime_layer.find_child("SwapPivo", true, false) as Button
    if ala_button != null:
        ala_button.text = "TROCAR SLOT 2: %s ↔ %s" % [(home_players[1] as DinoPlayer).data.display_name, (home_bench[0] as PlayerData).display_name]
    if pivo_button != null:
        pivo_button.text = "TROCAR SLOT 3: %s ↔ %s" % [(home_players[2] as DinoPlayer).data.display_name, (home_bench[1] as PlayerData).display_name]

func _auto_away_halftime_substitution() -> void:
    if away_bench.is_empty():
        return
    var slot := 1 if (away_players[1] as DinoPlayer).stamina <= (away_players[2] as DinoPlayer).stamina else 2
    var bench_slot := 0 if slot == 1 else mini(1, away_bench.size() - 1)
    var player := away_players[slot] as DinoPlayer
    var outgoing := player.data
    var incoming := away_bench[bench_slot] as PlayerData
    player.replace_data(incoming, true)
    away_bench[bench_slot] = outgoing

func _continue_second_half() -> void:
    if is_instance_valid(halftime_layer):
        halftime_layer.queue_free()
    period = 2
    period_time_left = GameTuning.STORY_PERIOD_SECONDS
    match_state = MatchState.LIVE
    feedback_label.text = "2º TEMPO • %s COMEÇA COM A BOLA" % away_team_name
    _start_possession(TEAM_AWAY)

func _recover_stamina(amount: float) -> void:
    for player in all_players:
        player.stamina = minf(GameTuning.STAMINA_MAX, player.stamina + amount)

func _ensure_stat_row(data: PlayerData) -> void:
    if data == null:
        return
    var id := String(data.id)
    if not match_stats.has(id):
        match_stats[id] = {
            "id": id, "name": data.display_name, "played": false,
            "points": 0, "assists": 0, "rebounds": 0, "steals": 0, "blocks": 0,
            "fgm": 0, "fga": 0, "3pm": 0, "3pa": 0, "ftm": 0, "fta": 0,
            "fouls": 0, "turnovers": 0
        }

func _mark_played(data: PlayerData) -> void:
    if data == null:
        return
    _ensure_stat_row(data)
    var id := String(data.id)
    var row: Dictionary = match_stats[id]
    row["played"] = true
    match_stats[id] = row

func _stat_inc(player: DinoPlayer, key: String, amount: int) -> void:
    if player == null or player.team_id != TEAM_HOME or player.data == null:
        return
    _ensure_stat_row(player.data)
    var id := String(player.data.id)
    var row: Dictionary = match_stats[id]
    row[key] = int(row.get(key, 0)) + amount
    match_stats[id] = row

func _record_shot_attempt(player: DinoPlayer, value: int) -> void:
    _stat_inc(player, "fga", 1)
    if value == 3:
        _stat_inc(player, "3pa", 1)

func get_home_stats_summary() -> Dictionary:
    var rows: Array = []
    var mvp_id := ""
    var mvp_name := ""
    var best_impact := -999.0
    for entry in MatchCatalog.home_roster(player_progression):
        var id := String(entry.get("id", ""))
        if match_stats.has(id):
            var row: Dictionary = match_stats[id].duplicate(true)
            var misses := maxi(0, int(row.get("fga", 0)) - int(row.get("fgm", 0)))
            var impact := float(row.get("points", 0))
            impact += float(row.get("assists", 0)) * 1.5
            impact += float(row.get("rebounds", 0)) * 1.2
            impact += float(row.get("steals", 0)) * 2.0
            impact += float(row.get("blocks", 0)) * 2.0
            impact -= float(misses) * 0.6
            impact -= float(row.get("fouls", 0)) * 0.25
            impact -= float(row.get("turnovers", 0)) * 1.1
            row["impact"] = snappedf(impact, 0.1)
            rows.append(row)
            if bool(row.get("played", false)) and impact > best_impact:
                best_impact = impact
                mvp_id = id
                mvp_name = String(row.get("name", ""))
    rows.sort_custom(func(a: Dictionary, b: Dictionary): return float(a.get("impact", 0.0)) > float(b.get("impact", 0.0)))
    return {
        "players": rows,
        "difficulty": difficulty_name,
        "lineup": home_lineup_ids.duplicate(),
        "mvp_id": mvp_id,
        "mvp_name": mvp_name,
        "mvp_impact": snappedf(best_impact, 0.1),
        "team_turnovers": turnovers.duplicate(true),
        "points_off_turnovers": points_off_turnovers.duplicate(true),
        "adaptive_profile": tendency_model.to_dictionary(),
        "sequence_profile": sequence_model.to_dictionary(),
        "semifinal_profile": composure_tracker.to_dictionary(),
        "final_profile": crown_legacy.to_dictionary(),
        "prediction_summary": {
            "seen": fossil_predictions_seen,
            "correct": fossil_predictions_correct,
            "evaded": fossil_predictions_evaded,
        },
        "apex_summary": {
            "roar_meter": snappedf(apex_roar_meter, 0.1),
            "best_composure_chain": composure_tracker.best_chain,
            "roars_silenced": composure_tracker.roars_silenced,
            "defensive_plan": apex_ai.defensive_plan_name(apex_defensive_plan),
            "offensive_plan": apex_ai.offensive_plan_name(apex_offensive_plan),
        },
        "crown_summary": {
            "edicts_broken": crown_legacy.broken_this_match,
            "crowns_shattered": crown_legacy.crowns_shattered,
            "legacy_meter": snappedf(crown_legacy.legacy_meter, 0.1),
            "predictions_seen": crown_predictions_seen,
            "predictions_correct": crown_predictions_correct,
            "predictions_evaded": crown_predictions_evaded,
            "active_edict": crown_ai.edict_name(crown_edict),
        },
    }

func _green_window() -> float:
    if difficulty_name == "METEOR":
        return GameTuning.SHOT_GREEN_METEOR
    if difficulty_name == "LEAGUE":
        return GameTuning.SHOT_GREEN_LEAGUE
    return GameTuning.SHOT_GREEN_ADVENTURE

func _difficulty_ai_multiplier() -> float:
    if difficulty_name == "METEOR":
        return GameTuning.DIFFICULTY_METEOR_AI
    if difficulty_name == "LEAGUE":
        return GameTuning.DIFFICULTY_LEAGUE_AI
    return GameTuning.DIFFICULTY_ADVENTURE_AI

func _build_three_point_lines() -> void:
    var line_color := Color("f7fbff") if high_contrast else Color(0.76, 0.82, 0.9, 0.88)
    for hoop_z in [-12.55, 12.55]:
        var direction := 1.0 if hoop_z < 0.0 else -1.0
        for i in range(25):
            var t := lerpf(-1.02, 1.02, float(i) / 24.0)
            var x := sin(t) * GameTuning.THREE_POINT_DISTANCE
            var z_offset := cos(t) * GameTuning.THREE_POINT_DISTANCE
            var z := hoop_z + direction * z_offset
            if absf(x) <= GameTuning.COURT_WIDTH * 0.5 - 0.35 and absf(z) <= GameTuning.COURT_LENGTH * 0.5 - 0.25:
                _add_box(Vector3(x, 0.032, z), Vector3(0.20, 0.018, 0.07), line_color, false)

func _finish_match() -> void:
    if match_state == MatchState.FINISHED:
        return
    match_state = MatchState.FINISHED
    dead_ball = true
    feedback_label.text = "FIM DE JOGO • %d x %d" % [home_score, away_score]
    match_finished.emit(home_score > away_score, home_score, away_score)

func _add_box(pos: Vector3, size: Vector3, color: Color, collider: bool) -> Node3D:
    var root := Node3D.new()
    root.position = pos
    add_child(root)
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.75
    mesh.material_override = mat
    root.add_child(mesh)
    if collider:
        var body := StaticBody3D.new()
        body.collision_layer = 1
        body.collision_mask = 2 | 4
        var collision := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        collision.shape = shape
        body.add_child(collision)
        root.add_child(body)
    return root

func _add_sphere(pos: Vector3, radius: float, color: Color, collider: bool) -> Node3D:
    var root := Node3D.new()
    root.position = pos
    add_child(root)
    var mesh := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = radius
    sphere.height = radius * 2.0
    mesh.mesh = sphere
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = 0.25
    mesh.material_override = mat
    root.add_child(mesh)
    if collider:
        var body := StaticBody3D.new()
        body.collision_layer = 1
        body.collision_mask = 2
        var collision := CollisionShape3D.new()
        var shape := SphereShape3D.new()
        shape.radius = radius
        collision.shape = shape
        body.add_child(collision)
        root.add_child(body)
    return root

func _format_time(seconds: float) -> String:
    var total := ceili(seconds)
    return "%02d:%02d" % [int(total / 60), total % 60]
