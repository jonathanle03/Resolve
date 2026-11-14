extends Area2D


@export var encounters: Array[Encounter]


const MIN_DISTANCE := 750.0
const MAX_DISTANCE := 1500.0


var distance_moved := 0.0
var threshold: float
var player_inside := false
var player: Player


func _ready() -> void:
	assert(not encounters.is_empty(), "No encounters set")
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	threshold = randf_range(MIN_DISTANCE, MAX_DISTANCE)


func _physics_process(delta: float) -> void:
	if not player_inside or not player:
		return
	
	if player.velocity.length() > 0.0:
		distance_moved += player.velocity.length() * delta
	
		if distance_moved >= threshold:
			trigger_battle()


func trigger_battle() -> void:
	distance_moved = 0.0
	var encounter = encounters.pick_random()
	GameState.start_battle(player.global_position, encounter)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_inside = true
		player = body


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_inside = false
		player = null
