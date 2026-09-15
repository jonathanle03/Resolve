extends Node2D


enum Motion { UP, DOWN, ARC }


@onready var _ally_node: Node2D = %AllyNode
@onready var _enemy_node: Node2D = %EnemyNode


var combatant_node_map: Dictionary[Combatant, Node2D] = {}


func setup(allies: Array[Combatant], enemies: Array[Combatant]) -> void:
	combatant_node_map[allies[0]] = _ally_node
	_ally_node.get_node("ProgressBar").max_value = allies[0].max_health
	_ally_node.get_node("ProgressBar").value = allies[0].current_health
	combatant_node_map[enemies[0]] = _enemy_node
	_enemy_node.get_node("ProgressBar").max_value = enemies[0].max_health
	_enemy_node.get_node("ProgressBar").value = enemies[0].current_health


func present(results: Array[Result]) -> void:
	for result in results:
		var target := result.target
		
		match result.kind:
			Result.ResultKind.DAMAGE:
				var source := result.source
				
				if source:
					await attack_animation(combatant_node_map[source], combatant_node_map[target])
				
				attacked_animation(combatant_node_map[target])
				combatant_node_map[target].get_node("ProgressBar").value = result.health_after
				await create_floating_text(combatant_node_map[target], str(max(floori(result.amount), 1)), Color.RED, Motion.UP)
				
				if source:
					await fallback_animation(combatant_node_map[source], combatant_node_map[target])
				
			Result.ResultKind.HEAL:
				combatant_node_map[target].get_node("ProgressBar").value = result.health_after
				await create_floating_text(combatant_node_map[target], str(max(floori(result.amount), 1)), Color.GREEN, Motion.UP)
				
			Result.ResultKind.STATUS_APPLIED:
				var text: String
				var color: Color
				var motion: Motion
				
				if result.status.category == StatusEffect.Category.BUFF:
					text = "▲"
					color = Color.ORANGE
					motion = Motion.UP
				elif result.status.category == StatusEffect.Category.DEBUFF:
					text = "▼"
					color = Color.NAVY_BLUE
					motion = Motion.DOWN
				else:
					text = "■"
					color = Color.GRAY
					motion = Motion.ARC
				
				await create_floating_text(combatant_node_map[target], text, color, motion)
			
			Result.ResultKind.DEATH:
				var tween := create_tween()
				tween.tween_property(combatant_node_map[target], "modulate:a", 0, 1.0)
				await tween.finished
			
			_:
				pass


func attack_animation(source: Node2D, target: Node2D) -> void:
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


func attacked_animation(target: Node2D) -> void:
	var sprite: Sprite2D = target.get_node("Sprite2D")
	var tween := create_tween()
	tween.tween_property(sprite, "position:x", -10.0, 0.05).as_relative()
	tween.tween_property(sprite, "position:x", 20.0, 0.1).as_relative()
	tween.tween_property(sprite, "position:x", -10.0, 0.05).as_relative()
	
	await tween.finished


func fallback_animation(source: Node2D, target: Node2D) -> void:
	var start_position := source.position
	var direction := -1.0 if target.global_position.x > source.global_position.x else 1.0
	
	var tween := create_tween()
	tween.tween_property(source, "position:x", 100.0 * direction, 0.4).as_relative()
	
	await tween.finished


func create_floating_text(target: Node2D, text: String, color: Color, motion: Motion) -> void:
	var label := Label.new()
	add_child(label)	
	label.text = text
	label.global_position = target.global_position
	label.modulate = color
	
	var label_tween := create_tween()
	match motion:
		Motion.UP:
			label.global_position.y += 20.0
			label_tween.tween_property(label, "position:y", -50.0, 0.3).as_relative()
		
		Motion.DOWN:
			label.global_position.y -= 40.0
			label_tween.tween_property(label, "position:y", 50.0, 0.3).as_relative()
		
		Motion.ARC:
			var start_position = label.global_position
			label_tween.tween_method(
				func (t: float) -> void:
					label.position.y = start_position.y - 40.0 * 2 * t * (1 - t)
			, 0.0, 1.0, 0.3
			)
		
	label_tween.tween_property(label, "modulate:a", 0.0, 0.3)
	label_tween.finished.connect(label.queue_free)
	await label_tween.finished
