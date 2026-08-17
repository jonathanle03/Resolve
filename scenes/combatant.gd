class_name Combatant
extends RefCounted


var name: String
var max_hp: float
var hp: float
var attack: float
var status_effects: Array[StatusEffect]
var is_dead: bool


func _init(name: String, max_hp: float, attack: float) -> void:
	self.name = name
	self.max_hp = max_hp
	self.hp = max_hp
	self.attack = attack
	status_effects = []
	is_dead = false


func take_damage(amount: float) -> float:
	var prev_hp = hp
	hp -= amount
	hp = maxf(0, hp)
	is_dead = hp == 0
	return prev_hp - hp
