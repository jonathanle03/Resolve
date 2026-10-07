extends Node2D


@onready var _battle_view: Node2D = %BattleView


enum BattleStates { START, RESOLVE_TURN_START, PRESENT_TURN_START, SELECT, RESOLVE, PRESENT, VICTORY, DEFEAT }
const BLOCKING_STATES := [BattleStates.VICTORY, BattleStates.DEFEAT]
var state := BattleStates.START


var current_combatant: Combatant = null
var is_player_turn := false
var chosen_skill: Skill = null


var ally_team: Array[Combatant]
var enemy_team: Array[Combatant]
var turn_order: Array[Combatant]


var party_member_map: Dictionary[PartyMember, Combatant]


func _ready() -> void:
	advance()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not event.is_echo() and (state in BLOCKING_STATES):
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
			
			BattleStates.SELECT:
				if is_player_turn and chosen_skill == null:
					_battle_view.show_battle_menu(current_combatant)
					break
				
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
					party_member.current_mana = party_member_map[party_member].current_mana
				GameState.returning_from_battle = true
				get_tree().change_scene_to_file("uid://mtwtyjlq7lkx")
				
			BattleStates.DEFEAT:
				get_tree().change_scene_to_file("uid://chn2oyk85qt5m")
		
		if state in BLOCKING_STATES:
			break


func _battle_start() -> void:
	for party_member in GameState.party_members:
		var ally_combatant := party_member.build_combatant()
		ally_team.append(ally_combatant)
		party_member_map[party_member] = ally_combatant
	
	for enemy in GameState.enemies:
		var enemy_combatant := enemy.build_combatant()
		enemy_team.append(enemy_combatant)
	
	turn_order.append_array(ally_team)
	turn_order.append_array(enemy_team)
	
	_battle_view.setup(ally_team, enemy_team)
	
	_battle_view.skill_chosen.connect(_on_skill_chosen)


func _select_actions(combatant: Combatant) -> Array[Action]:
	var actions: Array[Action] = []
	
	if combatant in ally_team:
		var ally_action := Action.new()
		ally_action.source = combatant
		ally_action.target = _get_target(chosen_skill, combatant, ally_team, enemy_team)
		ally_action.mana_cost = chosen_skill.mana_cost
		ally_action.effects = chosen_skill.effects
		actions.append(ally_action)
		chosen_skill = null
	
	if combatant in enemy_team:
		var valid_skills: Array[Skill] = [combatant.basic_attack]
		for skill in combatant.skills:
			if combatant.current_mana >= skill.mana_cost:
				valid_skills.append(skill)
		
		var random_skill: Skill = valid_skills.pick_random()
		var enemy_action := Action.new()
		enemy_action.source = combatant
		enemy_action.target = _get_target(random_skill, combatant, enemy_team, ally_team)
		enemy_action.mana_cost = random_skill.mana_cost
		enemy_action.effects = random_skill.effects
		actions.append(enemy_action)
	
	return actions


func _present(results: Array[Result]) -> void:
	for result in results:
		if result.source:
			match (result.kind):
				Result.ResultKind.DAMAGE:
					print("%s attacks %s for %.1f damage." % [result.source.name, result.target.name, result.amount])
				Result.ResultKind.HEAL:
					print("%s heals %s for %.1f health." % [result.source.name, result.target.name, result.amount])
				Result.ResultKind.STATUS_APPLIED:
					print("%s applies %s to %s." % [result.source.name, result.status.name, result.target.name])
		else:
			match (result.kind):
				Result.ResultKind.DAMAGE:
					print("%s takes %.1f damage." % [result.target.name, result.amount])
				Result.ResultKind.HEAL:
					print("%s heals for %.1f health." % [result.target.name, result.amount])
				Result.ResultKind.STATUS_APPLIED:
					print("%s is applied to %s." % [result.status.name, result.target.name])
				Result.ResultKind.DEATH:
					print("%s died." % [result.target.name])
	
	print()
	for combatant in ally_team:
		print("%s %.1f / %.1f HP  %.1f / %.1f MP" % [combatant.name, combatant.current_health, combatant.max_health, combatant.current_mana, combatant.max_mana])
	for combatant in enemy_team:
		print("%s %.1f / %.1f HP  %.1f / %.1f MP" % [combatant.name, combatant.current_health, combatant.max_health, combatant.current_mana, combatant.max_mana])
	print()
	
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


func _get_target(skill: Skill, source: Combatant, allies: Array[Combatant], enemies: Array[Combatant]) -> Combatant:
	var target: Combatant
	match skill.target_type:
		Skill.TargetType.SELF:
			target = source
		Skill.TargetType.ENEMY:
			target = enemies[0]
		_:
			push_error("Not a valid target type")
	return target


func _on_skill_chosen(skill: Skill) -> void:
	_battle_view.hide_battle_menu()
	chosen_skill = skill
	advance()
