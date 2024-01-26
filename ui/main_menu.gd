extends Control

@onready var main_panel: Panel = $Panel
@onready var how_to_play: Panel = $HowToPlay



func _on_start_pressed() -> void:
	var e = get_tree().change_scene_to_file("res://maps/map.tscn")
	if e != OK:
		print("Error while changing scene: %s" % str(e))
		push_error("Error while changing scene: %s" % str(e))


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_how_to_play_pressed() -> void:
	how_to_play.show()
	main_panel.hide()


func _on_back_pressed() -> void:
	how_to_play.hide()
	main_panel.show()
