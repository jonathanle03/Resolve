class_name Result
extends RefCounted


enum ResultKind { NONE, DAMAGE, HEAL, STATUS_APPLIED, DEATH, MANA_CHANGED }


var source: Combatant
var target: Combatant
var kind: ResultKind
var amount: float
var health_after: float
var mana_after: float
var status: StatusEffect
