class_name tank
extends Enemy

@onready var shooter: = $Shooter as Shooter

func die() -> void:
	super.die()
	shooter.die()
	$Explosion/AnimationPlayer.play("default_explosion")

func get_shooter() -> Shooter:
	return $Shooter
