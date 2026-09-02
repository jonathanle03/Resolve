extends Node


var overworld_position: Vector2
var party_members: Array[PartyMember]
var enemies: Array[Dictionary] # TODO: Update when enemy resources are implemented
var returning_from_battle := false
