extends Node2D


@onready var _battle_view: BattleView = %BattleView


enum BattleStates { START, RESOLVE_TURN_START, PRESENT_TURN_START, SELECT_ACTION, SELECT_TARGET, RESOLVE, PRESENT, VICTORY, DEFEAT }
const BLOCKING_STATES := [BattleStates.VICTORY, BattleStates.DEFEAT]
var state := BattleStates.START


var current_combatant: Combatant
var is_player_turn: bool
var chosen_skill: Skill
var chosen_targets: Array[Combatant]


var ally_team: Array[Combatant]
var enemy_team: Array[Combatant]
var turn_order: Array[Combatant]


var party_member_map: Dictionary[PartyMember, Combatant]


func _ready() -> void:
	advance()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not event.is_echo() and (state == BattleStates.DEFEAT):
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
					state = BattleStates.SELECT_ACTION
			
			BattleStates.SELECT_ACTION:
				if is_player_turn and chosen_skill == null:
					_battle_view.show_battle_menu(current_combatant)
					break
				
				# Enemy randomly chooses a skill or basic attack
				if not is_player_turn:
					var valid_skills: Array[Skill] = [current_combatant.basic_attack]
					for skill in current_combatant.skills:
						if current_combatant.current_mana >= skill.mana_cost:
							valid_skills.append(skill)
					chosen_skill = valid_skills.pick_random()
				
				state = BattleStates.SELECT_TARGET
			
			BattleStates.SELECT_TARGET:
				if not chosen_skill:
					state = BattleStates.SELECT_ACTION
					break
				elif not is_player_turn:
					var valid_targets := _get_targets(chosen_skill, current_combatant, enemy_team, ally_team)
					if chosen_skill.target_type == Skill.TargetType.ENEMY:
						chosen_targets = [valid_targets.pick_random()]
				elif chosen_targets.is_empty():
					var valid_targets := _get_targets(chosen_skill, current_combatant, ally_team, enemy_team)
					if chosen_skill == current_combatant.basic_attack:
						_battle_view.show_targeting_menu(chosen_skill, current_combatant, valid_targets)
					else:
						_battle_view.show_targeting_menu(chosen_skill, current_combatant, valid_targets)
					break
				
				actions = _create_actions(chosen_skill, current_combatant, chosen_targets)
				chosen_skill = null
				chosen_targets = []
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
					_battle_view.show_victory_screen()
					state = BattleStates.VICTORY
				else:
					state = BattleStates.RESOLVE_TURN_START
			
			BattleStates.VICTORY:
				pass
			
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
	_battle_view.target_chosen.connect(_on_target_chosen)
	_battle_view.cancel.connect(_on_cancel)
	_battle_view.continue_to_overworld.connect(_on_continue_to_overworld)


func _create_actions(skill: Skill, source: Combatant, targets: Array[Combatant]) -> Array[Action]:
	var actions: Array[Action] = []
	
	# Update when a skill can produce multiple actions
	var action := Action.new()
	action.source = source
	action.targets = targets
	action.mana_cost = skill.mana_cost
	action.effects = skill.effects
	actions.append(action)
	
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


func _get_targets(skill: Skill, source: Combatant, allies: Array[Combatant], enemies: Array[Combatant]) -> Array[Combatant]:
	var valid_targets: Array[Combatant]
	match skill.target_type:
		Skill.TargetType.SELF:
			valid_targets = [source]
		Skill.TargetType.ENEMY:
			for enemy in enemies:
				if not enemy.is_dead:
					valid_targets.append(enemy)
		_:
			push_error("Invalid target type")
	return valid_targets


func _on_skill_chosen(skill: Skill) -> void:
	if state != BattleStates.SELECT_ACTION:
		return
	_battle_view.hide_battle_menu()
	chosen_skill = skill
	advance()


func _on_target_chosen(target: Combatant) -> void:
	if state != BattleStates.SELECT_TARGET:
		return
	_battle_view.hide_targeting_menu()
	chosen_targets = [target]
	advance()


func _on_cancel() -> void:
	chosen_skill = null
	state = BattleStates.SELECT_ACTION
	advance()


func _on_continue_to_overworld() -> void:
	for party_member in GameState.party_members:
		party_member.current_health = party_member_map[party_member].current_health
		party_member.current_mana = party_member_map[party_member].current_mana
	GameState.returning_from_battle = true
	get_tree().change_scene_to_file("uid://br1ry85r6s0ql")
