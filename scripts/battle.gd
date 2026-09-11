extends Node2D


@onready var _battle_view: Node2D = %BattleView


enum BattleStates { START, SELECT, RESOLVE, PRESENT, VICTORY, DEFEAT }
const BLOCKING_STATES := [BattleStates.SELECT, BattleStates.VICTORY, BattleStates.DEFEAT]
var state := BattleStates.START


var ally_team: Array[Combatant]
var enemy_team: Array[Combatant]
var turn_order: Array[Combatant]


var party_member_map: Dictionary[PartyMember, Combatant]


func _ready() -> void:
	advance()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not event.is_echo() and state in BLOCKING_STATES:
		advance()


func advance() -> void:
	var actions: Array[Action]
	var results: Array[Result]
	
	while (true):
		match state:
			BattleStates.START:
				state = _battle_start()
			
			BattleStates.SELECT:
				actions = _select_actions()
				state = BattleStates.RESOLVE
				
			BattleStates.RESOLVE:
				results = Resolution.resolve(actions)
				state = BattleStates.PRESENT
				
			BattleStates.PRESENT:
				state = await _present(results)
				
			BattleStates.VICTORY:
				for party_member in GameState.party_members:
					party_member.current_health = party_member_map[party_member].current_health
				GameState.returning_from_battle = true
				get_tree().change_scene_to_file("uid://mtwtyjlq7lkx")
				
			BattleStates.DEFEAT:
				get_tree().change_scene_to_file("uid://chn2oyk85qt5m")
		
		if state in BLOCKING_STATES:
			break


func _battle_start() -> BattleStates:
	for party_member in GameState.party_members:
		var ally := party_member.build_combatant()
		ally_team.append(ally)
		party_member_map[party_member] = ally
	
	# TODO: Update when enemy resources are implemented
	for enemy in GameState.enemies:
		var enemy_combatant := Combatant.new(enemy["name"], enemy["max_health"], enemy["attack"])
		enemy_team.append(enemy_combatant)
	
	turn_order.append_array(ally_team)
	turn_order.append_array(enemy_team)
	
	_battle_view.setup(ally_team, enemy_team)
	
	return BattleStates.SELECT


func _select_actions() -> Array[Action]:
	var actions: Array[Action] = []
	
	for ally in ally_team:
		var ally_action := Action.new()
		ally_action.source = ally
		ally_action.target = enemy_team[0]

		var ally_damage_effect := DamageEffect.new(ally.attack)
		var ally_poison_effect := ApplyStatusEffect.new(StatusEffect.new(
			3, [], [], [], [DamageEffect.new(ally.attack * 0.2)]
		))
		ally_action.effects.append(ally_damage_effect)
		ally_action.effects.append(ally_poison_effect)
		
		actions.append(ally_action)
	
	for enemy in enemy_team:
		var enemy_damage_action := Action.new()
		var enemy_damage_effect := DamageEffect.new(enemy.attack)
		enemy_damage_action.source = enemy
		enemy_damage_action.target = ally_team[0]
		enemy_damage_action.effects.append(enemy_damage_effect)
		
		var enemy_heal_action := Action.new()
		var enemy_heal_effect := HealEffect.new(enemy.attack * 0.5)
		enemy_heal_action.source = enemy
		enemy_heal_action.target = enemy
		enemy_heal_action.effects.append(enemy_heal_effect)
		
		var enemy_attack_buff_action := Action.new()
		var enemy_attack_buff_effect := ApplyStatusEffect.new(StatusEffect.new(
			3, [ModifyStatEffect.new(Combatant.Stat.ATTACK, 2)], [ModifyStatEffect.new(Combatant.Stat.ATTACK, -2)], [], []
		))
		enemy_attack_buff_action.source = enemy
		enemy_attack_buff_action.target = enemy
		enemy_attack_buff_action.effects.append(enemy_attack_buff_effect)
		
		var enemy_skills: Array[Action] = [enemy_damage_action, enemy_heal_action, enemy_attack_buff_action]
		actions.append(enemy_skills.pick_random())
	
	return actions


func _present(results: Array[Result]) -> BattleStates:
	for result in results:
		prints(
			result.source.name if result.source else null,
			result.target.name if result.target else null,
			Result.ResultKind.keys()[result.kind],
			result.amount,
			result.health_after
		)
	
	await _battle_view.present(results)
	
	var all_allies_defeated := true
	for ally_unit in ally_team:
		if not ally_unit.is_dead:
			all_allies_defeated = false
	
	var all_enemies_defeated := true
	for enemy_unit in enemy_team:
		if not enemy_unit.is_dead:
			all_enemies_defeated = false
	
	var next_state := BattleStates.SELECT
	
	if all_allies_defeated:
		print("Game Over!")
		next_state = BattleStates.DEFEAT
	elif all_enemies_defeated:
		print("Victory!")
		next_state = BattleStates.VICTORY
	
	return next_state
