class_name State
extends Node


var state_machine: StateMachine


func enter(sm: StateMachine, _prev_state: State) -> void:
	self.state_machine = sm


func exit() -> void:
	pass

func update(_delta: float) -> void:
	return
