extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var standing_collison_shape: CollisionShape3D = $standing_collison_shape
@onready var crouching_collison_shape: CollisionShape3D = $crouching_collison_shape
@onready var ray_cast_3d: RayCast3D = $RayCast3D

# Speed vars

var current_speed = 5.0

const walking_speed = 5.0
const sprint_speed = 10.0
const crouch_speed = 4.0

const JUMP_VELOCITY = 4.5


var lerp_speed = 10.0

# Input var mouse sens
var direction = Vector3.ZERO
const mouse_sens = 0.4

var courching_depth = -0.5



func _ready(): 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
func _physics_process(delta: float) -> void:
	
	# Crounching logic 
	if Input.is_action_pressed("crouch"):
		current_speed = crouch_speed 
		head.position.y = lerp( head.position.y,1.8 + courching_depth,delta*lerp_speed)
		standing_collison_shape.disabled = true
		crouching_collison_shape.disabled = false
		
	elif !ray_cast_3d.is_colliding(): 
		
	# Standing logic 
		head.position.y = lerp( head.position.y,1.8,delta*lerp_speed )
		standing_collison_shape.disabled = false
		crouching_collison_shape.disabled = true
		if Input.is_action_pressed("sprint"):
			#Spriting
			current_speed = sprint_speed
		else:
			#Walking 
			current_speed = walking_speed
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
