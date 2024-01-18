extends State

@onready var enemy := owner as Enemy
@onready var shooter: Shooter = enemy.get_shooter()


func enter(sm: StateMachine, prev_state: State) -> void:
	super(sm, prev_state)
	enemy.play_animation("shoot_stationary")

	for i in len(shooter.targets):
		if shooter.targets[i] is Objective:
			var objective = shooter.targets.pop_at(i)
			shooter.targets.push_front(objective)
			break

func update(delta: float) -> void:
	if shooter:
		if shooter.targets.size() > 0 :
			shooter._rotate_shooter(delta)
			if shooter.should_shoot():
				shooter.shoot()
		else:
			state_machine.transition_to("Move")
