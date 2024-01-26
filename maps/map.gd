extends Node2D

@export var starting_money := 5000

@onready var background: TextureRect = $SubMaps/Map1/BackgroundD
@onready var camera: Camera2D = $Camera2D as Camera2D
@onready var objective := $Objective as Objective
@onready var spawner := $Spawner as Spawner
@onready var sub_maps := $SubMaps as Node2D
@onready var tower_price_label: Label = $Camera2D/HUD/Control/TowerPopup/Background/Panel/Towers/Gatling/Label
@onready var tile_map_exclusion: TileMap = $TileMapExclusion
@onready var tower_preview: Control = $TowerPreview
@onready var towers: Control = $Towers
@onready var buy_btn: Button = $Camera2D/HUD/Control/TowerPopup/Background/Panel/Towers/Gatling/Button


var maps := []
var actual_map : SubMap
var _towers_to_build := {
	"indio": preload("res://entities/towers/indio_tower.tscn")
}
var build_mode := false
var build_valid := false
var build_location : Vector2

func _ready() -> void:
	#maps
	for node_map in sub_maps.get_children():
		maps.append(node_map)
		node_map.map_started.connect(_on_map_started)
		node_map.map_restored.connect(_on_map_restored)
	actual_map = maps.pop_front() as SubMap
	actual_map.start_map()
		
	# initialize camera
	_resize_camera(1)
	
	#update prices
	tower_price_label.text = str(Global.tower_costs["indio"])
	
	#initialize money and connect signals
	var hud = camera.hud as HUD
	Global.money_changed.connect(hud._on_money_changed)
	Global.money = starting_money
	hud.initialize(objective.health)
	objective.health_changed.connect(hud._on_objective_health_changed)
	objective.objective_destroyed.connect(_on_objective_destroyed)
	spawner.countdown_started.connect(hud._on_spawner_countdown_started)
	spawner.wave_started.connect(hud._on_spawner_wave_started)
	spawner.enemy_spawned.connect(_on_enemy_spawned)
	spawner.enemies_defeated.connect(_on_enemies_defeated)

	

func _resize_camera(level: int) -> void:
	var background_limits := background.get_rect()
	var background_size := background.size
	camera.limit_left = background_limits.position.x * background_size.x
	camera.limit_top = background_limits.position.y * background_size.y
	camera.limit_right = background_limits.end.x * level
	camera.limit_bottom = background_limits.end.x * level

	
func _on_enemy_spawned(enemy: Enemy) -> void:
	enemy.enemy_died.connect(_on_enemy_died)
	
	
func _on_enemy_died(enemy: Enemy):
	Global.money += enemy.kill_reward


func _game_over() ->void:
	var hud = camera.hud as HUD
	hud.get_node("Menus/GameOver").enable()
	#prevent pausing during game over
	hud.get_node("Menus/Pause").queue_free()


func _on_objective_destroyed()-> void:
	_game_over()


func _on_enemies_defeated()-> void:
	actual_map.restore_map()
	if maps.size() < 1:
		_game_over()


func _on_map_started(sub_map: SubMap) -> void:
		actual_map = sub_map


func _on_map_restored(sub_map: SubMap) -> void:
	#todo: Aviso que passou de fase
	if maps.size() > 0:
		actual_map = maps.pop_front() as SubMap
		actual_map.start_map()
		_resize_camera(int(actual_map.map_name))


func update_tower_preview() -> void:
	var mouse_position = get_global_mouse_position()
	var current_tile = tile_map_exclusion.local_to_map(mouse_position)
	var tile_position = tile_map_exclusion.map_to_local(current_tile)
	tower_preview.global_position = tile_position
	if tile_map_exclusion.get_cell_source_id(0,current_tile) == -1: # verificar impacto?
		build_valid = false
		tower_preview.modulate = Color("ff00008e")
		
	elif is_tile_busy(tile_position):
		build_valid = false
		tower_preview.modulate = Color("ff00008e")
	else:
		build_valid = true
		build_location = tile_position
		tower_preview.modulate = Color("00ff008e")
		

func is_tile_busy(tile_position: Vector2) -> bool:
	for tower in towers.get_children():
		if tower.global_position == tile_position:
			return true
	return false
	

func set_tower_preview():
	var drag_tower = _towers_to_build["indio"].instantiate()
	drag_tower.set_name("DragTower")
	tower_preview.modulate = Color("00ff008e")
	drag_tower.process_mode = Node.PROCESS_MODE_DISABLED
	tower_preview.add_child(drag_tower)
	tower_preview.global_position = get_global_mouse_position()



func _on_button_pressed() -> void: #comprar torre
		if Global.money >= int(tower_price_label.text):
			cancel_build_mode()
			build_mode = true
			set_tower_preview()
		else:

			var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
			buy_btn.modulate = Color("ff383f")
			tween.tween_property(buy_btn, "modulate", Color("fff"), 0.25)	


func _process(delta: float) -> void:
	if build_mode:
		update_tower_preview()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				if build_mode:
					cancel_build_mode()
			elif event.button_index == MOUSE_BUTTON_LEFT:
				if build_mode:
					build_tower()


func cancel_build_mode() ->void :
	build_mode = false
	build_valid = false
	for c in tower_preview.get_children():
		c.queue_free()


func build_tower() -> void:
	if build_mode and build_valid:
		var new_tower = _towers_to_build["indio"].instantiate()
		var mouse_position = get_global_mouse_position()
		var current_tile = tile_map_exclusion.local_to_map(mouse_position)
		var tile_position = tile_map_exclusion.map_to_local(current_tile)
		new_tower.global_position = tile_position
		towers.add_child(new_tower)
		Global.money -= Global.tower_costs["indio"]
		cancel_build_mode()
