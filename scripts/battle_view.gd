extends Node2D


@onready var _ally_unit: Sprite2D = %AllyUnit
@onready var _enemy_unit: Sprite2D = %EnemyUnit


func on_hit_landed(amount: float) -> void:
	var ally_start_position := _ally_unit.position
	var tween := create_tween()
	tween.set_parallel()
	
	tween.tween_property(_ally_unit, "position:x", -100.0, 0.5).as_relative()
	tween.tween_method(
		func (t: float) -> void:
			_ally_unit.position.y = ally_start_position.y - 50.0 * 4 * t * (1 - t)
	, 0.0, 1.0, 0.5
	)
	
	tween.chain().tween_callback(
		func () -> void:
			var damage_label := Label.new()
			add_child(damage_label)
			damage_label.text = "4"
			damage_label.global_position = _enemy_unit.global_position
			
			var damage_label_tween := create_tween()
			damage_label_tween.tween_property(damage_label, "position:y", -100.0, 0.5).as_relative()
			damage_label_tween.parallel().tween_property(damage_label, "modulate:a", 0.0, 0.5)
			damage_label_tween.finished.connect(damage_label.queue_free)
	)
	
	tween.tween_interval(0.5)
	tween.chain().tween_property(_ally_unit, "position:x", 100.0, 0.25).as_relative()
