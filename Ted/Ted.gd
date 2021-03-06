extends KinematicBody2D

signal pause_game

var moving_right
var velocity = Vector2()
var walk_speed = 350
var run_speed = 700
var top_speed = walk_speed
var walk_accel = 1000
var gravity_scale = 500
var jump_multiplier = 3.5
var jump_button_timer = 0
var allow_jump = true
var max_jump_length_s = 1.5
var has_landed = true
var state

onready var JumpSound = get_node("JumpSound")
onready var PlopSound = get_node("PlopSound")

enum state_list{
	idle,
	walking,
	windup,
	jumping,
	falling,
	turning,
#	landing,
#	running, //Don't need a new state for this, yet.
}

func _ready() -> void:
	moving_right = true

func get_input(delta):
	if Input.is_action_just_pressed("ui_pause"):
		emit_signal("pause_game")
	if Input.is_action_pressed("player_run") and not Input.is_action_just_pressed("player_jump"):
		top_speed = run_speed
	else:
		top_speed = walk_speed
	if Input.is_action_pressed("player_walk_right"):
		if !moving_right and (state == state_list.walking or state == state_list.idle):
			state = state_list.turning
			velocity.x = 0
			$AnimatedSprite.play("ted_turns")
		if state == state_list.idle:
			state = state_list.walking
			$AnimatedSprite.play("ted_walks")
		moving_right = true
		if velocity.x < top_speed:
			velocity.x += walk_accel * delta
		elif velocity.x > top_speed:
			velocity.x -= walk_accel * delta
	elif Input.is_action_pressed("player_walk_left"):
		if moving_right and (state == state_list.walking or state == state_list.idle):
			state = state_list.turning
			$AnimatedSprite.play("ted_turns")
			velocity.x = 0
		if state == state_list.idle:
			state = state_list.walking
			$AnimatedSprite.play("ted_walks")
		moving_right = false
		if velocity.x > -top_speed:
			velocity.x -= walk_accel * delta
		elif velocity.x < -top_speed:
			velocity.x += walk_accel * delta
	else:
		if velocity.x != 0:
			velocity.x /=  1.5
		if state == state_list.walking:
			state = state_list.idle
			$AnimatedSprite.play("ted_stands")
	if Input.is_action_pressed("player_jump") and jump_button_timer < 0.2 and allow_jump:
		if Input.is_action_just_pressed("player_jump"):
			if state == state_list.idle or state == state_list.walking or state == state_list.turning:
				state = state_list.windup
				$AnimatedSprite.play("ted_jump_windup")
		if state == state_list.jumping:
			jump_button_timer += delta
			velocity.y -= gravity_scale * (jump_multiplier - 1)
	if is_on_floor() and !Input.is_action_pressed("player_jump"): 
		allow_jump = true
		jump_button_timer = 0
	if jump_button_timer > max_jump_length_s:
		allow_jump = false
	if !is_on_floor() and !Input.is_action_pressed("player_jump"):
		allow_jump = false
	if not moving_right:
		$AnimatedSprite.set_flip_h(true)
		#$CollisionShape2D.set_position(Vector2(-25,12))
	else:
		$AnimatedSprite.set_flip_h(false)
		#$CollisionShape2D.set_position(Vector2(25,12))

func _physics_process(delta: float) -> void:
	velocity.y = gravity_scale
	get_input(delta)
# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2(0, -1))
	if just_landed():
#		state = state_list.landing
#		$AnimatedSprite.play("ted_lands")
		state = state_list.idle
		$AnimatedSprite.play("ted_stands")
		PlopSound.play()
	if !is_on_floor() and velocity.y > 0:
		state = state_list.falling
		$AnimatedSprite.play("ted_falling")

func just_landed():
	var retVal = false
	if is_on_floor() and !has_landed:
		has_landed = true
		retVal = true
	if !is_on_floor():
		has_landed = false
	return retVal

func _on_AnimatedSprite_animation_finished() -> void:
	#this might be better practice if you just check which animation it is
	if state == state_list.turning:
		state = state_list.idle
		$AnimatedSprite.play("ted_stands")
		
#	if state == state_list.landing:
#		state = state_list.idle
#		$AnimatedSprite.play("ted_stands")
		
	if state == state_list.windup:
		if !Input.is_action_pressed("player_jump"):
			state = state_list.idle
			$AnimatedSprite.play("ted_stands")
		else:
			state = state_list.jumping
			$AnimatedSprite.play("ted_jump_up")
			JumpSound.play()

	if state == state_list.jumping and !Input.is_action_pressed("player_jump"):
		state = state_list.falling
		$AnimatedSprite.play("ted_falling")

	if state == state_list.falling and is_on_floor():
		state = state_list.idle
		$AnimatedSprite.play("ted_stands")
	
