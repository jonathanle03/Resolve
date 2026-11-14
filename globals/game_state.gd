extends Node


var overworld_position: Vector2
var party_members: Array[PartyMember]
var encounter: Encounter
var returning_from_battle: bool


func start_new_game() -> void:
	encounter = null
	returning_from_battle = false
	initialize_party()
	get_tree().change_scene_to_file("uid://br1ry85r6s0ql")


func start_battle(prev_position: Vector2, new_encounter: Encounter) -> void:
	overworld_position = prev_position
	encounter = new_encounter
	get_tree().change_scene_to_file("uid://dsh8y6ogu1sfl")


func initialize_party() -> void:
	var party_member := PartyMember.new()
	party_member.combatant_def = load("uid://c4pn2wleqr1c1") as CombatantDef
	party_member.current_health = party_member.combatant_def.max_health
	party_member.current_mana = party_member.combatant_def.max_mana
	party_members = [party_member]


func full_heal_party() -> void:
	for party_member in party_members:
		party_member.full_heal()
