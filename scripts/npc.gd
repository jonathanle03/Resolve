class_name NPC
extends StaticBody2D


@onready var _prompt: Label = %Prompt


func interact() -> void:
	GameState.overworld_position = global_position
	
	var enemy := Combatant.new("Enemy", 20.0, 20.0, 2.0)
	GameState.enemies = [enemy]
	
	get_tree().change_scene_to_file("uid://dsh8y6ogu1sfl")


func show_prompt() -> void:
	_prompt.visible = true


func hide_prompt() -> void:
	_prompt.visible = false
