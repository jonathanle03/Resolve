class_name BattleView
extends Node2D


signal skill_chosen(skill: Skill)
signal target_chosen(target: Combatant)
signal cancel


enum Motion { UP, DOWN, ARC }


@onready var _v_box_container: VBoxContainer = %VBoxContainer


@onready var _enemy_1_marker: Marker2D = %Enemy1Marker
@onready var _enemy_2_marker: Marker2D = %Enemy2Marker
@onready var _enemy_3_marker: Marker2D = %Enemy3Marker
@onready var _ally_1_marker: Marker2D = %Ally1Marker
@onready var _ally_2_marker: Marker2D = %Ally2Marker
@onready var _ally_3_marker: Marker2D = %Ally3Marker


const COMBATANT := preload("uid://s15n5wdul107")
const BATTLE_BUTTON := preload("uid://lmeawgpaf568")


var combatant_node_map: Dictionary[Combatant, CombatantView] = {}
var ally_markers: Array[Marker2D]
var enemy_markers: Array[Marker2D]


func _ready() -> void:
	ally_markers = [_ally_1_marker, _ally_2_marker, _ally_3_marker]
	enemy_markers = [_enemy_1_marker, _enemy_2_marker,_enemy_3_marker]


func setup(allies: Array[Combatant], enemies: Array[Combatant]) -> void:
	create_team_nodes(allies, ally_markers, true)
	create_team_nodes(enemies, enemy_markers)


func create_team_nodes(team: Array[Combatant], markers: Array[Marker2D], mirrored: bool = false) -> void:
	for i in range(len(team)):
		var combatant := team[i]
		var combatant_node: CombatantView = COMBATANT.instantiate()
		add_child(combatant_node)
		combatant_node_map[combatant] = combatant_node
		
		combatant_node.set_max_health(combatant.max_health)
		combatant_node.set_health(combatant.current_health)
		combatant_node.set_max_mana(combatant.max_mana)
		combatant_node.set_mana(combatant.current_mana)
		combatant_node.position = markers[i].position
		if mirrored:
			combatant_node.mirror()
		
		combatant_node.target_node_chosen.connect(
			func(_target_node: CombatantView) -> void:
				target_chosen.emit(combatant)
		)


func present(results: Array[Result]) -> void:
	for result in results:
		var source := result.source
		var target := result.target
		
		match result.kind:
			Result.ResultKind.DAMAGE:
				if source:
					await combatant_node_map[source].attack_animation(combatant_node_map[target])
				
				combatant_node_map[target].attacked_animation()
				combatant_node_map[target].set_health(result.health_after)
				await combatant_node_map[target].create_floating_text(str(result.amount), Color.RED, Motion.UP)
				
				if source:
					await combatant_node_map[source].fallback_animation(combatant_node_map[target])
				
			Result.ResultKind.HEAL:
				combatant_node_map[target].set_health(result.health_after)
				await combatant_node_map[target].create_floating_text(str(result.amount), Color.GREEN, Motion.UP)
				
			Result.ResultKind.STATUS_APPLIED:
				var text: String
				var color: Color
				var motion: Motion
				
				if result.status.category == StatusEffect.Category.BUFF:
					text = "▲"
					color = Color.ORANGE
					motion = Motion.UP
				elif result.status.category == StatusEffect.Category.DEBUFF:
					text = "▼"
					color = Color.NAVY_BLUE
					motion = Motion.DOWN
				else:
					text = "■"
					color = Color.GRAY
					motion = Motion.ARC
				
				await combatant_node_map[target].create_floating_text(text, color, motion)
			
			Result.ResultKind.DEATH:
				await combatant_node_map[target].death_animation()
			
			Result.ResultKind.MANA_CHANGED:
				combatant_node_map[target].set_mana(result.mana_after)
			
			_:
				pass


func show_battle_menu(combatant: Combatant) -> void:
	var attack_button: BattleButton = BATTLE_BUTTON.instantiate()
	_v_box_container.add_child(attack_button)
	
	attack_button.set_labels("Attack", "")
	attack_button.set_binding(skill_chosen.emit.bind(combatant.basic_attack))
	
	var skills_button: BattleButton = BATTLE_BUTTON.instantiate()
	_v_box_container.add_child(skills_button)
	
	skills_button.set_labels("Skills", "")
	skills_button.set_binding(
		func():
			hide_battle_menu()
			show_skill_menu(combatant)
	)
	
	_v_box_container.visible = true


func show_skill_menu(combatant: Combatant) -> void:
	var skills := combatant.skills
	
	for skill in skills:
		var skill_button: BattleButton = BATTLE_BUTTON.instantiate()
		_v_box_container.add_child(skill_button)
		
		skill_button.set_labels(skill.name, "%.1f" % skill.mana_cost)
		skill_button.set_binding(skill_chosen.emit.bind(skill))
		
		if combatant.current_mana < skill.mana_cost:
			skill_button.disable_button()
	
	var back_button: BattleButton = BATTLE_BUTTON.instantiate()
	_v_box_container.add_child(back_button)
	
	back_button.set_labels("Back", "")
	back_button.set_binding(
		func():
			hide_battle_menu()
			show_battle_menu(combatant)
	)
	
	_v_box_container.visible = true


func hide_battle_menu() -> void:
	for button in _v_box_container.get_children():
		_v_box_container.remove_child(button)
		button.queue_free()
	_v_box_container.visible = false


func show_targeting_menu(skill: Skill, source: Combatant, valid_targets: Array[Combatant]) -> void:
	for target in valid_targets:
		combatant_node_map[target].enable_click()
	
	var back_button: BattleButton = BATTLE_BUTTON.instantiate()
	_v_box_container.add_child(back_button)
	
	back_button.set_labels("Back", "")
	back_button.set_binding(
		func():
			hide_targeting_menu()
			cancel.emit()
	)
	
	_v_box_container.visible = true


func hide_targeting_menu() -> void:
	for node in combatant_node_map.values():
		node.disable_click()
	hide_battle_menu()
