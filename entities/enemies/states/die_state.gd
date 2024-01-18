class_name DieState
extends State


@onready var enemy := owner as Enemy


func enter(sm: StateMachine, prev_state: State) -> void:
	super(sm, prev_state)
	enemy.die()

