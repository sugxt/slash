class_name CrouchingState
extends PlayerState

const crouching_speed = 3.0
const crouching_depth = -0.5

func enter_state():
	state_manager.walking = false
	state_manager.sprinting = false
	state_manager.crouching = true
	state_manager.sliding = false

func exit_state():
	state_manager.crouching = false

func process(delta):
	# Set appropriate speed
	state_manager.current_speed = lerp(state_manager.current_speed, crouching_speed, delta * player.lerp_speed)
	
	# Lower head position
	player.head.position.y = lerp(player.head.position.y, crouching_depth, delta * player.lerp_speed)
	
	# Enable crouching collision shape
	player.standing_collision_shape.disabled = true
	player.crouching_collision_shape.disabled = false
	
	# Handle movement
	process_movement(delta)

func process_movement(delta):
	var input_dir = state_manager.get_input_direction()
	
	if player.is_on_floor():
		player.direction = lerp(player.direction,
			(player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),
			delta * player.lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			player.direction = lerp(player.direction,
				(player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),
				delta * player.air_lerp_speed)
	
	if player.direction:
		player.velocity.x = player.direction.x * state_manager.current_speed
		player.velocity.z = player.direction.z * state_manager.current_speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, state_manager.current_speed)
		player.velocity.z = move_toward(player.velocity.z, 0, state_manager.current_speed)

func check_state_changes():
	if !Input.is_action_pressed("crouch") && state_manager.can_stand():
		if Input.is_action_pressed("sprint"):
			return state_manager.sprinting_state
		else:
			return state_manager.walking_state
			
	return self
