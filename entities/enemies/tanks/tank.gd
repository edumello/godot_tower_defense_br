class_name tank
extends Enemy

@onready var shooter: = $Shooter as Shooter

func die() -> void:
	super.die()
	shooter.die()


func get_shooter() -> Shooter:
	return $Shooter
