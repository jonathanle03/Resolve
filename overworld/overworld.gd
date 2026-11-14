extends Node2D


@onready var _player: Player = %Player


func _ready() -> void:
	if GameState.returning_from_battle:
		_player.global_position = GameState.overworld_position
		GameState.returning_from_battle = false
	
	if GameState.encounter:
		if not GameState.encounter.victory_dialogue.is_empty():
			await DialogueBox.show_dialogue(GameState.encounter.victory_dialogue)
		
		var next_scene := GameState.encounter.next_scene
		GameState.encounter = null
		if next_scene:
			get_tree().change_scene_to_packed(next_scene)
