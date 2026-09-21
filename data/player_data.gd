class_name PlayerData
extends Resource

@export var id: StringName = &"kiro"
@export var display_name := "Kiro"
@export var species := "Velociraptor"
@export var role := "Armador"
@export_range(1, 100) var speed := 92
@export_range(1, 100) var shooting := 70
@export_range(1, 100) var passing := 84
@export_range(1, 100) var defense := 78
@export_range(1, 100) var strength := 38
@export_range(1.55, 2.35, 0.01) var gameplay_height := 1.78
@export var instinct_name := "Rastro Meteoro"
@export_multiline var bio := "Armador rápido da Vale Fóssil. Aprende que velocidade sem direção não vence campeonatos."
