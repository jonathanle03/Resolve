class_name PartyMember
extends RefCounted


var name: String
var max_health: float
var current_health: float
var attack: float


func _init(name: String, max_health: float, attack: float, current_health: float = -1.0) -> void:
	self.name = name
	self.max_health = max_health
	self.current_health = current_health if current_health >= 0.0 else max_health
	self.attack = attack


func build_combatant() -> Combatant:
	return Combatant.new(name, max_health, attack, current_health)
