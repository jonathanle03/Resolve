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
	if event.is_action_released("ui_accept") and state in BLOCKING_STATES:
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
				get_tree().change_scene_to_file("uid://br1ry85r6s0ql")
				
			BattleStates.DEFEAT:
				get_tree().change_scene_to_file("uid://dsh8y6ogu1sfl") # Replay battle for now
		
		if state in BLOCKING_STATES:
			break


func _battle_start() -> BattleStates:
	for party_member in GameState.party_members:
		var ally := party_member.build_combatant()
		ally_team.append(ally)
		party_member_map[party_member] = ally
	
	enemy_team = GameState.enemies
	
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

		var ally_damage_effect := DamageEffect.new(ally.attack * 0.5)
		var ally_poison_effect := ApplyStatusEffect.new(StatusEffect.new(
			3, [], [], [], [DamageEffect.new(ally.attack * 0.2)]
		))
		ally_action.effects.append(ally_damage_effect)
		ally_action.effects.append(ally_poison_effect)
		
		actions.append(ally_action)
	
	for enemy in enemy_team:
		var enemy_action := Action.new()
		var enemy_damage_effect := DamageEffect.new(enemy.attack * 0.5)
		enemy_action.source = enemy
		enemy_action.target = ally_team[0]
		enemy_action.effects.append(enemy_damage_effect)
		
		actions.append(enemy_action)
	
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
