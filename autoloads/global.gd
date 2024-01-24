extends Node

signal money_changed(money: int)

var money: int:
	set(m):
		money = m
		money_changed.emit(money)


var tower_costs: Dictionary


func _ready() -> void:
	var tower_cost_resource = load("res://entities/towers/tower_cost_json.tres")
	tower_costs = tower_cost_resource.data


