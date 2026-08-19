extends Node2D


@onready var _battle_view: Node2D = %BattleView


enum BattleStates { START, SELECT, RESOLVE, PRESENT, VICTORY, DEFEAT }
var state := BattleStates.START


var player := Combatant.new("Player", 250.0, 5.0)
var enemy := Combatant.new("Enemy", 20.0, 2.0)
var player_damage_effect := DamageEffect.new(player.attack * 0.5)
var enemy_damage_effect := DamageEffect.new(enemy.attack * 0.5)
var player_poison_effect := ApplyStatusEffect.new(StatusEffect.new(
	3, [], [], [], [DamageEffect.new(player.attack * 0.2)]
))
var player_action := Action.new()
var enemy_action := Action.new()


var player_team: Array[Combatant]
var enemy_team: Array[Combatant]
var turn_order: Array[Combatant]


func _ready() -> void:
	advance()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		advance()


func advance() -> void:
	var actions: Array[Action]
	var results: Array[Result]
	
	while (true):
		match state:
			BattleStates.START:
				state = _battle_start()
			
			BattleStates.SELECT:
				actions = [player_action, enemy_action]
				state = BattleStates.RESOLVE
				
			BattleStates.RESOLVE:
				results = Resolution.resolve(actions)
				state = BattleStates.PRESENT
				
			BattleStates.PRESENT:
				state = _present(results)
				
			BattleStates.VICTORY:
				get_tree().change_scene_to_file("uid://dsh8y6ogu1sfl")
				
			BattleStates.DEFEAT:
				get_tree().change_scene_to_file("uid://dsh8y6ogu1sfl")
		
		if state == BattleStates.SELECT or state == BattleStates.VICTORY or state == BattleStates.DEFEAT:
			break


func _battle_start() -> BattleStates:
	player_action.source = player
	player_action.target = enemy
	player_action.effects.append(player_damage_effect)
	player_action.effects.append(player_poison_effect)
	player_team.append(player)
	
	enemy_action.source = enemy
	enemy_action.target = player
	enemy_action.effects.append(enemy_damage_effect)
	enemy_team.append(enemy)
	
	turn_order.append(player)
	turn_order.append(enemy)
	
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
	
	var all_allies_defeated := true
	for ally_unit in player_team:
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
