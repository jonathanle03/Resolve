class_name StatusEffect
extends RefCounted


var duration: int
var amount: float


func tick(target: Combatant) -> Result:
	var res := Result.new()
	res.amount = target.take_damage(amount)
	return res
