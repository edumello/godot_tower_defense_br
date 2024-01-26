class_name SubMap
extends Node2D

signal map_started(SubMap)
signal map_restored(SubMap)

@onready var background_d: TextureRect = $BackgroundD
@onready var background_l: TextureRect = $BackgroundL

@export var map_state = false
@export var map_name : String


func _ready() -> void:
	if map_state:
		start_map()
	else: 
		hide_map()
		

func restore_map() -> void:
	background_d.visible = false
	background_l.visible = true
	map_state = true
	visible = true
	map_restored.emit(self)

func hide_map() -> void:
	background_d.visible = false
	background_l.visible = false
	map_state = false
	visible = false


func start_map() -> void:
	background_d.visible = true
	background_l.visible = false
	visible = true
	map_state = true
	map_started.emit(self)

