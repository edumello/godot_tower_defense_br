extends Panel

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func enable() -> void:
	get_tree().paused = true
	animation_player.play("show")
	

func _hide() -> void:
	get_tree().paused = false
	visible = false

func _on_restart_pressed() -> void:
	_hide()
	var e = get_tree().change_scene_to_file("res://maps/map.tscn")
	if e != OK:
		push_error("Error while changing scene: %s" % str(e))


func _on_exit_pressed() -> void:
	_hide()
	var e = get_tree().change_scene_to_file("res://ui/main_menu.tscn")
	if e != OK:
		push_error("Error while changing scene: %s" % str(e))
