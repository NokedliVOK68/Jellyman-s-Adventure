extends CharacterBody2D

@onready var camera_node = get_tree().get_first_node_in_group("Camera")

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -600

@export var dash_speed = 400

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

@onready var coyote_timer: Timer = $CoyoteTimer
var coyote_time_activated := false

@onready var dash_timer: Timer = $Dash_Timer
var is_dashing = false
var can_dash = true

var ball_state = false
var can_bounce = false

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _change_col_shape_size():
	if sprite_2d.animation == "Dash":
		collision_shape_2d.shape.size = Vector2(200, 80)
	else:
		collision_shape_2d.shape.size = Vector2(120,125)

func check_player_is_on_floor():
	if is_on_floor():
		if coyote_time_activated:
			coyote_time_activated = false
			coyote_timer.stop()
	else:
		if !coyote_time_activated:
			coyote_timer.start()
			coyote_time_activated = true

func move(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction < 0:
		sprite_2d.flip_h = true
	if direction > 0: 
		sprite_2d.flip_h = false
	
	if Input.is_action_just_pressed("transform") and !is_on_floor():
		ball_state = true
		can_bounce = true

	if !is_dashing:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("dash") and !is_on_floor() and !is_dashing:
		can_dash = false
		is_dashing = true
		dash_timer.start()
		velocity.x = direction * 625.0
	
	move_and_slide()
	
	if is_on_floor():
		can_dash = true
	
	if ball_state and is_on_floor():
		if can_bounce:
			camera_node.trigger_shake()
			can_bounce = false
			velocity.y = JUMP_VELOCITY * 1.25
			ball_state = false

func jump():
	if Input.is_action_just_pressed("ui_accept") and (!coyote_timer.is_stopped() or is_on_floor()):
		velocity.y = JUMP_VELOCITY
		coyote_timer.stop()
		coyote_time_activated = true

func _physics_process(delta: float) -> void:
	check_player_is_on_floor()
	move(delta)
	jump()
	_change_col_shape_size()
	
	if ball_state:
		sprite_2d.play("ball")
	elif is_dashing:
		sprite_2d.play("Dash")
	else:
		sprite_2d.play("default")

func _on_dash_timer_timeout() -> void:
	is_dashing = false
