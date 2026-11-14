extends Control


@onready var _play_again_button: Button = %PlayAgainButton


func _ready() -> void:
	_play_again_button.pressed.connect(_on_play_again_button_pressed)


func _on_play_again_button_pressed() -> void:
	GameState.start_new_game()
