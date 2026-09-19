class_name StatusEffect
extends Resource


enum Category { NEUTRAL, BUFF, DEBUFF }


@export var duration: int
@export var category: Category
@export var on_apply_effects: Array[Effect]
@export var on_remove_effects: Array[Effect]
@export var on_turn_start_effects: Array[Effect]
@export var on_turn_end_effects: Array[Effect]


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
	var status := StatusEffect.new()
	status.duration = duration
	status.category = category
	status.on_apply_effects = on_apply_effects
	status.on_remove_effects = on_remove_effects
	status.on_turn_start_effects = on_turn_start_effects
	status.on_turn_end_effects = on_turn_end_effects
	return status
