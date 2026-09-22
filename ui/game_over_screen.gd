extends Control


@onready var _retry_battle_button: Button = %RetryBattleButton
@onready var _return_to_title_button: Button = %ReturnToTitleButton


func _ready() -> void:
	_retry_battle_button.pressed.connect(_on_retry_battle_button_pressed)
	_return_to_title_button.pressed.connect(_on_return_to_title_button_pressed)


func _on_retry_battle_button_pressed() -> void:
	get_tree().change_scene_to_file("uid://dsh8y6ogu1sfl")


func _on_return_to_title_button_pressed() -> void:
	get_tree().change_scene_to_file("uid://dix75hobg1j0r")
