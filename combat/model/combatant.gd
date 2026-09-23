class_name Combatant
extends RefCounted


enum Stat { ATTACK }


var name: String
var max_health: float
var current_health: float
var attack: float
var skills: Array[Skill]
var status_effects: Array[StatusEffect]
var is_dead: bool


func _init(combatant_name: String, combatant_max_health: float, combatant_attack: float) -> void:
	name = combatant_name
	max_health = combatant_max_health
	current_health = max_health
	attack = combatant_attack
	status_effects = []
	is_dead = false


func take_damage(amount: float) -> float:
	var prev_health = current_health
	current_health -= amount
	current_health = maxf(0, current_health)
	is_dead = current_health == 0
	return prev_health - current_health


func heal_health(amount: float) -> float:
	var prev_health = current_health
	current_health += amount
	current_health = minf(current_health, max_health)
	return current_health - prev_health
