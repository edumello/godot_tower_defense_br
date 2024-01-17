class_name Enemy

extends CharacterBody2D

@export var speed: int = 150

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D as NavigationAgent2D

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
