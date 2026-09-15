class_name StatusEffect
extends RefCounted


enum Category { NEUTRAL, BUFF, DEBUFF }


var duration: int
var category: Category
var on_apply_effects: Array[Effect]
var on_remove_effects: Array[Effect]
var on_turn_start_effects: Array[Effect]
var on_turn_end_effects: Array[Effect]


func _init(duration: int, category: Category, on_apply_effects: Array[Effect], on_remove_effects: Array[Effect], on_turn_start_effects: Array[Effect], on_turn_end_effects: Array[Effect]) -> void:
	self.duration = duration
	self.category = category
	self.on_apply_effects = on_apply_effects
	self.on_remove_effects = on_remove_effects
	self.on_turn_start_effects = on_turn_start_effects
	self.on_turn_end_effects = on_turn_end_effects


func on_apply(target: Combatant) -> Array[Result]:
	var arr: Array[Result] = []
	for effect in on_apply_effects:
		arr.append_array(effect.apply(null, target))
	return arr


func on_remove(target: Combatant) -> Array[Result]:
	var arr: Array[Result] = []
	for effect in on_remove_effects:
		arr.append_array(effect.apply(null, target))
	return arr


func on_turn_start(target: Combatant) -> Array[Result]:
	var arr: Array[Result] = []
	for effect in on_turn_start_effects:
		arr.append_array(effect.apply(null, target))
	return arr


func on_turn_end(target: Combatant) -> Array[Result]:
	var arr: Array[Result] = []
	for effect in on_turn_end_effects:
		arr.append_array(effect.apply(null, target))
	return arr


func clone() -> StatusEffect:
	var status := StatusEffect.new(duration, category, on_apply_effects, on_remove_effects, on_turn_start_effects, on_turn_end_effects)
	return status
