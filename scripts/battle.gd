extends Node2D


signal hit_landed(amount: float)


@onready var _battle_view: Node2D = %BattleView

var player := Combatant.new(20.0, 5.0)
var enemy := Combatant.new(10.0, 2.0)
var damage_effect := DamageEffect.new()
var poison_effect := ApplyStatusEffect.new()
var action := Action.new()


func _ready() -> void:
	hit_landed.connect(_battle_view.on_hit_landed)
	
	action.source = player
	action.target = enemy
	action.effects.append(damage_effect)
	action.effects.append(poison_effect)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		for effect in action.effects:
			var result := effect.apply(action.source, action.target)
			if result.kind == "attack":
				hit_landed.emit(result.amount)
				print("Deal %s damage" % result.amount)
			
	elif event.is_action_released("ui_cancel"):
		for status_effect in enemy.status_effects:
			var result := status_effect.tick(enemy)
			print("Deal %s damage" % result.amount)
		
		for status_effect in player.status_effects:
			var result := status_effect.tick(player)
			print("Deal %s damage" % result.amount)
