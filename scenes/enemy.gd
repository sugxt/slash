extends CharacterBody3D

@export var health = 100

func _ready():
	# Make sure to add this node to the "Enemy" group
	add_to_group("Enemy")

func take_damage(damage_amount):
	health -= damage_amount
	print("Enemy took damage! Health: ", health)
	
	if health <= 0:
		die()

func die():
	print("Enemy died!")
	# Add death animation or effects here
	queue_free()  # Remove enemy from scene
