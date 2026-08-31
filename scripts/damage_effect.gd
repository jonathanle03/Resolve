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
	res.kind = Result.ResultKind.DAMAGE
	res.amount = damage_dealt
	res.health_after = target.current_health
	
	return res
