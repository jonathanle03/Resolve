extends Node2D


signal hit_landed(amount: float)


@onready var _battle_view: Node2D = %BattleView


func _ready() -> void:
	hit_landed.connect(_battle_view.on_hit_landed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		hit_landed.emit(4)
		print("Deal 4 damage")
