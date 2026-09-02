extends Control


@onready var _play_button: Button = %PlayButton


func _ready() -> void:
	_play_button.pressed.connect(_on_play_button_pressed)


func _on_play_button_pressed() -> void:
	var party_member := PartyMember.new("Ally", 250.0, 5.0)
	GameState.party_members = [party_member]
	GameState.returning_from_battle = false
	get_tree().change_scene_to_file("uid://br1ry85r6s0ql")
