class_name ApplyStatusEffect
extends Effect


var status: StatusEffect


func apply(source: Combatant, target: Combatant) -> Result:
	var res := Result.new()
	
	var poison := StatusEffect.new()
	poison.duration = 2
	poison.amount = 2.0
	target.status_effects.append(poison)
	
	res.source = source
	res.target = target
	res.kind = "status"
	
	return res
