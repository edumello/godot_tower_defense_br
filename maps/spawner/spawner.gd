class_name Spawner
extends Node2D

signal countdown_started(seconds: float)
signal wave_started(current_wave: int)
signal enemy_spawned(enemy: Enemy)
signal enemies_defeated

@export_range(0.5, 5.0, 0.5) var spawn_rate : float = 2.0
@export var wave_count := 3
@export var enemies_per_wave_count := 10
@export var spawn_probabilities := {
	"lumberjackman":  100,
}

var spawn_containers := []
var spawn_locations := []
var current_wave := 0
var current_enemy_count := 0
var enemy_scenes := {
	"lumberjackman": preload("res://entities/enemies/infantry/lumberjackman.tscn")
}

var _enemy_removed_count := 0
var enemy_buff := {
	"health" : 1.3,
}

@onready var wave_timer : Timer = $WaveTimer as Timer
@onready var spawn_timer: Timer = $SpawnTimer as Timer
@onready var spawn_container: Node2D = $SpawnContainer as Node2D

func _ready() -> void:
	for spawnContainer in get_children():
		if spawnContainer is Node2D:
			spawn_containers.append(spawnContainer) 
	set_spawn_locations()
	wave_timer.start()

	await owner.ready #wait for parent node to be ready, allowing it to capture the signal
	countdown_started.emit(wave_timer.time_left)


func set_spawn_locations() -> void:
	if spawn_containers.size() > 0:
		spawn_locations = []
		for marker in spawn_containers.pop_front().get_children():
			spawn_locations.append(marker)

func _start_wave() -> void:
	current_wave += 1
	spawn_timer.start()
	current_enemy_count = 0
	wave_started.emit(current_wave)

func _on_wave_timer_timeout() -> void:
	_start_wave() 
	
func _spawn_new_enemy(enemy_name: String) -> void:
	var enemy: Enemy = enemy_scenes[enemy_name].instantiate()
	if current_wave > 1:
		enemy.health = enemy.health * enemy_buff["health"] * (current_wave - 1) 
	get_parent().add_child(enemy)
	var spawner_marker = spawn_locations.pick_random()
	enemy.global_position = spawner_marker.global_position
	current_enemy_count += 1
	enemy_spawned.emit(enemy)
	enemy.enemy_removed.connect(_on_enemy_removed)
	
func _end_wave() -> void:
	#if current_wave < wave_count: # controlado pelo mapa
	wave_timer.start()
	countdown_started.emit(wave_timer.time_left)
		
		
func _on_spawn_timer_timeout() -> void:
	if current_enemy_count < enemies_per_wave_count:
		_spawn_new_enemy("lumberjackman")
		var spawn_delay : float = randf_range(spawn_rate / 2.0, spawn_rate)
		spawn_timer.start(spawn_delay)
	else:
		_end_wave()

func _on_enemy_removed() -> void:
	_enemy_removed_count += 1
	if _enemy_removed_count == wave_count * enemies_per_wave_count:
		enemies_defeated.emit()
		_resetSpawner()
		set_spawn_locations()
		enemy_buff["health"] = enemy_buff["health"] * 1.1
		Global.money += (Global.money * 0.1) + 200
		
func _resetSpawner() -> void:
		_enemy_removed_count = 0
