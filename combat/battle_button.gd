class_name BattleButton
extends PanelContainer


@onready var _button: Button = %Button
@onready var _margin_container: MarginContainer = %MarginContainer
@onready var _skill_name_label: Label = %SkillNameLabel
@onready var _mana_cost_label: Label = %ManaCostLabel


func _ready() -> void:
	_skill_name_label.text = ""
	_mana_cost_label.text = ""


func set_labels(skill_name: String, mana_cost: String) -> void:
	_skill_name_label.text = skill_name
	_mana_cost_label.text = mana_cost


func set_binding(skill_binding: Callable) -> void:
	_button.pressed.connect(skill_binding)


func disable_button() -> void:
	_button.disabled = true
	_margin_container.modulate = Color(0.5, 0.5, 0.5, 1.0)
