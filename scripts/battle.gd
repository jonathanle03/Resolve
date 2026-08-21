extends Node2D


@onready var _battle_view: Node2D = %BattleView


enum BattleStates { START, SELECT, RESOLVE, PRESENT, VICTORY, DEFEAT }
const BLOCKING_STATES := [BattleStates.SELECT, BattleStates.VICTORY, BattleStates.DEFEAT]
var state := BattleStates.START


var ally := Combatant.new("Ally", 250.0, 5.0)
var enemy := Combatant.new("Enemy", 20.0, 2.0)
var ally_damage_effect := DamageEffect.new(ally.attack * 0.5)
var enemy_damage_effect := DamageEffect.new(enemy.attack * 0.5)
var ally_poison_effect := ApplyStatusEffect.new(StatusEffect.new(
	3, [], [], [], [DamageEffect.new(ally.attack * 0.2)]
))
var ally_action := Action.new()
var enemy_action := Action.new()


var ally_team: Array[Combatant]
var enemy_team: Array[Combatant]
var turn_order: Array[Combatant]


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
				actions = [ally_action, enemy_action]
				state = BattleStates.RESOLVE
				
			BattleStates.RESOLVE:
				results = Resolution.resolve(actions)
				state = BattleStates.PRESENT
				
			BattleStates.PRESENT:
				state = await _present(results)
				
			BattleStates.VICTORY:
				get_tree().change_scene_to_file("uid://dsh8y6ogu1sfl")
				
			BattleStates.DEFEAT:
				get_tree().change_scene_to_file("uid://dsh8y6ogu1sfl")
		
		if state in BLOCKING_STATES:
			break


func _battle_start() -> BattleStates:
	ally_action.source = ally
	ally_action.target = enemy
	ally_action.effects.append(ally_damage_effect)
	ally_action.effects.append(ally_poison_effect)
	ally_team.append(ally)
	
	enemy_action.source = enemy
	enemy_action.target = ally
	enemy_action.effects.append(enemy_damage_effect)
	enemy_team.append(enemy)
	
	turn_order.append(ally)
	turn_order.append(enemy)
	
	_battle_view.setup(ally_team, enemy_team)
	
	return BattleStates.SELECT


func _present(results: Array[Result]) -> BattleStates:
	# TODO: Replace this with Presentation phase
	for result in results:
		prints(
			result.source.name if result.source else null,
			result.target.name if result.target else null,
			Result.ResultKind.keys()[result.kind],
			result.amount,
			result.hp_after
		)
	
	await _battle_view.present(results)
	
	var all_allies_defeated := true
	for ally_unit in ally_team:
		if not ally_unit.is_dead:
			all_allies_defeated = false
	
	var all_enemies_defeated := true
	for enemy_unit in enemy_team: # Change back to "enemy" later
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
