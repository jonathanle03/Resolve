extends Area2D


@export var encounter: Encounter


const MIN_DISTANCE := 1000.0
const MAX_DISTANCE := 2500.0
const ENCOUNTER_CHANCE := 0.001


var distance_moved := 0.0
var player_inside := false
var player: Player


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	if not player_inside or not player:
		return
	
	if player.velocity.length() > 0.0:
		distance_moved += player.velocity.length() * delta
	
		if distance_moved >= MIN_DISTANCE:
			if randf() <= ENCOUNTER_CHANCE or distance_moved >= MAX_DISTANCE:
				trigger_battle()


func trigger_battle() -> void:
	distance_moved = 0.0
	
	GameState.overworld_position = global_position
	GameState.encounter = encounter
	get_tree().change_scene_to_file("uid://dsh8y6ogu1sfl")


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_inside = true
		player = body


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_inside = false
		player = null
