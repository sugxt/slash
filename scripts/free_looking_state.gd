class_name FreeLookingState
extends PlayerState

const free_look_tilt_amount = 5

func process(delta):
	# Check if free look should be active
	if Input.is_action_pressed("free_look") || state_manager.sliding:
		state_manager.free_looking = true
		
		# Don't rotate if sliding (handled in slide state)
		if !state_manager.sliding:
			player.eyes.rotation.z = -deg_to_rad(player.neck.rotation.y * free_look_tilt_amount)
	else:
		state_manager.free_looking = false
		player.neck.rotation.y = lerp(player.neck.rotation.y, 0.0, delta * player.lerp_speed)
		player.eyes.rotation.z = lerp(player.eyes.rotation.z, 0.0, delta * player.lerp_speed)
