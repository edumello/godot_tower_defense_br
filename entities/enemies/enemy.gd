class_name Enemy

extends CharacterBody2D

@export var speed: int = 150
@export var health := 100:
	set = set_health

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var default_sound: AudioStreamPlayer2D = $DefaultSound



func _ready() -> void:
	nav_agent.max_speed = speed

	var objective: Node2D = $/root/Map/Objective
	nav_agent.set_target_position(objective.global_position)

func _physics_process(delta: float) -> void:
	var next_path_pos: Vector2 = nav_agent.get_next_path_position()
	var cur_agent_pos: Vector2 = global_position
	var new_velocity: Vector2 = cur_agent_pos.direction_to(next_path_pos) * speed
	velocity = new_velocity
	move_and_slide()


func set_health(value: int) -> void:
	health = max(0, value)
	if health == 0:
		die()
			
func die() -> void:
	collision_shape_2d.set_deferred("disabled", true)
	speed = 0
	animated_sprite_2d.play("die")
	default_sound.stop()


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "die":
		queue_free()
