class_name CombatantDef
extends Resource


@export var name: String
@export var max_health: float
@export var attack: float
@export var skills: Array[Skill]


func build_combatant() -> Combatant:
	var combatant := Combatant.new(name, max_health, attack)
	combatant.skills = skills.duplicate()
	return combatant
