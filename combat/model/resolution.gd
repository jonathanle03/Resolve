class_name Resolution
extends RefCounted


static func resolve_turn_start(combatant: Combatant) -> Array[Result]:
	var results: Array[Result] = []
	
	# On Turn Start
	for status in combatant.status_effects:
		results.append_array(status.on_turn_start(combatant))
	
	if combatant.is_dead:
		results.append(_death_result(combatant))
	
	return results


static func resolve(actions: Array[Action]) -> Array[Result]:
	var results: Array[Result] = []
	
	for action in actions:
		if action.source.is_dead:
			continue
		
		var prev_target_is_dead := action.target.is_dead
		
		# Perform Action
		for effect in action.effects:
			var res := effect.apply(action.source, action.target)
			results.append_array(res)
		
		if not prev_target_is_dead and action.target.is_dead:
			prev_target_is_dead = true
			results.append(_death_result(action.target))
		
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
		
		if action.source.is_dead:
			results.append(_death_result(action.source))
	
	return results


static func _death_result(target: Combatant) -> Result:
	var res := Result.new()
	res.source = null
	res.target = target
	res.kind = Result.ResultKind.DEATH
	return res
