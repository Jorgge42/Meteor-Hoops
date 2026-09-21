class_name PassingLaneAnalyzer
extends RefCounted


static func analyze(
    origin: Vector3,
    target: Vector3,
    defenders: Array,
    passer_rating: int,
    safety_bonus: float = 0.0,
    is_lob: bool = false
) -> Dictionary:
    var best_defender: Node3D = null
    var closest_distance := INF
    var best_projection := 0.0
    for defender_value in defenders:
        var defender := defender_value as Node3D
        if defender == null:
            continue
        var result := distance_to_segment(defender.global_position, origin, target)
        var distance := float(result.get("distance", INF))
        var projection := float(result.get("projection", 0.0))
        if projection >= 0.08 and projection <= 0.94 and distance < closest_distance:
            closest_distance = distance
            best_projection = projection
            best_defender = defender

    var distance_factor := 0.0
    if best_defender != null:
        distance_factor = 1.0 - clampf(closest_distance / 2.25, 0.0, 1.0)
    var length_factor := clampf(origin.distance_to(target) / 12.0, 0.0, 1.0)
    var passing_safety := clampf(float(passer_rating) / 100.0, 0.0, 1.0) * 0.34
    var lob_safety := 0.16 if is_lob else 0.0
    var risk := distance_factor * 0.58 + length_factor * 0.30
    risk -= passing_safety + clampf(safety_bonus, 0.0, 0.35) + lob_safety
    risk = clampf(risk, 0.0, 1.0)
    return {
        "risk": risk,
        "closest_distance": closest_distance,
        "projection": best_projection,
        "defender": best_defender,
        "cross_court": is_cross_court(origin, target),
    }


static func distance_to_segment(point: Vector3, start: Vector3, end: Vector3) -> Dictionary:
    var point_2d := Vector2(point.x, point.z)
    var start_2d := Vector2(start.x, start.z)
    var end_2d := Vector2(end.x, end.z)
    var segment := end_2d - start_2d
    var length_squared := segment.length_squared()
    if length_squared <= 0.0001:
        return {
            "distance": point_2d.distance_to(start_2d),
            "projection": 0.0,
            "closest": start,
        }
    var projection := clampf(
        (point_2d - start_2d).dot(segment) / length_squared,
        0.0,
        1.0
    )
    var closest_2d := start_2d + segment * projection
    return {
        "distance": point_2d.distance_to(closest_2d),
        "projection": projection,
        "closest": Vector3(closest_2d.x, 0.0, closest_2d.y),
    }


static func is_cross_court(origin: Vector3, target: Vector3) -> bool:
    var changes_side := signf(origin.x) != signf(target.x)
    return changes_side and absf(target.x - origin.x) >= 5.0
