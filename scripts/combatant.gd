class_name Combatant
extends RefCounted


var name: String
var max_health: float
var current_health: float
var attack: float
var status_effects: Array[StatusEffect]
var is_dead: bool


func _init(name: String, max_health: float, current_health: float, attack: float) -> void:
	self.name = name
	self.max_health = max_health
	self.current_health = current_health
	self.attack = attack
	status_effects = []
	is_dead = false


func take_damage(amount: float) -> float:
	var prev_health = current_health
	current_health -= amount
	current_health = maxf(0, current_health)
	is_dead = current_health == 0
	return prev_health - current_health
