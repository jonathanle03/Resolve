class_name Combatant
extends RefCounted


enum Stat { ATTACK }


var name: String
var max_health: float
var current_health: float
var attack: float
var status_effects: Array[StatusEffect]
var is_dead: bool


func _init(name: String, max_health: float, attack: float, current_health: float = -1.0) -> void:
	self.name = name
	self.max_health = max_health
	self.current_health = current_health if current_health >= 0.0 else max_health
	self.attack = attack
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
