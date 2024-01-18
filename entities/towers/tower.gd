class_name Tower
extends StaticBody2D

@export_range(1, 1000) var health: int = 100:
	set = set_health
	
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var shooter: Shooter = $Shooter

func _physics_process(delta: float) -> void:
	if shooter.targets.size() > 0:
		shooter._rotate_shooter(delta)
		if shooter.should_shoot():
			shooter.shoot()

func set_health(value: int) -> void:
	health = max(0, value)
	if health == 0:
		set_physics_process(false)
		collision_shape_2d.set_deferred("disabled", true)
		shooter.die()


func _on_gun_animation_finished() -> void:
	if shooter.gun.animation == "die":
		queue_free()
