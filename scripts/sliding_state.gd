class_name SlidingState
extends PlayerState

# Slide Variables
var slide_timer = 0.0
const slide_timer_max = 1.2
var slide_vector = Vector2.ZERO
const slide_speed = 10.0
const crouching_depth = -0.5

func enter_state():
	state_manager.walking = false
	state_manager.sprinting = false
	state_manager.crouching = true
	state_manager.sliding = true
	state_manager.free_looking = true
	
	# Initialize slide
	slide_timer = slide_timer_max
	slide_vector = state_manager.get_input_direction()
	print("Slide Begin")

func exit_state():
	state_manager.sliding = false
	state_manager.free_looking = false
	print("Slide End")

func process(delta):
	# Update slide timer
	slide_timer -= delta
	
	# Lower head position (same as crouching)
	player.head.position.y = lerp(player.head.position.y, crouching_depth, delta * player.lerp_speed)
	
	# Enable crouching collision shape
	player.standing_collision_shape.disabled = true
	player.crouching_collision_shape.disabled = false
	
	# Tilt camera while sliding
	player.eyes.rotation.z = lerp(player.eyes.rotation.z, -deg_to_rad(7.0), delta * player.lerp_speed)
	
	# Handle movement
	process_movement(delta)

func process_movement(delta):
	# Set direction based on slide vector
	player.direction = (player.transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
	
	# Calculate speed based on remaining slide time
	var current_slide_speed = (slide_timer + 0.1) * slide_speed
	
	# Apply movement
	player.velocity.x = player.direction.x * current_slide_speed
	player.velocity.z = player.direction.z * current_slide_speed

func check_state_changes():
	if slide_timer <= 0:
		return state_manager.crouching_state
	
	return self
