class_name CombatantView
extends Node2D


signal target_node_chosen(target: CombatantView)


@onready var _animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var _health_bar: ProgressBar = %HealthBar
@onready var _health_label: Label = %HealthLabel
@onready var _mana_bar: ProgressBar = %ManaBar
@onready var _mana_label: Label = %ManaLabel
@onready var _area_2d: Area2D = %Area2D
@onready var _target_box: Sprite2D = %TargetBox


var max_health: float:
	set(amount):
		max_health = amount
		_health_bar.max_value = amount
		_health_label.text = str(current_health) + " / " + str(max_health)
var current_health: float:
	set(amount):
		current_health = amount
		_health_bar.value = amount
		_health_label.text = str(current_health) + " / " + str(max_health)
var max_mana: float:
	set(amount):
		max_mana = amount
		_mana_bar.max_value = amount
		_mana_label.text = str(current_mana) + " / " + str(max_mana)
var current_mana: float:
	set(amount):
		current_mana = amount
		_mana_bar.value = amount
		_mana_label.text = str(current_mana) + " / " + str(max_mana)


func _ready() -> void:
	disable_click()
	_area_2d.input_event.connect(_on_area_2d_input_event)


func set_max_health(amount: float) -> void:
	max_health = amount


func set_health(amount: float) -> void:
	current_health = amount


func set_max_mana(amount: float) -> void:
	max_mana = amount


func set_mana(amount: float) -> void:
	current_mana = amount


func set_sprites(sprites: SpriteFrames) -> void:
	if not sprites.has_animation("idle") or not sprites.has_animation("attacking"):
		push_error("Missing combatant animations")
	elif sprites.get_animation_loop("attacking"):
		push_error("Attacking animations is looping")
	
	_animated_sprite_2d.sprite_frames = sprites
	_animated_sprite_2d.play("idle")


func mirror() -> void:
	_animated_sprite_2d.flip_h = true


func attack_animation(target: Node2D) -> void:
	if _animated_sprite_2d.sprite_frames.has_animation("attacking"):
		_animated_sprite_2d.play("attacking")
		await _animated_sprite_2d.animation_finished
		_animated_sprite_2d.play("idle")
		return
	
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
	tween.tween_property(_animated_sprite_2d, "position:x", -8.0, 0.04).as_relative()
	tween.tween_property(_animated_sprite_2d, "position:x", 16.0, 0.08).as_relative()
	tween.tween_property(_animated_sprite_2d, "position:x", -8.0, 0.04).as_relative()
	
	await tween.finished


func fallback_animation(target: Node2D) -> void:
	if _animated_sprite_2d.sprite_frames.has_animation("attacking"):
		return
	
	var direction := -1.0 if target.position.x > position.x else 1.0
	
	var tween := create_tween()
	tween.tween_property(self, "position:x", 100.0 * direction, 0.4).as_relative()
	
	await tween.finished


func death_animation() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.6)
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


func enable_click() -> void:
	_area_2d.visible = true
	_target_box.visible = true


func disable_click() -> void:
	_area_2d.visible = false
	_target_box.visible = false


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shade_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			target_node_chosen.emit(self)
