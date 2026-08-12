class_name DamageEffect
extends Effect


var ratio: float = 0.5


func apply(source: Combatant, target: Combatant) -> Result:
	var res := Result.new()
	
	var damage_dealt = target.take_damage(source.attack * ratio)
	
	res.source = source
	res.target = target
	res.kind = "attack"
	res.amount = damage_dealt
	res.hp_after = target.hp
	
	return res
