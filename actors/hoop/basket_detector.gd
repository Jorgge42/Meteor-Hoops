class_name BasketDetector
extends Node3D

signal basket_scored(points: int, basket_id: StringName)

var basket_id: StringName = &"north"
var _armed_balls: Dictionary = {}

func setup(new_basket_id: StringName) -> void:
    basket_id = new_basket_id

func _ready() -> void:
    _make_gate("TopGate", 3.14, Callable(self, "_on_top_gate"))
    _make_gate("BottomGate", 2.96, Callable(self, "_on_bottom_gate"))

func _make_gate(gate_name: String, y: float, callback: Callable) -> void:
    var area := Area3D.new()
    area.name = gate_name
    area.position = Vector3(0.0, y, 0.0)
    area.collision_layer = 0
    area.collision_mask = 2
    add_child(area)

    var collision := CollisionShape3D.new()
    var shape := CylinderShape3D.new()
    shape.radius = GameTuning.RIM_RADIUS * 0.78
    shape.height = 0.06
    collision.shape = shape
    area.add_child(collision)
    area.body_entered.connect(callback)

func _on_top_gate(body: Node3D) -> void:
    if body is MeteorBall and body.linear_velocity.y < 0.0:
        _armed_balls[body.get_instance_id()] = Time.get_ticks_msec()

func _on_bottom_gate(body: Node3D) -> void:
    if not (body is MeteorBall):
        return
    var id := body.get_instance_id()
    if not _armed_balls.has(id):
        return
    var elapsed := Time.get_ticks_msec() - int(_armed_balls[id])
    _armed_balls.erase(id)
    if body.linear_velocity.y < 0.0 and elapsed <= 900:
        basket_scored.emit(2, basket_id)
