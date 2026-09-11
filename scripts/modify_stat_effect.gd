class_name ModifyStatEffect
extends Effect


var stat: Combatant.Stat
var amount: float


func _init(stat: Combatant.Stat, amount: float) -> void:
	self.stat = stat
	self.amount = amount


func apply(source: Combatant, target: Combatant) -> Array[Result]:
	match stat:
		Combatant.Stat.ATTACK:
			target.attack += amount
	
	return []
