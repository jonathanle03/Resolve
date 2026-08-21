extends Node2D


@onready var _ally_unit: Sprite2D = %AllyUnit
@onready var _enemy_unit: Sprite2D = %EnemyUnit


var sprite_map: Dictionary[Combatant, Sprite2D] = {}


func setup(allies: Array[Combatant], enemies: Array[Combatant]) -> void:
	sprite_map[allies[0]] = _ally_unit
	sprite_map[enemies[0]] = _enemy_unit


func present(results: Array[Result]) -> void:
	for result in results:
		match result.kind:
			Result.ResultKind.DAMAGE:
				var source := result.source
				var target := result.target
				
				if source:
					await attack_animation(sprite_map[source], sprite_map[target])
				
				attacked_animation(sprite_map[target])
				await create_damage_number(sprite_map[target], result.amount)
				
				if source:
					await fallback_animation(sprite_map[source], sprite_map[target])
				
			Result.ResultKind.HEAL:
				pass
			Result.ResultKind.STATUS_APPLIED:
				pass
			Result.ResultKind.DEATH:
				pass
			_:
				pass


func attack_animation(source: Sprite2D, target: Sprite2D) -> void:
	var start_position := source.position
	var direction := -1.0 if target.global_position.x > source.global_position.x else 1.0
	
	var tween := create_tween()
	tween.tween_method(
		func (t: float) -> void:
			source.position.x = start_position.x - 100.0 * t * direction
			source.position.y = start_position.y - 50.0 * 4 * t * (1 - t)
	, 0.0, 1.0, 0.5
	)
	
	await tween.finished


func attacked_animation(target: Sprite2D) -> void:
	var tween := create_tween()
	tween.tween_property(target, "position:x", -10.0, 0.05).as_relative()
	tween.tween_property(target, "position:x", 20.0, 0.1).as_relative()
	tween.tween_property(target, "position:x", -10.0, 0.05).as_relative()
	
	await tween.finished


func fallback_animation(source: Sprite2D, target: Sprite2D) -> void:
	var start_position := source.position
	var direction := -1.0 if target.global_position.x > source.global_position.x else 1.0
	
	var tween := create_tween()
	tween.tween_property(source, "position:x", 100.0 * direction, 0.5).as_relative()
	
	await tween.finished


func create_damage_number(target: Sprite2D, amount: float) -> void:
	var damage_label := Label.new()
	add_child(damage_label)	
	damage_label.text = str(floori(amount))
	damage_label.global_position = target.global_position
	
	var damage_label_tween := create_tween()
	damage_label_tween.tween_property(damage_label, "position:y", -100.0, 0.5).as_relative()
	damage_label_tween.parallel().tween_property(damage_label, "modulate:a", 0.0, 0.5)
	damage_label_tween.finished.connect(damage_label.queue_free)
	
	await damage_label_tween.finished
