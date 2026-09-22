class_name DamageEffect
extends Effect


@export var amount: float = 0.0


func apply(source: Combatant, target: Combatant) -> Array[Result]:
	var res := Result.new()
	
	var damage_dealt := target.take_damage(amount)
	
	res.source = source
	res.target = target
	res.kind = Result.ResultKind.DAMAGE
	res.amount = damage_dealt
	res.health_after = target.current_health
	
	return [res]
