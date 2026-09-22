class_name PartyMember
extends RefCounted


var combatant_def: CombatantDef
var current_health: float


func build_combatant() -> Combatant:
	var combatant := combatant_def.build_combatant()
	combatant.current_health = current_health
	return combatant
