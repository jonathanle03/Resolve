extends Node2D


signal hit_landed(amount: float)


@onready var _battle_view: Node2D = %BattleView


var player := Combatant.new("Player", 250.0, 5.0)
var enemy := Combatant.new("Enemy", 20.0, 2.0)
var player_damage_effect := DamageEffect.new(player.attack * 0.5)
var enemy_damage_effect := DamageEffect.new(enemy.attack * 0.5)
var player_poison_effect := ApplyStatusEffect.new(StatusEffect.new(3, [], [], [], [DamageEffect.new(player.attack * 0.2)]))
var player_action := Action.new()
var enemy_action := Action.new()


func _ready() -> void:
	hit_landed.connect(_battle_view.on_hit_landed)
	
	player_action.source = player
	player_action.target = enemy
	player_action.effects.append(player_damage_effect)
	player_action.effects.append(player_poison_effect)
	
	enemy_action.source = enemy
	enemy_action.target = player
	enemy_action.effects.append(enemy_damage_effect)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		var actions: Array[Action] = [player_action, enemy_action]
		var results := resolution(actions)
		
		for result in results:
			prints(result.source.name if result.source else null, result.target.name if result.target else null, Result.ResultKind.keys()[result.kind], result.amount, result.hp_after)


func resolution(actions: Array[Action]) -> Array[Result]:
	var results: Array[Result] = []
	
	
	for action in actions:
		if action.source.is_dead:
			continue
		
		
		var prev_source_is_dead := action.source.is_dead
		var prev_target_is_dead := action.target.is_dead
		
		
		# On Turn Start
		for status in action.source.status_effects:
			results.append_array(status.on_turn_start(action.source))
		
		if not prev_source_is_dead and action.source.is_dead:
			prev_source_is_dead = true
			var res = Result.new()
			res.source = null
			res.target = action.source
			res.kind = Result.ResultKind.DEATH
			results.append(res)
			continue
		
		
		# Perform Action
		for effect in action.effects:
			results.append(effect.apply(action.source, action.target))
		
		if not prev_target_is_dead and action.target.is_dead:
			prev_target_is_dead = true
			var res = Result.new()
			res.source = null
			res.target = action.target
			res.kind = Result.ResultKind.DEATH
			results.append(res)
		
		
		# On Turn End
		var removed_statuses: Array[StatusEffect] = []
		for status in action.source.status_effects:
			results.append_array(status.on_turn_end(action.source))
			
			if status.duration > 0:
				status.duration -= 1
			if status.duration == 0:
				results.append_array(status.on_remove(action.source))
				removed_statuses.append(status)
		
		for status in removed_statuses:
			action.source.status_effects.erase(status)
		
		if not prev_source_is_dead and action.source.is_dead:
			prev_source_is_dead = true
			var res = Result.new()
			res.source = null
			res.target = action.source
			res.kind = Result.ResultKind.DEATH
			results.append(res)
	
	
	return results
