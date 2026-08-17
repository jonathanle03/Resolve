class_name ApplyStatusEffect
extends Effect


var status: StatusEffect


func _init(status: StatusEffect) -> void:
	self.status = status


func apply(source: Combatant, target: Combatant) -> Result:
	var res := Result.new()
	
	target.status_effects.append(status.clone())
	
	res.source = source
	res.target = target
	res.kind = Result.ResultKind.STATUS_APPLIED
	
	return res
