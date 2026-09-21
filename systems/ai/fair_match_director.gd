class_name FairMatchDirector
extends RefCounted

signal intervention_requested(intervention: Dictionary)

const REPEAT_HINT_COOLDOWN := 4

var _possessions_since_hint := REPEAT_HINT_COOLDOWN
var _consecutive_turnovers := 0
var _consecutive_easy_scores := 0


func observe_event(event_name: StringName) -> void:
    match event_name:
        &"turnover":
            _consecutive_turnovers += 1
            _consecutive_easy_scores = 0
        &"easy_score":
            _consecutive_easy_scores += 1
            _consecutive_turnovers = 0
        &"safe_possession":
            _consecutive_turnovers = 0
        &"possession_end":
            _possessions_since_hint += 1
    _evaluate_intervention()


func allowed_adjustments() -> Dictionary:
    return {
        "tutorial_hint": true,
        "opponent_strategy_weights": true,
        "commentary_focus": true,
        "camera_emphasis": true,
        "shot_probability": false,
        "ball_physics": false,
        "hidden_attribute_boost": false,
    }


func _evaluate_intervention() -> void:
    if _possessions_since_hint < REPEAT_HINT_COOLDOWN:
        return
    if _consecutive_turnovers >= 3:
        _request_hint(
            "turnover_help",
            "A Nightclaw leu o padrão. Use V para fintar antes do próximo passe."
        )
    elif _consecutive_easy_scores >= 3:
        _request_strategy_shift("protect_paint", 0.18)


func _request_hint(code: String, message: String) -> void:
    _possessions_since_hint = 0
    intervention_requested.emit({
        "type": "hint",
        "code": code,
        "message": message,
    })


func _request_strategy_shift(strategy: String, weight_delta: float) -> void:
    _possessions_since_hint = 0
    intervention_requested.emit({
        "type": "strategy_shift",
        "strategy": strategy,
        "weight_delta": clampf(weight_delta, -0.25, 0.25),
    })
