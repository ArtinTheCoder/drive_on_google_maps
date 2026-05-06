extends CharacterBody2D

@export var speed = 400

func _enter_tree() -> void:
	Global.set_player(self)

func get_input():
	var input_direction = Input.get_vector("Left", "Right", "Forward", "Backward")
	velocity = input_direction * speed

func _physics_process(_delta):
	get_input()
	move_and_slide()
	
