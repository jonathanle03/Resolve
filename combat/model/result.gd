class_name Result
extends RefCounted


enum ResultKind { NONE, DAMAGE, HEAL, STATUS_APPLIED, DEATH }


var source: Combatant
var target: Combatant
var kind: ResultKind
var amount: float
var health_after: float
var status: StatusEffect
