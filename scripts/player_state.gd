class_name PlayerState
extends Node

var player
var state_manager

func _init(player_reference, state_manager_reference):
	player = player_reference
	state_manager = state_manager_reference

# Called when entering this state
func enter_state():
	pass

# Called when exiting this state
func exit_state():
	pass

# Main process function for state behavior
func process(_delta):
	pass

# Check if we should switch to another state
func check_state_changes():
	return self
