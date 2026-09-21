class_name MeteorBall
extends RigidBody3D

enum BallState { HELD, PASS, SHOT, LOOSE }

var state: BallState = BallState.LOOSE
var holder: Node3D
var hold_marker: Node3D
var intended_receiver: Node3D
var last_touch_team := -1
var state_started_msec := 0
var shot_value := 2
var shot_origin := Vector3.ZERO
var shot_type := "JUMPER"
var shooter: Node3D
var pass_style := "NORMAL"

func _ready() -> void:
    mass = GameTuning.BALL_MASS
    collision_layer = 2
    collision_mask = 1 | 4
    continuous_cd = true
    contact_monitor = true
    max_contacts_reported = 8

    var material := PhysicsMaterial.new()
    material.bounce = 0.72
    material.friction = 0.55
    physics_material_override = material

    if get_child_count() == 0:
        var mesh := MeshInstance3D.new()
        var sphere := SphereMesh.new()
        sphere.radius = GameTuning.BALL_RADIUS
        sphere.height = GameTuning.BALL_RADIUS * 2.0
        mesh.mesh = sphere
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color("d97822")
        mat.roughness = 0.8
        mesh.material_override = mat
        add_child(mesh)

        var collision := CollisionShape3D.new()
        var shape := SphereShape3D.new()
        shape.radius = GameTuning.BALL_RADIUS
        collision.shape = shape
        add_child(collision)

func _physics_process(_delta: float) -> void:
    if state == BallState.HELD and is_instance_valid(hold_marker):
        global_position = hold_marker.global_position
        linear_velocity = Vector3.ZERO
        angular_velocity = Vector3.ZERO

func attach_to(new_holder: Node3D, marker: Node3D, team_id: int = -1) -> void:
    holder = new_holder
    hold_marker = marker
    intended_receiver = null
    shooter = null
    pass_style = "NORMAL"
    state = BallState.HELD
    state_started_msec = Time.get_ticks_msec()
    last_touch_team = team_id
    freeze = true
    sleeping = false
    collision_layer = 0
    collision_mask = 0
    global_position = marker.global_position
    linear_velocity = Vector3.ZERO
    angular_velocity = Vector3.ZERO

func release_with_velocity(initial_velocity: Vector3, next_state: BallState, team_id: int = -1) -> void:
    holder = null
    hold_marker = null
    state = next_state
    state_started_msec = Time.get_ticks_msec()
    if team_id >= 0:
        last_touch_team = team_id
    freeze = false
    collision_layer = 2
    collision_mask = 1 | 4
    linear_velocity = initial_velocity
    angular_velocity = Vector3(4.0, 1.5, -3.0)

func launch_pass(target: Vector3, receiver: Node3D = null, speed: float = GameTuning.PASS_SPEED, team_id: int = -1) -> void:
    intended_receiver = receiver
    shooter = null
    pass_style = "NORMAL"
    var direction := (target - global_position).normalized()
    release_with_velocity(direction * speed, BallState.PASS, team_id)

func launch_lob(target: Vector3, receiver: Node3D = null, flight_time: float = GameTuning.LOB_PASS_FLIGHT, team_id: int = -1) -> void:
    intended_receiver = receiver
    shooter = null
    pass_style = "LOB"
    release_with_velocity(_ballistic_velocity(target, flight_time), BallState.PASS, team_id)

func launch_arc(target: Vector3, flight_time: float, team_id: int = -1, new_shooter: Node3D = null, new_shot_value: int = 2, new_shot_type: String = "JUMPER") -> void:
    intended_receiver = null
    shooter = new_shooter
    pass_style = "NORMAL"
    shot_value = new_shot_value
    shot_origin = global_position
    shot_type = new_shot_type
    release_with_velocity(_ballistic_velocity(target, flight_time), BallState.SHOT, team_id)

func _ballistic_velocity(target: Vector3, flight_time: float) -> Vector3:
    var safe_time := maxf(0.12, flight_time)
    var gravity := float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))
    var displacement := target - global_position
    var horizontal := Vector3(displacement.x, 0.0, displacement.z)
    var horizontal_velocity := horizontal / safe_time
    var vertical_velocity := (displacement.y + 0.5 * gravity * safe_time * safe_time) / safe_time
    return Vector3(horizontal_velocity.x, vertical_velocity, horizontal_velocity.z)

func make_loose() -> void:
    if state == BallState.HELD:
        freeze = false
    holder = null
    hold_marker = null
    intended_receiver = null
    shooter = null
    pass_style = "NORMAL"
    state = BallState.LOOSE
    state_started_msec = Time.get_ticks_msec()
    collision_layer = 2
    collision_mask = 1 | 4

func swat(direction: Vector3, team_id: int = -1) -> void:
    make_loose()
    if team_id >= 0:
        last_touch_team = team_id
    var dir := direction
    if dir.length() < 0.01:
        dir = Vector3(0.7, 0.25, 0.4)
    dir = dir.normalized()
    linear_velocity = dir * 7.5 + Vector3.UP * 2.6
    angular_velocity = Vector3(9.0, 2.0, -5.0)

func state_age_seconds() -> float:
    return float(Time.get_ticks_msec() - state_started_msec) / 1000.0
