class_name DinoPlayer
extends CharacterBody3D

@export var data: PlayerData

var match_manager: Node
var ball: MeteorBall
var team_id := 0
var roster_index := 0
var controlled := false
var has_ball := false
var stamina := GameTuning.STAMINA_MAX
var ai_target := Vector3.ZERO
var ai_sprint := false
var last_move_input := Vector2.ZERO
var steal_cooldown_left := 0.0
var block_cooldown_left := 0.0
var rebound_cooldown_left := 0.0
var post_cooldown_left := 0.0
var pass_fake_cooldown_left := 0.0
var protecting_ball := false
var boxing_out := false
var ai_box_out := false
var movement_slow_left := 0.0
var movement_slow_multiplier := 1.0

var _regen_delay_left := 0.0
var _shot_started_at := -1
var _ball_socket: Marker3D
var _body_material: StandardMaterial3D
var _body_mesh: MeshInstance3D
var _visual_action := ""
var _visual_action_time := 0.0
var _name_label: Label3D
var _control_ring: MeshInstance3D
var _team_color := Color("39c7b5")
var _dribble_phase := 0.0
var _instinct_visual_active := false
var _base_socket_position := Vector3(0.48, 1.05, -0.18)

func _ready() -> void:
    collision_layer = 4
    collision_mask = 1 | 2 | 4
    _build_graybox_body()

func setup(new_data: PlayerData, match_ball: MeteorBall, manager: Node, new_team_id: int, new_roster_index: int, color: Color) -> void:
    data = new_data
    ball = match_ball
    match_manager = manager
    team_id = new_team_id
    roster_index = new_roster_index
    _team_color = color
    _apply_identity()

func _build_graybox_body() -> void:
    var body_mesh := MeshInstance3D.new()
    _body_mesh = body_mesh
    var capsule_mesh := CapsuleMesh.new()
    capsule_mesh.radius = 0.38
    capsule_mesh.height = 1.55
    body_mesh.mesh = capsule_mesh
    body_mesh.position.y = 0.9
    _body_material = StandardMaterial3D.new()
    _body_material.albedo_color = _team_color
    _body_material.roughness = 0.75
    body_mesh.material_override = _body_material
    add_child(body_mesh)

    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.38
    capsule.height = 1.8
    collision.shape = capsule
    collision.position.y = 0.9
    add_child(collision)

    _ball_socket = Marker3D.new()
    _ball_socket.name = "BallSocket"
    _ball_socket.position = _base_socket_position
    add_child(_ball_socket)

    _name_label = Label3D.new()
    _name_label.position = Vector3(0, 2.08, 0)
    _name_label.font_size = 26
    _name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    add_child(_name_label)

    _control_ring = MeshInstance3D.new()
    var ring := CylinderMesh.new()
    ring.top_radius = 0.52
    ring.bottom_radius = 0.52
    ring.height = 0.035
    _control_ring.mesh = ring
    _control_ring.position = Vector3(0, 0.03, 0)
    var ring_mat := StandardMaterial3D.new()
    ring_mat.albedo_color = Color("ffffff")
    ring_mat.emission_enabled = true
    ring_mat.emission = Color("ffffff")
    ring_mat.emission_energy_multiplier = 1.5
    _control_ring.material_override = ring_mat
    _control_ring.visible = false
    add_child(_control_ring)

func _apply_identity() -> void:
    if is_instance_valid(_body_material):
        _body_material.albedo_color = _team_color
    if is_instance_valid(_name_label) and data != null:
        _name_label.text = data.display_name
        _name_label.modulate = _team_color.lightened(0.2)

func replace_data(new_data: PlayerData, reset_stamina: bool = false) -> void:
    data = new_data
    if reset_stamina:
        stamina = GameTuning.STAMINA_MAX
    _apply_identity()

func set_controlled(value: bool) -> void:
    controlled = value
    if is_instance_valid(_control_ring):
        _control_ring.visible = value
        _control_ring.scale = Vector3.ONE * (1.18 if value and _instinct_visual_active else 1.0)

func set_ai_target(target: Vector3, sprint: bool = false) -> void:
    ai_target = target
    ai_sprint = sprint

