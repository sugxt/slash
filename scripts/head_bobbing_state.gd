class_name HeadBobbingState
extends PlayerState

# Head Bobbing Constants
const head_bobbing_sprinting_speed = 22.0
const head_bobbing_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0

const head_bobbing_crouching_intensity = 0.05
const head_bobbing_sprinting_intensity = 0.2
const head_bobbing_walking_intensity = 0.1

# Head Bobbing Variables
var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0

func process(delta):
	# Determine which bobbing parameters to use based on current state
	if state_manager.sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed * delta
	elif state_manager.walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed * delta
	elif state_manager.crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed * delta
	
	# Apply head bobbing effect when moving on the ground
	var input_dir = state_manager.get_input_direction()
	
	if player.is_on_floor() && !state_manager.sliding && input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2) + 0.5
		
		player.eyes.position.y = lerp(player.eyes.position.y, 
			head_bobbing_vector.y * (head_bobbing_current_intensity/2.0), 
			delta * player.lerp_speed)
		player.eyes.position.x = lerp(player.eyes.position.x, 
			head_bobbing_vector.x * head_bobbing_current_intensity, 
			delta * player.lerp_speed)
	else:
		player.eyes.position.y = lerp(player.eyes.position.y, 0.0, delta * player.lerp_speed)
		player.eyes.position.x = lerp(player.eyes.position.x, 0.0, delta * player.lerp_speed)
