@tool
class_name NPC
extends StaticBody2D


@onready var _animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var _prompt: Label = %Prompt


@export var sprites: SpriteFrames:
	set(value):
		sprites = value
		if Engine.is_editor_hint():
			update_configuration_warnings()
		_update_sprites()

@export var dialogue: Array[String]
@export var heal_player: bool
@export var encounter: Encounter


func _ready() -> void:
	_update_sprites()


func interact() -> void:
	await DialogueBox.show_dialogue(dialogue)
	
	if heal_player:
		for party_member in GameState.party_members:
			party_member.current_health = party_member.combatant_def.max_health
			party_member.current_mana = party_member.combatant_def.max_mana
	
	if encounter:
		GameState.overworld_position = global_position
		GameState.encounter = encounter
		get_tree().change_scene_to_file("uid://dsh8y6ogu1sfl")


func show_prompt() -> void:
	_prompt.visible = true


func hide_prompt() -> void:
	_prompt.visible = false


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array[String] = []
	
	if not sprites or not sprites.has_animation("idle"):
		warnings.append("Missing NPC animations")
	
	return PackedStringArray(warnings)


func _update_sprites() -> void:
	if not is_node_ready():
		return
	
	if not sprites:
		return
	
	_animated_sprite_2d.sprite_frames = sprites
	
	if sprites.has_animation("idle"):
		_animated_sprite_2d.play("idle")
	else:
		if not Engine.is_editor_hint():
			push_error("No NPC idle animation")
