class_name Helicopter
extends Enemy

@onready var shooter: Shooter = $Shooter
@onready var rotor: AnimatedSprite2D = $Rotor
@onready var shadow: AnimatedSprite2D = $Shadow

func get_shooter() -> Shooter:
	return shooter

func die() ->void:
	super()
	shooter.die()
	$Explosion/AnimationPlayer.play("default_explosion")

func _process(delta: float) -> void:
	shooter.global_rotation = animated_sprite_2d.global_rotation
	rotor.global_rotation = animated_sprite_2d.global_rotation
	shadow.global_rotation = animated_sprite_2d.global_rotation
