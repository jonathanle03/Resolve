class_name Resolution
extends RefCounted


static func resolve(actions: Array[Action]) -> Array[Result]:
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
			var res := Result.new()
			res.source = null
			res.target = action.source
			res.kind = Result.ResultKind.DEATH
			results.append(res)
			continue
		
		
		# Perform Action
		for effect in action.effects:
			var res := effect.apply(action.source, action.target)
			results.append(res)
			if res.kind == Result.ResultKind.STATUS_APPLIED:
				results.append_array(res.status.on_apply(action.target))
		
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
