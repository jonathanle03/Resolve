extends Control


@onready var _play_again_button: Button = %PlayAgainButton


func _ready() -> void:
	_play_again_button.pressed.connect(_on_play_again_button_pressed)


func _on_play_again_button_pressed() -> void:
	var party_member := PartyMember.new()
	party_member.combatant_def = load("uid://c4pn2wleqr1c1") as CombatantDef
	party_member.current_health = party_member.combatant_def.max_health
	party_member.current_mana = party_member.combatant_def.max_mana
	GameState.party_members = [party_member]
	GameState.returning_from_battle = false
	get_tree().change_scene_to_file("uid://br1ry85r6s0ql")
