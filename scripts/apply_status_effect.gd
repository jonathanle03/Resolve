class_name ApplyStatusEffect
extends Effect


var status: StatusEffect


func _init(status: StatusEffect) -> void:
	self.status = status


func apply(source: Combatant, target: Combatant) -> Array[Result]:
	var res := Result.new()
	
	var cloned_status := status.clone()
	target.status_effects.append(cloned_status)
	
	res.source = source
	res.target = target
	res.kind = Result.ResultKind.STATUS_APPLIED
	res.status = cloned_status
	
	var results: Array[Result] = [res]
	results.append_array(cloned_status.on_apply(target))
	return results
