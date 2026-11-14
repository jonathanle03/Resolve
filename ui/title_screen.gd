extends Control


@onready var _play_button: Button = %PlayButton


func _ready() -> void:
	_play_button.pressed.connect(_on_play_button_pressed)


func _on_play_button_pressed() -> void:
	GameState.start_new_game()
