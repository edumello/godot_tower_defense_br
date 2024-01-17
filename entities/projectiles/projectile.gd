class_name Projectile
extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_vfx: AnimatedSprite2D = $HitVfx
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hit_sound: AudioStreamPlayer2D = $HitSound

var speed: int
var damage: int
var velocity: Vector2

func start(_position: Vector2, _rotation: float, _speed: int, _damage: int) -> void:
	global_position = _position
	rotation = _rotation
	speed = _speed
	damage = _damage
	velocity = Vector2.RIGHT.rotated(_rotation) * speed

func _physics_process(delta: float) -> void:
	global_position += velocity * delta

func _explode() -> void:
	set_physics_process(false)
	collision_shape.set_deferred("disabled", true)
	animated_sprite_2d.hide()
	hit_vfx.show()
	hit_vfx.play("hit")
	hit_sound.play()


func _on_hit_vfx_animation_finished() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		(body as Enemy).health -= damage
		_explode()


func _on_lifetime_timer_timeout() -> void:
	queue_free()