func set_ai_box_out(value: bool) -> void:
    ai_box_out = value

func _physics_process(delta: float) -> void:
    steal_cooldown_left = maxf(0.0, steal_cooldown_left - delta)
    block_cooldown_left = maxf(0.0, block_cooldown_left - delta)
    rebound_cooldown_left = maxf(0.0, rebound_cooldown_left - delta)
    post_cooldown_left = maxf(0.0, post_cooldown_left - delta)
    pass_fake_cooldown_left = maxf(0.0, pass_fake_cooldown_left - delta)
    movement_slow_left = maxf(0.0, movement_slow_left - delta)
    if movement_slow_left <= 0.0:
        movement_slow_multiplier = 1.0
    if match_manager != null and match_manager.has_method("is_gameplay_live") and not match_manager.is_gameplay_live():
        velocity = Vector3.ZERO
        protecting_ball = false
        boxing_out = false
        return
    _update_movement(delta)
    _update_dribble_visual(delta)
    _update_action_visual(delta)
    if controlled:
        _update_ball_actions()

func _update_movement(delta: float) -> void:
    var input2 := Vector2.ZERO
    var sprinting := false
    protecting_ball = false
    boxing_out = false

    if controlled:
        input2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
        last_move_input = input2
        protecting_ball = has_ball and Input.is_action_pressed("protect_ball") and stamina > 1.0
        boxing_out = not has_ball and Input.is_action_pressed("protect_ball") and stamina > 1.0
        sprinting = Input.is_action_pressed("sprint") and input2.length() > 0.1 and stamina > 1.0 and not protecting_ball and not boxing_out
    else:
        var to_target := ai_target - global_position
        to_target.y = 0.0
        if to_target.length() > 0.28:
            var wish3 := to_target.normalized()
            input2 = Vector2(wish3.x, wish3.z)
        boxing_out = ai_box_out and not has_ball and stamina > 1.0
        sprinting = ai_sprint and input2.length() > 0.1 and stamina > 1.0 and not boxing_out

    var wish := Vector3(input2.x, 0.0, input2.y)
    if wish.length() > 1.0:
        wish = wish.normalized()

    var stat_speed := 60.0 if data == null else float(data.speed)
    var stat_multiplier := lerpf(0.82, 1.16, stat_speed / 100.0)
    if match_manager != null and match_manager.has_method("speed_multiplier_for"):
        stat_multiplier *= float(match_manager.speed_multiplier_for(self))
    var sprint_multiplier := GameTuning.SPRINT_MULTIPLIER if sprinting else 1.0
    if protecting_ball:
        sprint_multiplier *= GameTuning.PROTECT_SPEED_MULTIPLIER
    if boxing_out:
        sprint_multiplier *= GameTuning.BOX_OUT_SPEED_MULTIPLIER
    sprint_multiplier *= movement_slow_multiplier
    var target_velocity := wish * GameTuning.BASE_SPEED * stat_multiplier * sprint_multiplier

    var accel := GameTuning.ACCELERATION if wish.length() > 0.05 else GameTuning.DECELERATION
    velocity.x = move_toward(velocity.x, target_velocity.x, accel * delta)
    velocity.z = move_toward(velocity.z, target_velocity.z, accel * delta)
    velocity.y = 0.0
    move_and_slide()

    if wish.length() > 0.1:
        var facing := Vector3(wish.x, 0.0, wish.z)
        rotation.y = lerp_angle(rotation.y, atan2(facing.x, facing.z), minf(1.0, delta * 12.0))

    if sprinting:
        stamina = maxf(0.0, stamina - GameTuning.SPRINT_DRAIN_PER_SEC * delta)
        _regen_delay_left = GameTuning.STAMINA_REGEN_DELAY
    elif protecting_ball or boxing_out:
        var drain := GameTuning.PROTECT_DRAIN_PER_SEC if protecting_ball else GameTuning.PROTECT_DRAIN_PER_SEC * 0.72
        stamina = maxf(0.0, stamina - drain * delta)
        _regen_delay_left = GameTuning.STAMINA_REGEN_DELAY
    else:
        _regen_delay_left = maxf(0.0, _regen_delay_left - delta)
        if _regen_delay_left <= 0.0:
            stamina = minf(GameTuning.STAMINA_MAX, stamina + GameTuning.STAMINA_REGEN_PER_SEC * delta)


