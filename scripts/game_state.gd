extends Node


var overworld_position: Vector2
var party_members: Array[PartyMember]
var enemies: Array[Combatant]
var battle_outcome: String # Change to enum when we make it
var returning_from_battle := false
