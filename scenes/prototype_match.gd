Warning: truncated output (original token count: 32161)
Total output lines: 3024

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
    if difficulty_name == "METEOR":
        fossil_ai.difficulty = FossilTechPredictiveAI.Difficulty.METEOR
    elif difficulty_name == "LEAGUE":
        fossil_ai.difficulty = FossilTechPredictiveAI.Difficulty.LEAGUE
    else:
        fossil_ai.difficulty = FossilTechPredictiveAI.Difficulty.ADVENTURE
    fossil_ai.begin_match(match_seed + 808)
    if not sequence_profile.is_empty():
        sequence_model.from_dictionary(sequence_profile)
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
    return (
        match_number == 7
        and player.team_id == TEAM_AWAY
        and nightclaw_takeover_left > 0.0
    )

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

    if match_number in [7, 8] and passer.team_id == TEAM_HOME:
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
        _play_sfx("res://audio/sfx/block.wav")
    else:
        var foul_chance := GameTuning.BLOCK_FOU…12161 tokens truncated…overy_team: int
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
    if is_instance_valid(ball.holder) and ball.holder is DinoPlayer:
        (ball.holder as DinoPlayer).release_ball()
    player.take_ball()
    possession_team = player.team_id
    if player.team_id != previous_possession:
        last_passer_by_team[player.team_id] = null

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
        "prediction_summary": {
            "seen": fossil_predictions_seen,
            "correct": fossil_predictions_correct,
            "evaded": fossil_predictions_evaded,
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