func _update_dribble_visual(delta: float) -> void:
    if not is_instance_valid(_ball_socket):
        return
    if not has_ball:
        _ball_socket.position = _base_socket_position
        return
    var movement_factor := clampf(Vector2(velocity.x, velocity.z).length() / maxf(GameTuning.BASE_SPEED, 0.1), 0.0, 1.4)
    var tempo := 7.5 + movement_factor * 4.0
    if protecting_ball:
        tempo *= 0.72
    _dribble_phase = fmod(_dribble_phase + delta * tempo, TAU)
    var bounce := absf(sin(_dribble_phase))
    var depth := lerpf(0.24, 0.58, clampf(movement_factor, 0.0, 1.0))
    if protecting_ball:
        depth *= 0.55
    _ball_socket.position = _base_socket_position + Vector3(0.0, -bounce * depth, 0.0)

func play_action_visual(action: String) -> void:
    _visual_action = action
    _visual_action_time = 0.32 if action == "SHOT" else 0.42

func _update_action_visual(delta: float) -> void:
    if not is_instance_valid(_body_mesh):
        return
    _visual_action_time = maxf(0.0, _visual_action_time - delta)
    var speed_ratio := clampf(Vector2(velocity.x, velocity.z).length() / maxf(GameTuning.BASE_SPEED, 0.1), 0.0, 1.0)
    var run_bob := sin(float(Time.get_ticks_msec()) / 95.0) * 0.035 * speed_ratio
    var target_y := 0.9 + run_bob
    var target_scale := Vector3.ONE
    if _visual_action_time > 0.0:
        var phase := _visual_action_time / 0.42
        if _visual_action == "DUNK":
            target_y += sin((1.0 - phase) * PI) * 0.48
            target_scale = Vector3(0.94, 1.10, 0.94)
        elif _visual_action == "LAYUP":
            target_y += sin((1.0 - phase) * PI) * 0.30
            target_scale = Vector3(0.97, 1.06, 0.97)
        elif _visual_action == "BLOCK":
            target_y += sin((1.0 - phase) * PI) * 0.38
            target_scale = Vector3(1.06, 1.08, 0.92)
        elif _visual_action == "REBOUND":
            target_y += sin((1.0 - phase) * PI) * 0.34
            target_scale = Vector3(1.02, 1.08, 0.96)
        elif _visual_action == "ALLEY":
            target_y += sin((1.0 - phase) * PI) * 0.58
            target_scale = Vector3(0.93, 1.14, 0.93)
        elif _visual_action == "SHOT":
            target_y += sin((1.0 - phase) * PI) * 0.16
            target_scale = Vector3(0.97, 1.05, 0.97)
        elif _visual_action == "SCREEN":
            target_scale = Vector3(1.13, 0.98, 1.10)
        elif _visual_action == "POST":
            target_scale = Vector3(1.10, 1.00, 1.08)
        elif _visual_action == "FREETHROW":
            target_y += sin((1.0 - phase) * PI) * 0.10
            target_scale = Vector3(0.98, 1.04, 0.98)
        elif _visual_action == "PASS_FAKE":
            target_scale = Vector3(1.04, 0.98, 1.08)
    _body_mesh.position.y = lerpf(_body_mesh.position.y, target_y, minf(1.0, delta * 18.0))
    _body_mesh.scale = _body_mesh.scale.lerp(target_scale, minf(1.0, delta * 15.0))
    if _visual_action_time <= 0.0:
        _visual_action = ""

func set_instinct_visual(active: bool) -> void:
    if _instinct_visual_active == active:
        return
    _instinct_visual_active = active
    if not is_instance_valid(_body_material):
        return
    _body_material.emission_enabled = active
    if active:
        _body_material.emission = _team_color.lightened(0.35)
        _body_material.emission_energy_multiplier = 2.4
    else:
        _body_material.emission_energy_multiplier = 1.0
    if is_instance_valid(_control_ring) and controlled:
        _control_ring.scale = Vector3.ONE * (1.18 if active else 1.0)

