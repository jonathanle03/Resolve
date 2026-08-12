class_name StatusEffect
extends RefCounted


var duration: int
var on_apply_effects: Array[Effect]
var on_remove_effects: Array[Effect]
var on_turn_start_effects: Array[Effect]
var on_turn_end_effects: Array[Effect]


func _init(on_turn_end_effects: Array[Effect]) -> void:
	self.on_turn_end_effects = on_turn_end_effects


func on_apply(target: Combatant) -> Array[Result]:
	var arr: Array[Result] = []
	for effect in on_apply_effects:
		arr.append(effect.apply(null, target))
	return arr


func on_remove(target: Combatant) -> Array[Result]:
	var arr: Array[Result] = []
	for effect in on_remove_effects:
		arr.append(effect.apply(null, target))
	return arr


func on_turn_start(target: Combatant) -> Array[Result]:
	var arr: Array[Result] = []
	for effect in on_turn_start_effects:
		arr.append(effect.apply(null, target))
	return arr


func on_turn_end(target: Combatant) -> Array[Result]:
	var arr: Array[Result] = []
	for effect in on_turn_end_effects:
		arr.append(effect.apply(null, target))
	return arr
