class_name CombatantView
extends Node2D


@onready var _animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var _health_bar: ProgressBar = %HealthBar
@onready var _mana_bar: ProgressBar = %ManaBar


func set_max_health(amount: float) -> void:
	_health_bar.max_value = amount


func set_health(amount: float) -> void:
	_health_bar.value = amount


func set_max_mana(amount: float) -> void:
	_mana_bar.max_value = amount


func set_mana(amount: float) -> void:
	_mana_bar.value = amount


func mirror() -> void:
	_animated_sprite_2d.flip_h = true


func attack_animation(target: Node2D) -> void:
	var start_position := position
	var direction := -1.0 if target.position.x > position.x else 1.0
	
	var tween := create_tween()
	tween.tween_method(
		func (t: float) -> void:
			position.x = start_position.x - 100.0 * t * direction
			position.y = start_position.y - 50.0 * 4 * t * (1 - t)
	, 0.0, 1.0, 0.5
	)
	
	await tween.finished


func attacked_animation() -> void:
	var tween := create_tween()
	tween.tween_property(_animated_sprite_2d, "position:x", -10.0, 0.05).as_relative()
	tween.tween_property(_animated_sprite_2d, "position:x", 20.0, 0.1).as_relative()
	tween.tween_property(_animated_sprite_2d, "position:x", -10.0, 0.05).as_relative()
	
	await tween.finished


func fallback_animation(target: Node2D) -> void:
	var start_position := position
	var direction := -1.0 if target.position.x > position.x else 1.0
	
	var tween := create_tween()
	tween.tween_property(self, "position:x", 100.0 * direction, 0.4).as_relative()
	
	await tween.finished


func death_animation() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0, 1.0)
	await tween.finished


func create_floating_text(text: String, color: Color, motion: BattleView.Motion) -> void:
	var label := Label.new()
	add_child(label)	
	label.text = text
	label.position = Vector2.ZERO
	label.modulate = color
	
	var label_tween := create_tween()
	match motion:
		BattleView.Motion.UP:
			label.global_position.y += 20.0
			label_tween.tween_property(label, "position:y", -50.0, 0.3).as_relative()
		
		BattleView.Motion.DOWN:
			label.global_position.y -= 40.0
			label_tween.tween_property(label, "position:y", 50.0, 0.3).as_relative()
		
		BattleView.Motion.ARC:
			var start_position = label.position
			label_tween.tween_method(
				func (t: float) -> void:
					label.position.y = start_position.y - 40.0 * 2 * t * (1 - t)
			, 0.0, 1.0, 0.3
			)
		
	label_tween.tween_property(label, "modulate:a", 0.0, 0.3)
	label_tween.finished.connect(label.queue_free)
	await label_tween.finished