func _update_ball_actions() -> void:
    if ball == null or match_manager == null:
        return

    if Input.is_action_just_pressed("pass_pickup"):
        if has_ball:
            match_manager.request_pass(self, last_move_input)
        else:
            match_manager.request_pickup_or_steal(self)

    if Input.is_action_just_pressed("lob_pass") and has_ball:
        match_manager.request_lob(self, last_move_input)

    if Input.is_action_just_pressed("pass_fake") and has_ball:
        match_manager.request_pass_fake(self, last_move_input)

    if Input.is_action_just_pressed("call_screen") and has_ball:
        match_manager.request_screen(self)

    if Input.is_action_just_pressed("post_move") and has_ball:
        match_manager.request_post_move(self)

    if Input.is_action_just_pressed("finish_block"):
        if has_ball:
            match_manager.request_finish(self)
        elif ball.state == MeteorBall.BallState.SHOT:
            var early_shot_window := ball.state_age_seconds() <= GameTuning.BLOCK_WINDOW
            var enemy_shot := ball.shooter is DinoPlayer and (ball.shooter as DinoPlayer).team_id != team_id
            if early_shot_window and enemy_shot:
                match_manager.request_block(self)
            else:
                match_manager.request_rebound(self)
        elif ball.state == MeteorBall.BallState.LOOSE:
            match_manager.request_rebound(self)
        else:
            match_manager.request_block(self)

    if has_ball and Input.is_action_just_pressed("shoot"):
        _shot_started_at = Time.get_ticks_msec()

    if has_ball and _shot_started_at >= 0 and Input.is_action_just_released("shoot"):
        var held := float(Time.get_ticks_msec() - _shot_started_at) / 1000.0
        _shot_started_at = -1
        match_manager.request_shot(self, held)

    if Input.is_action_just_pressed("activate_instinct"):
        match_manager.request_instinct(self)

    if has_ball and Input.is_action_just_pressed("protect_ball"):
        if match_manager.has_method("notify_ball_protection"):
            match_manager.notify_ball_protection(self)

func take_ball() -> void:
    if ball == null:
        return
    if is_instance_valid(ball.holder) and ball.holder is DinoPlayer:
        (ball.holder as DinoPlayer).has_ball = false
    has_ball = true
    ball.attach_to(self, _ball_socket, team_id)

func release_ball() -> void:
    has_ball = false
    protecting_ball = false
    boxing_out = false
    _shot_started_at = -1

func apply_movement_slow(seconds: float, multiplier: float) -> void:
    movement_slow_left = maxf(movement_slow_left, seconds)
    movement_slow_multiplier = minf(movement_slow_multiplier, clampf(multiplier, 0.2, 1.0))

func can_attempt_post_move() -> bool:
    return post_cooldown_left <= 0.0 and stamina >= GameTuning.POST_STAMINA_COST

func consume_post_move() -> void:
    post_cooldown_left = GameTuning.POST_COOLDOWN
    stamina = maxf(0.0, stamina - GameTuning.POST_STAMINA_COST)
    _regen_delay_left = GameTuning.STAMINA_REGEN_DELAY


func can_attempt_pass_fake() -> bool:
    return pass_fake_cooldown_left <= 0.0


func consume_pass_fake() -> void:
    pass_fake_cooldown_left = GameTuning.PASS_FAKE_COOLDOWN

func can_attempt_steal() -> bool:
    return steal_cooldown_left <= 0.0

func consume_steal_attempt() -> void:
    steal_cooldown_left = GameTuning.STEAL_COOLDOWN

func can_attempt_block() -> bool:
    return block_cooldown_left <= 0.0

func consume_block_attempt() -> void:
    block_cooldown_left = GameTuning.BLOCK_COOLDOWN

func can_attempt_rebound() -> bool:
    return rebound_cooldown_left <= 0.0

func consume_rebound_attempt() -> void:
    rebound_cooldown_left = GameTuning.REBOUND_COOLDOWN
