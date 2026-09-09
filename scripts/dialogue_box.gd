extends CanvasLayer


signal line_advanced


@onready var label: Label = %Label


var is_active := false


func _ready() -> void:
	visible = false


func show_dialogue(lines: Array[String]) -> void:
	if is_active:
		return
	
	is_active = true
	visible = true
	for line in lines:
		label.text = line
		await line_advanced
	is_active = false
	visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not event.is_echo() and is_active:
		line_advanced.emit()
		get_viewport().set_input_as_handled()
