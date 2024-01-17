extends Node2D

@onready var tilemap := $TileMap as TileMap
@onready var camera: Camera2D = $Camera2D as Camera2D

func _ready() -> void:
	var map_limits := tilemap.get_used_rect()
	var tile_size := tilemap.tile_set.tile_size
	camera.limit_left = map_limits.position.x * tile_size.x
	camera.limit_top = map_limits.position.y * tile_size.y
	camera.limit_right = map_limits.end.x * tile_size.x
	camera.limit_bottom = map_limits.end.y * tile_size.y
