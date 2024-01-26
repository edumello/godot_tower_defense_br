extends Camera2D

@export var min_zoom: float = 0.0
@export var max_zoom: float = 1.0
@export var zoom_rate: float = 16.0
@export var zoom_delta: float = 0.1
@export var fixed_toggle_point: Vector2

@onready var target_zoom: float = zoom.x
@onready var hud: HUD = $HUD


#func _process(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#if event.pressed:
			#if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				#target_zoom = min(target_zoom + zoom_delta, max_zoom)
			#if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				#target_zoom = max(target_zoom - zoom_delta, min_zoom)
			#if event.button_index == MOUSE_BUTTON_MIDDLE:
				#Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		#elif event.button_index == MOUSE_BUTTON_MIDDLE:
			#Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	#if event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
		#position -= event.relative * drag_speed / zoom
		
func _process(delta: float) -> void:
	if Input.is_action_just_released("zoom_in"):
		target_zoom = min(target_zoom + zoom_delta, max_zoom)
	if Input.is_action_just_released("zoom_out"):
		target_zoom = max(target_zoom - zoom_delta, min_zoom)
	if Input.is_action_just_pressed("pan"):
		var ref = get_viewport().get_mouse_position()
		fixed_toggle_point = ref
	
	if Input.is_action_pressed("pan"):
		pan_map_with_mouse()

func pan_map_with_mouse():
	var ref = get_viewport().get_mouse_position()
	position.x -= ((ref.x - fixed_toggle_point.x) / zoom.x)
	position.y -= ((ref.y - fixed_toggle_point.y) / zoom.y)
	fixed_toggle_point = ref


func _physics_process(delta: float) -> void:
	zoom.x = lerp(zoom.x, target_zoom, zoom_rate * delta)
	zoom.y = lerp(zoom.y, target_zoom, zoom_rate * delta)
