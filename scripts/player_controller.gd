extends CharacterBody3D

# Player Nodes
@onready var neck: Node3D = $Neck
@onready var head = $Neck/head
@onready var standing_collision_shape: CollisionShape3D = $standing_collision_shape
@onready var crouching_collision_shape: CollisionShape3D = $crouching_collision_shape
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var camera_3d: Camera3D = $Neck/head/eyes/Camera3D
@onready var eyes: Node3D = $Neck/head/eyes
@onready var animation_player: AnimationPlayer = $Neck/head/eyes/AnimationPlayer

# Movement Variables
const jump_velocity = 4.5
var direction = Vector3.ZERO
var last_velocity = Vector3.ZERO
const mouse_sens = 0.2
var lerp_speed = 7.5
var air_lerp_speed = 3.0

# Movement State Manager
var state_manager: PlayerStateManager

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Initialize state manager
	state_manager = PlayerStateManager.new(self)
	add_child(state_manager)
	
func _input(event):
	state_manager.handle_input(event)

func _physics_process(delta: float) -> void:
	# Update player state
	state_manager.process_state_changes()
	state_manager.process_movement(delta)
	
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump - could be moved to state manager but kept here for simplicity
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		state_manager.cancel_sliding()
		animation_player.play("jumping")
	
	# Handle Landing
	if is_on_floor() && last_velocity.y < 0.0:
		animation_player.play("landing")
	
	last_velocity = velocity
	move_and_slide()
