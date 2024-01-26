class_name HUD
extends CanvasLayer

@onready var health_bar := %HealthBar as TextureProgressBar
@onready var money_label := %MoneyLabel as Label
@onready var wave_label := %WaveLabel as Label
@onready var next_wave_panel := %NextWave as Panel
@onready var countdown_label := %Countdown as Label
@onready var next_wave_timer := %Timer as Timer


func initialize(max_helth: int) -> void:
	health_bar.max_value = max_helth
	health_bar.value = health_bar.max_value


func _on_objective_health_changed(cur_health: int) -> void:
	health_bar.value = cur_health


func _on_spawner_countdown_started(seconds: float) -> void:
	next_wave_panel.show()
	next_wave_timer.start(seconds)


func _on_spawner_wave_started(current_wave: int) -> void:
	wave_label.text = "Wave: %d" % current_wave
	

func _process(delta: float) -> void:
	if not next_wave_timer.is_stopped():
		countdown_label.text = str(ceil(next_wave_timer.time_left))
	


func _on_timer_timeout() -> void:
	next_wave_panel.hide()


func _on_money_changed(money: int) -> void:
	money_label.text = str(money)
