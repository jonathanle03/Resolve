class_name Skill
extends Resource


enum TargetType { SELF, ENEMY }


@export var name: String
@export var effects: Array[Effect]
@export var target_type: TargetType
