class_name CombatantDef
extends Resource


@export var name: String
@export var max_health: float
@export var max_mana: float
@export var attack: float
@export var basic_attack: Skill
@export var skills: Array[Skill]


func build_combatant() -> Combatant:
	var combatant := Combatant.new(name, max_health, max_mana, attack)
	combatant.basic_attack = basic_attack
	combatant.skills = skills.duplicate()
	return combatant
