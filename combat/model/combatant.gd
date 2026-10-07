class_name Combatant
extends RefCounted


enum Stat { ATTACK }


var name: String

var max_health: float:
	set(value):
		max_health = maxf(0.0, value)
		self.current_health = current_health
var current_health: float:
	set(value):
		current_health = minf(value, max_health)
		is_dead = current_health <= 0.0
var is_dead: bool

var max_mana: float:
	set(value):
		max_mana = maxf(0.0, value)
		self.current_mana = current_mana
var current_mana: float:
	set(value):
		current_mana = minf(value, max_mana)

var attack: float

var basic_attack: Skill
var skills: Array[Skill]

var status_effects: Array[StatusEffect]


func _init(combatant_name: String, combatant_max_health: float, combatant_max_mana: float, combatant_attack: float) -> void:
	name = combatant_name
	max_health = combatant_max_health
	current_health = max_health
	max_mana = combatant_max_mana
	current_mana = max_mana
	attack = combatant_attack
	status_effects = []


func take_damage(amount: float) -> float:
	var prev_health = current_health
	current_health -= amount
	return prev_health - current_health


func heal_health(amount: float) -> float:
	var prev_health = current_health
	current_health += amount
	return current_health - prev_health
