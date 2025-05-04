class_name PlayerStateManager
extends Node

# States
var walking_state: WalkingState
var sprinting_state: SprintingState
var crouching_state: CrouchingState
var sliding_state: SlidingState
var free_looking_state: FreeLookingState
var head_bobbing_state: HeadBobbingState

# Current state
var current_movement_state
var player

# Current player speed
var current_speed = 5.0

# State flags for easy access
var walking = false
var sprinting = false
var crouching = false
var free_looking = false
var sliding = false

func _init(player_reference):
	player = player_reference

func _ready():
	# Initialize all states
	walking_state = WalkingState.new(player, self)
	sprinting_state = SprintingState.new(player, self)
	crouching_state = CrouchingState.new(player, self)
	sliding_state = SlidingState.new(player, self)
	free_looking_state = FreeLookingState.new(player, self)
	head_bobbing_state = HeadBobbingState.new(player, self)
	
	# Add states as children for automatic processing
	add_child(walking_state)
	add_child(sprinting_state)
	add_child(crouching_state)
	add_child(sliding_state)
	add_child(free_looking_state)
	add_child(head_bobbing_state)
	
	# Set initial state
	current_movement_state = walking_state
	walking = true

func process_state_changes():
	# Determine current state based on inputs and conditions
	var new_state = current_movement_state.check_state_changes()
	
	if new_state != current_movement_state:
		current_movement_state.exit_state()
		current_movement_state = new_state
		current_movement_state.enter_state()

func process_movement(delta):
	# Process main movement state
	current_movement_state.process(delta)
	
	# Process free-looking separately since it can be active with any movement state
	free_looking_state.process(delta)
	
	# Process head bobbing separately since it depends on movement state
	head_bobbing_state.process(delta)

func handle_input(event):
	if event is InputEventMouseMotion:
		if free_looking:
			player.neck.rotate_y(deg_to_rad(-event.relative.x * player.mouse_sens))
			player.neck.rotation.y = clamp(player.neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
		else:
			player.rotate_y(deg_to_rad(-event.relative.x * player.mouse_sens))
		player.head.rotate_x(deg_to_rad(-event.relative.y * player.mouse_sens))
		player.head.rotation.x = clamp(player.head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func get_input_direction():
	return Input.get_vector("left", "right", "forward", "backward")

func can_stand():
	return !player.ray_cast_3d.is_colliding()

func cancel_sliding():
	if sliding:
		sliding = false
		free_looking = false
