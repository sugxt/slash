extends CharacterBody3D

# Weapon Variables
var meele_damage = 50
@onready var meele_animator: AnimationPlayer = $MeeleAnimator
@onready var meele_weapon: Node3D = $"Neck/head/eyes/Camera3D/Meele Weapon"
@onready var hitbox: Area3D = $Neck/head/eyes/Hitbox

# Player Nodes
@onready var neck: Node3D = $Neck
@onready var head = $Neck/head
@onready var standing_collision_shape: CollisionShape3D = $standing_collision_shape
@onready var crouching_collision_shape: CollisionShape3D = $crouching_collision_shape
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var camera_3d: Camera3D = $Neck/head/eyes/Camera3D
@onready var eyes: Node3D = $Neck/head/eyes
@onready var animation_player: AnimationPlayer = $Neck/head/eyes/AnimationPlayer

#Player Variables
var current_speed = 5.0
const walking_speed = 5.0
const sprint_speed = 8.0
const crouching_speed = 3.0

#States
var walking = false
var sprinting = false
var crouching = false
var free_looking = false
var sliding = false

# Slide Vars
var slide_timer = 0.0
var slide_timer_max = 1.2
var slide_vector = Vector2.ZERO
var slide_speed = 10.0

#Head Bobbing Vars

const head_bobbing_sprinting_speed = 22.0
const head_bobbing_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0

const head_bobbing_crouching_intensity = 0.05
const head_bobbing_sprinting_intensity = 0.2
const head_bobbing_walking_intensity = 0.1

var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0

# Movement Variables
const jump_velocity = 4.5
var crouching_depth = -0.5
var free_look_tilt_amount = 4

var last_velocity = Vector3.ZERO

#Input Variables
var lerp_speed = 7.5
var air_lerp_speed = 3.0
var direction = Vector3.ZERO
const mouse_sens = 0.13

# 1. Fixed melee function
func meele():
	if Input.is_action_just_pressed("meele"):
		if not meele_animator.is_playing():
			meele_animator.play("swing")
			meele_animator.queue("reset")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hitbox.monitoring = false
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	
func _on_hitbox_body_entered(body):
	if body.is_in_group("Enemy"):
		print("Hit enemy for damage:", meele_damage)
		var direction_to_enemy = (body.global_transform.origin - global_transform.origin).normalized()
		body.take_damage(meele_damage, direction_to_enemy)

func _input(event):
	
	# Mouse Event Handling
	
	if event is InputEventMouseMotion:
		if free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))


func _physics_process(delta: float) -> void:
	meele()
	# Declaring Input
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	#Handling Movement Input and States
	
	#Crouching State
	if Input.is_action_pressed("crouch") || sliding:
		current_speed = lerp(current_speed,crouching_speed,delta * lerp_speed)
		head.position.y = lerp(head.position.y,crouching_depth, delta*lerp_speed)
		
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		
		# Slide Begin Logic
		
		if sprinting && input_dir != Vector2.ZERO && is_on_floor():
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			free_looking = true
			print("Slide Begin")
		
		walking = false
		sprinting = false
		crouching = true
	
	elif !ray_cast_3d.is_colliding():
		
		# Standing State
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		head.position.y = lerp(head.position.y, 0.0, delta*lerp_speed)
		
		if Input.is_action_pressed("sprint"):
			
			# Sprinting State
			current_speed = lerp(current_speed,sprint_speed,delta * lerp_speed)
			walking = false
			sprinting = true
			crouching = false
		else:
			
			# Walking State
			current_speed = lerp(current_speed,walking_speed,delta * lerp_speed)
			walking = true
			sprinting = false
			crouching = false
	# Handle Free Looking
	if Input.is_action_pressed("free_look") || sliding:
		free_looking = true
		if sliding:
			eyes.rotation.z = lerp(eyes.rotation.z,-deg_to_rad(7.0), delta * lerp_speed)
		else:
			eyes.rotation.z = -deg_to_rad(neck.rotation.y*free_look_tilt_amount)
	else:
		free_looking = false
		neck.rotation.y = lerp(neck.rotation.y,0.0,delta * lerp_speed)
		eyes.rotation.z = lerp(eyes.rotation.z,0.0,delta * lerp_speed)
		
	# Handle Sliding
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			sliding = false
			print("Slide End")
			free_looking = false
	
	# Handle Head Bob
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed* delta
	elif walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed* delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed* delta
	
	if is_on_floor() && !sliding && input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2)+0.5
		
		eyes.position.y = lerp(eyes.position.y,head_bobbing_vector.y*(head_bobbing_current_intensity/2.0), delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x,head_bobbing_vector.x*head_bobbing_current_intensity, delta * lerp_speed)
		
	else:
		eyes.position.y = lerp(eyes.position.y,0.0, delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x,0.0, delta * lerp_speed)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		sliding = false
		animation_player.play("jumping")
	# Handle Landing
	if is_on_floor() && last_velocity.y < 0.0:
		animation_player.play("landing")
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if is_on_floor():
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta * lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta * air_lerp_speed)
		
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x,0,slide_vector.y)).normalized()
		current_speed = (slide_timer + 0.1) * slide_speed
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	last_velocity = velocity
	move_and_slide()
