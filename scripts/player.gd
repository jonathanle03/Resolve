extends CharacterBody2D


@onready var _area_2d: Area2D = %Area2D


var move_speed := 300.0
var tracked_npc: NPC = null


func _ready() -> void:
	if GameState.returning_from_battle:
		global_position = GameState.overworld_position
	
	_area_2d.body_entered.connect(_on_area_2d_body_entered)
	_area_2d.body_exited.connect(_on_area_2d_body_exited)


func _physics_process(delta: float) -> void:
	if DialogueBox.is_active:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		if tracked_npc:
			tracked_npc.interact()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is NPC:
		if tracked_npc:
			tracked_npc.hide_prompt()
		tracked_npc = body
		tracked_npc.show_prompt()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is NPC and body == tracked_npc:
		tracked_npc.hide_prompt()
		tracked_npc = null
