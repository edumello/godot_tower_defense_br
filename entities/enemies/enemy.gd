class_name Enemy

extends CharacterBody2D

signal enemy_died(enemy: Enemy)
signal enemy_removed # emitted when enemy dies or reaches objective

@export var speed: int = 150
@export var rot_speed := 10.0
@export var health := 100:
	set = set_health
@export var kill_reward := 100

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var default_sound: AudioStreamPlayer2D = $DefaultSound
@onready var state_machine = $StateMachine as StateMachine
@onready var entity_hud: EntityHUD = $UI/EntityHUD



func _ready() -> void:
	var objective: Node2D = $/root/Map/Objective
	nav_agent.set_target_position(objective.global_position)
	nav_agent.max_speed = speed
	entity_hud.health_bar.max_value = health
	entity_hud.health_bar.value = health
	
	var shooter := get_shooter()
	if shooter:
		shooter.has_shot.connect(self._on_shooter_has_shot)


func _move(delta: float) -> void:
	var next_path_pos: Vector2 = nav_agent.get_next_path_position()
	var cur_agent_pos: Vector2 = global_position
	var new_velocity: Vector2 = cur_agent_pos.direction_to(next_path_pos) * speed
	if not nav_agent.avoidance_enabled:
		velocity = new_velocity
		move_and_slide()
	else:
		nav_agent.set_velocity(new_velocity)
	
	animated_sprite_2d.global_rotation = _calculate_rot(animated_sprite_2d.global_rotation, velocity.angle(), rot_speed, delta )
	collision_shape_2d.global_rotation = _calculate_rot(collision_shape_2d.global_rotation, velocity.angle(), rot_speed, delta )
	


func set_health(value: int) -> void:
	health = max(0, value)
	if is_instance_valid(entity_hud):
		entity_hud.health_bar.value = health
	if health == 0:
		state_machine.transition_to("Die")


func die() -> void:
	collision_shape_2d.set_deferred("disabled", true)
	speed = 0
	animated_sprite_2d.play("die")
	default_sound.stop()
	nav_agent.set_velocity(Vector2.ZERO)
	enemy_died.emit(self)
	
	
func play_animation(anim_name: String) -> void:
	animated_sprite_2d.play(anim_name)
	
	
func get_shooter() -> Shooter:
	return null	
	
	
func _calculate_rot(start_rot: float, target_rot: float, _speed: float, delta: float) -> float:
	return lerp_angle(start_rot, target_rot, _speed * delta )


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "die":
		enemy_removed.emit()
		queue_free()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()


func _on_shooter_has_shot(reload_time: float) ->void:
	entity_hud.animate_reload_bar(reload_time)
