class_name DamageEffect
extends Effect


@export var amount: float = 0.0
@export var ratio: float = 0.0


func apply(source: Combatant, target: Combatant) -> Array[Result]:
	var res := Result.new()
	
	if ratio and not source:
		push_error("No source combatant for ratio to derive stats from")
	
	var damage := amount + ratio * source.attack if source else amount
	var damage_dealt := target.take_damage(damage)
	
	res.source = source
	res.target = target
	res.kind = Result.ResultKind.DAMAGE
	res.amount = damage_dealt
	res.health_after = target.current_health
	
	return [res]
