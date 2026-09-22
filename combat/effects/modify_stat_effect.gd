class_name ModifyStatEffect
extends Effect


@export var stat: Combatant.Stat = Combatant.Stat.ATTACK
@export var amount: float = 0.0
	

func apply(source: Combatant, target: Combatant) -> Array[Result]:
	match stat:
		Combatant.Stat.ATTACK:
			target.attack += amount
		_:
			push_error("Invalid stat attempted to be modified")
	
	return []
