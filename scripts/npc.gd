class_name NPC
extends StaticBody2D


@onready var _prompt: Label = %Prompt


var dialogue: Array[String] = ["Hey you!", "Rapiers are not swords!"]


func interact() -> void:
	await DialogueBox.show_dialogue(dialogue)
	GameState.overworld_position = global_position
	
	# TODO: Update when enemy resources are implemented
	var enemy := {"name": "Enemy", "max_health": 50.0, "attack": 4.0}
	GameState.enemies = [enemy]
	
	get_tree().change_scene_to_file("uid://dsh8y6ogu1sfl")


func show_prompt() -> void:
	_prompt.visible = true


func hide_prompt() -> void:
	_prompt.visible = false
