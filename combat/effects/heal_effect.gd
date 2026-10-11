class_name HealEffect
extends Effect


@export var amount: float = 0.0
@export var ratio: float = 0.0


func apply(source: Combatant, target: Combatant) -> Array[Result]:
	var res := Result.new()
	
	if ratio and not source:
		push_error("No source combatant for ratio to derive stats from")
	
	var healing := amount + ratio * source.attack if source else amount
	var health_healed := target.heal_health(healing)
	
	res.source = source
	res.target = target
	res.kind = Result.ResultKind.HEAL
	res.amount = health_healed
	res.health_after = target.current_health
	
	return [res]
