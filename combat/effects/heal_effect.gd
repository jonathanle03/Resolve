class_name HealEffect
extends Effect


@export var amount: float = 0.0


func apply(source: Combatant, target: Combatant) -> Array[Result]:
	var res := Result.new()
	
	var health_healed := target.heal_health(amount)
	
	res.source = source
	res.target = target
	res.kind = Result.ResultKind.HEAL
	res.amount = health_healed
	res.health_after = target.current_health
	
	return [res]
