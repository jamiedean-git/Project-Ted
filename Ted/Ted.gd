extends KinematicBody2D

signal pause_game

var moving_right
var velocity = Vector2()
var walk_speed = 350
var walk_accel = 1000
var gravity_scale = 500
var jump_multiplier = 3.5
var jump_button_timer = 0
var allow_jump = true
var max_jump_length_s = 1.5
var has_landed = true

onready var JumpSound = get_node("JumpSound")
onready var PlopSound = get_node("PlopSound")


func _ready() -> void:
	moving_right = true

func get_input(delta):
	if Input.is_action_just_pressed("ui_pause"):
		emit_signal("pause_game")
	if Input.is_action_pressed("ui_right"):
		moving_right = true
		if velocity.x < walk_speed:
			velocity.x += walk_accel * delta
		$AnimatedSprite.play("ted_stands")
	elif Input.is_action_pressed("ui_left"):
		moving_right = false
		if velocity.x > -walk_speed:
			velocity.x -= walk_accel * delta
	else:
		if velocity.x != 0:
			velocity.x /= 10
	if not moving_right:
		$AnimatedSprite.set_flip_h(true)
	else:
		$AnimatedSprite.set_flip_h(false)
	if Input.is_action_pressed("player_jump") and jump_button_timer < 0.2 and allow_jump:
		if Input.is_action_just_pressed("player_jump"):
			JumpSound.play()
		jump_button_timer += delta
		velocity.y -= gravity_scale * (jump_multiplier - 1)
	if jump_button_timer > max_jump_length_s:
		allow_jump = false
	if !is_on_floor() and !Input.is_action_pressed("player_jump"):
		allow_jump = false
	if just_landed():
		PlopSound.play()
	

func _physics_process(delta: float) -> void:
	velocity.y = gravity_scale
	get_input(delta)
	move_and_slide(velocity, Vector2(0, -1))
	if is_on_floor() and !Input.is_action_pressed("player_jump"): 
		allow_jump = true
		jump_button_timer = 0

func just_landed():
	var retVal = false
	if is_on_floor() and !has_landed:
		has_landed = true
		retVal = true
	if !is_on_floor():
		has_landed = false
	return retVal
