class_name Shooter
extends Node2D

signal has_shot(reload_time: float)

@export var fire_rate := 0.1
@export var rot_speed := 5.0
@export var projectile_type: PackedScene
@export var projectile_speed := 1000
@export var projectile_damage := 3

var targets : Array[Node2D]
var can_shoot := true
var map: Node
var has_body := false
var body 

@onready var gun: AnimatedSprite2D = $Gun as AnimatedSprite2D
@onready var muzzle_flash: AnimatedSprite2D = $MuzzleFlash as AnimatedSprite2D
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound as AudioStreamPlayer2D
@onready var lookahead: RayCast2D = $LookAhead as RayCast2D
@onready var firerate_timer: Timer = $FireRateTimer as Timer

func _ready() -> void:
	map = find_parent("Map")
	#body = get_parent()
	#if body is Enemy:
		#has_body = true
		#body = get_parent() as Enemy

func _rotate_shooter(delta: float) -> void:
	if not targets.is_empty():
		var target_pos: Vector2 = targets.front().global_position
		var xpto = (target_pos - global_position).normalized().x
		#body_rotate
		if xpto > 0:
			get_parent().scale.x = -1
		else: 
			get_parent().scale.x = 1


func should_shoot() -> bool:
	return can_shoot and not targets.is_empty()


func shoot() -> void:
	can_shoot = false
	for _muzzle in gun.get_children():
		_instantiate_projectile(_muzzle.global_position, targets.front())
	_play_animations("shoot")
	shoot_sound.play()
	firerate_timer.start(fire_rate)
	has_shot.emit(firerate_timer.wait_time)
	

func die() -> void:
	set_physics_process(false)
	can_shoot = false
	firerate_timer.stop()
	muzzle_flash.hide()
	gun.play("die")

	
func is_objective_in_range() -> bool:
	for target in targets:
		if target is Objective:
			return true
	return false
	
	
func _instantiate_projectile(_position: Vector2, target: Node2D) -> void:
	var projectile: Projectile = projectile_type.instantiate()
	var rot = _position.direction_to(target.global_position + Vector2(0,-300)).angle()
	projectile.start(_position, rot, projectile_speed, projectile_damage, target)
	projectile.collision_mask = $Detector.collision_mask
	if map: 
		map.add_child(projectile)
	else:
		owner.add_child(projectile)
		

func _play_animations(anim_name: String) -> void:
	gun.frame = 0
	muzzle_flash.frame = 0
	gun.play(anim_name)
	muzzle_flash.play(anim_name)


func _on_detector_body_entered(body: Node2D) -> void:
	if body not in targets:
		targets.append(body)


func _on_detector_body_exited(body: Node2D) -> void:
	if body in targets:
		targets.erase(body)


func _on_detector_area_entered(area: Area2D) -> void:
	if area not in targets:
		targets.append(area)


func _on_detector_area_exited(area: Area2D) -> void:
	if area in targets:
		targets.erase(area)


func _on_fire_rate_timer_timeout() -> void:
	can_shoot = true


func _on_gun_animation_finished() -> void:
	if gun.animation.contains("shoot"):
		_play_animations("idle")
