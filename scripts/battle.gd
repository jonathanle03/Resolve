extends Node2D


@onready var _battle_view: Node2D = %BattleView


enum BattleStates { START, RESOLVE_TURN_START, PRESENT_TURN_START, SELECT, RESOLVE, PRESENT, VICTORY, DEFEAT }
const BLOCKING_STATES := [BattleStates.VICTORY, BattleStates.DEFEAT]
var state := BattleStates.START


var current_combatant: Combatant
var is_player_turn := false


var ally_team: Array[Combatant]
var enemy_team: Array[Combatant]
var turn_order: Array[Combatant]


var party_member_map: Dictionary[PartyMember, Combatant]


func _ready() -> void:
	advance()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not event.is_echo() and (state in BLOCKING_STATES or (state == BattleStates.SELECT and is_player_turn)):
		advance()


func advance() -> void:
	var actions: Array[Action]
	var results: Array[Result]
	
	while (true):
		match state:
			BattleStates.START:
				_battle_start()
				state = BattleStates.RESOLVE_TURN_START
			
			BattleStates.RESOLVE_TURN_START:
				_set_next_combatant()
				results = Resolution.resolve_turn_start(current_combatant)
				state = BattleStates.PRESENT_TURN_START
			
			BattleStates.PRESENT_TURN_START:
				await _present(results)
				
				if _is_team_dead(ally_team):
					print("Game Over!")
					state = BattleStates.DEFEAT
				elif _is_team_dead(enemy_team):
					print("Victory!")
					state = BattleStates.VICTORY
				elif current_combatant.is_dead:
					state = BattleStates.RESOLVE_TURN_START
				else:
					state = BattleStates.SELECT
					if is_player_turn:
						break
			
			BattleStates.SELECT:
				actions = _select_actions(current_combatant)
				state = BattleStates.RESOLVE
				
			BattleStates.RESOLVE:
				results = Resolution.resolve(actions)
				state = BattleStates.PRESENT
			
			BattleStates.PRESENT:
				await _present(results)
				if _is_team_dead(ally_team):
					print("Game Over!")
					state = BattleStates.DEFEAT
				elif _is_team_dead(enemy_team):
					print("Victory!")
					state = BattleStates.VICTORY
				else:
					state = BattleStates.RESOLVE_TURN_START
				
			BattleStates.VICTORY:
				for party_member in GameState.party_members:
					party_member.current_health = party_member_map[party_member].current_health
				GameState.returning_from_battle = true
				get_tree().change_scene_to_file("uid://mtwtyjlq7lkx")
				
			BattleStates.DEFEAT:
				get_tree().change_scene_to_file("uid://chn2oyk85qt5m")
		
		if state in BLOCKING_STATES:
			break


func _battle_start() -> void:
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


# TODO: Update when enemy resources or skill selection are implemented
func _select_actions(combatant: Combatant) -> Array[Action]:
	var actions: Array[Action] = []
	
	if combatant in ally_team:
		var ally_action := Action.new()
		ally_action.source = combatant
		ally_action.target = enemy_team[0]

		var ally_damage_effect := DamageEffect.new(combatant.attack)
		var ally_poison_effect := ApplyStatusEffect.new(StatusEffect.new(
			3, StatusEffect.Category.NEUTRAL, [], [], [], [DamageEffect.new(combatant.attack * 0.2)]
		))
		ally_action.effects.append(ally_damage_effect)
		ally_action.effects.append(ally_poison_effect)
		
		actions.append(ally_action)
	
	if combatant in enemy_team:
		var enemy_damage_action := Action.new()
		var enemy_damage_effect := DamageEffect.new(combatant.attack)
		enemy_damage_action.source = combatant
		enemy_damage_action.target = ally_team[0]
		enemy_damage_action.effects.append(enemy_damage_effect)
		
		var enemy_heal_action := Action.new()
		var enemy_heal_effect := HealEffect.new(combatant.attack * 0.5)
		enemy_heal_action.source = combatant
		enemy_heal_action.target = combatant
		enemy_heal_action.effects.append(enemy_heal_effect)
		
		var enemy_attack_buff_action := Action.new()
		var enemy_attack_buff_effect := ApplyStatusEffect.new(StatusEffect.new(
			3, StatusEffect.Category.BUFF, [ModifyStatEffect.new(Combatant.Stat.ATTACK, 2)], [ModifyStatEffect.new(Combatant.Stat.ATTACK, -2)], [], []
		))
		enemy_attack_buff_action.source = combatant
		enemy_attack_buff_action.target = combatant
		enemy_attack_buff_action.effects.append(enemy_attack_buff_effect)
		
		var enemy_attack_debuff_action := Action.new()
		var enemy_attack_debuff_effect := ApplyStatusEffect.new(StatusEffect.new(
			3, StatusEffect.Category.DEBUFF, [ModifyStatEffect.new(Combatant.Stat.ATTACK, -2)], [ModifyStatEffect.new(Combatant.Stat.ATTACK, 2)], [], []
		))
		enemy_attack_debuff_action.source = combatant
		enemy_attack_debuff_action.target = ally_team[0]
		enemy_attack_debuff_action.effects.append(enemy_attack_debuff_effect)
		
		var enemy_skills: Array[Action] = [enemy_damage_action, enemy_heal_action, enemy_attack_buff_action, enemy_attack_debuff_action]
		actions.append(enemy_skills.pick_random())
	
	return actions


func _present(results: Array[Result]) -> void:
	for result in results:
		prints(
			result.source.name if result.source else null,
			result.target.name if result.target else null,
			Result.ResultKind.keys()[result.kind],
			result.amount,
			result.health_after
		)
	
	await _battle_view.present(results)


func _is_team_dead(team: Array[Combatant]) -> bool:
	var res := true
	for combatant in team:
		if not combatant.is_dead:
			res = false
			break
	return res


func _set_next_combatant() -> void:
	if current_combatant:
		turn_order.pop_front()
		turn_order.append(current_combatant)
	current_combatant = turn_order[0]
	
	while current_combatant.is_dead:
		turn_order.pop_front()
		turn_order.append(current_combatant)
		current_combatant = turn_order[0]
	is_player_turn = current_combatant in ally_team
