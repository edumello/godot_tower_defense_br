class_name Tower
extends StaticBody2D

signal tower_destroyed

@export_range(1, 1000) var health: int = 100:
	set = set_health
@export var tower_type: String
@export var detector_color := Color(0, 0, 1.0, 0.1)

var max_health: int
var _is_mouse_hovering := false
	
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var shooter: Shooter = $Shooter
@onready var entity_hud: EntityHUD = $UI/EntityHUD
@onready var detector_shape: CollisionShape2D = $Shooter/Detector/CollisionShape2D


func _ready() -> void:
	max_health = health
	entity_hud.health_bar.max_value = max_health
	entity_hud.health_bar.value = max_health

func _physics_process(delta: float) -> void:
	if shooter.targets.size() > 0:
		shooter._rotate_shooter(delta)
		if shooter.should_shoot():
			shooter.shoot()
			

func _draw() -> void:
	if _is_mouse_hovering:
		draw_circle(Vector2.ZERO, detector_shape.shape.radius, detector_color)

func set_health(value: int) -> void:
	health = max(0, value)
	if is_instance_valid(entity_hud):
		entity_hud.health_bar.value = health
	if health == 0:
		set_physics_process(false)
		collision_shape_2d.set_deferred("disabled", true)
		shooter.die()
		$Explosion/AnimationPlayer.play("default_explosion")
		tower_destroyed.emit()


func repair() -> void:
	health = max_health


func _on_gun_animation_finished() -> void:
	if shooter.gun.animation == "die":
		queue_free()


func _on_shooter_has_shot(reload_time: float) -> void:
	entity_hud.animate_reload_bar(reload_time)


func _on_mouse_entered() -> void:
	_is_mouse_hovering = true
	queue_redraw()


func _on_mouse_exited() -> void:
	_is_mouse_hovering = false
	queue_redraw()
