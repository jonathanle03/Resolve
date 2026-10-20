class_name NPC
extends StaticBody2D


@onready var _prompt: Label = %Prompt


var dialogue: Array[String] = ["Hey you!", "Rapiers are not swords!"]


func interact() -> void:
	await DialogueBox.show_dialogue(dialogue)
	GameState.overworld_position = global_position
	
	var encounter: Encounter = load("uid://dbr02kaip7gy6")
	GameState.encounter = encounter
	
	get_tree().change_scene_to_file("uid://dsh8y6ogu1sfl")


func show_prompt() -> void:
	_prompt.visible = true


func hide_prompt() -> void:
	_prompt.visible = false
