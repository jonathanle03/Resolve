class_name DamageEffect
extends Effect


var amount: float


func _init(amount: float) -> void:
	self.amount = amount


func apply(source: Combatant, target: Combatant) -> Result:
	var res := Result.new()
	
	var damage_dealt := target.take_damage(amount)
	
	res.source = source
	res.target = target
	res.kind = "attack"
	res.amount = damage_dealt
	res.hp_after = target.hp
	
	return res
