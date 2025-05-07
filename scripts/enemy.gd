extends CharacterBody3D

@export var health = 100
@onready var main_mesh: MeshInstance3D = $MeshInstance3D
@onready var ragdoll: RigidBody3D = $RigidBody3D
@onready var ragdoll_mesh = $RigidBody3D/MeshInstance3D
@onready var ragdoll_collision = $RigidBody3D/CollisionShape3D

func _ready():
	add_to_group("Enemy")
	ragdoll.visible = false
	ragdoll_collision.disabled = true

func take_damage(damage_amount, knockback_direction = Vector3.ZERO):
	health -= damage_amount
	print("Enemy took damage! Health: ", health)
	
	if health <= 0:
		die(knockback_direction)

func die(knockback_direction = Vector3.ZERO):
	print("Enemy died!")
	main_mesh.visible = false
	$CollisionShape3D.call_deferred("set_disabled", true)

	ragdoll.visible = true
	ragdoll_collision.call_deferred("set_disabled", false)
	ragdoll.global_transform = global_transform

	# Normalize direction to avoid excessive force
	var dir = -knockback_direction.normalized() * 2

	# Apply a backward impulse and torque
	ragdoll.apply_impulse(Vector3.ZERO, dir * 6 + Vector3.UP * 3)  # Up for some lift
	ragdoll.apply_torque_impulse(dir.cross(Vector3.UP) * 10)      # Torque to spin it backward
