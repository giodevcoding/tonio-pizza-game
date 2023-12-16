class_name TPPlayer
extends CharacterBody2D

@export var speed = 200
@export var sprint_multiplier = 1.4
@export var sprint_animation_multiplier = 1.2
@export var attack_cooldown_time = 0.5

var screen_size

enum Direction { LEFT, RIGHT, DOWN, UP }
var direction: Direction = Direction.DOWN

var last_attack_time = 0;
var can_attack = true
var is_attacking = false


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	velocity = Vector2.ZERO
	initAnimation()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handleMovement(delta)
	handleDirection()
	handleAnimation()
	handleAttacking()

func initAnimation():
	$AnimationPlayer.play("idle-down")


func handleMovement(delta):
	var currentVelocity = Vector2.ZERO;

	if (Input.is_action_pressed("move_up")):
		currentVelocity.y -= 1
	if (Input.is_action_pressed("move_left")):
		currentVelocity.x -= 1
	if (Input.is_action_pressed("move_down")):
		currentVelocity.y += 1
	if (Input.is_action_pressed("move_right")):
		currentVelocity.x += 1

	if (currentVelocity.length() > 0):
		var movementSpeed = speed

		if is_attacking:
			movementSpeed = 10

		currentVelocity = currentVelocity.normalized() * movementSpeed

		if (Input.is_action_pressed("sprint")):
			currentVelocity = currentVelocity * sprint_multiplier

	velocity = currentVelocity
	
	var motion = velocity * delta / 2

	move_and_collide(motion)
	move_and_slide()
	


func handleAnimation():
	if velocity.x == 0 && velocity.y == 0 && !is_attacking: 
		handleIdleAnimation()	

	if (velocity.x != 0 || velocity.y != 0) && !is_attacking:
		handleMoveAnimation()


func handleDirection():
	if (Input.is_action_pressed("move_up") || Input.is_action_pressed("move_down")): 
		if (Input.is_action_pressed("move_up") && !Input.is_action_pressed("move_down")):
			direction = Direction.UP
		if (!Input.is_action_pressed("move_up") && Input.is_action_pressed("move_down")):
			direction = Direction.DOWN

	# Horizontal direction gets priority over vertical direction
	if (Input.is_action_pressed("move_left") || Input.is_action_pressed("move_right")): 
		if (Input.is_action_pressed("move_left") && !Input.is_action_pressed("move_right")):
			direction = Direction.LEFT
		if (!Input.is_action_pressed("move_left") && Input.is_action_pressed("move_right")):
			direction = Direction.RIGHT


func handleIdleAnimation():
	if (direction == Direction.DOWN):
		$AnimationPlayer.play('idle-down')

	if (direction == Direction.LEFT || direction == Direction.RIGHT):
		$AnimationPlayer.play('idle-side')

		if (direction == Direction.LEFT):
			$Sprite2D.flip_h = true;
		else:
			$Sprite2D.flip_h = false;
	
	if (direction == Direction.UP):
		$AnimationPlayer.play('idle-up')


func handleMoveAnimation():
	if (direction == Direction.LEFT || direction == Direction.RIGHT):
		$AnimationPlayer.play('run-side')

		if (direction == Direction.LEFT):
			$Sprite2D.flip_h = true;
		else:
			$Sprite2D.flip_h = false;

	if (direction == Direction.DOWN):
		$AnimationPlayer.play('run-down')

	if (direction == Direction.UP):
		$AnimationPlayer.play('run-up')

	if (Input.is_action_pressed("sprint")):
		$AnimationPlayer.set_speed_scale(sprint_animation_multiplier)
	else:
		$AnimationPlayer.set_speed_scale(1)

func handleAttacking():
	if Time.get_ticks_msec() - last_attack_time > (attack_cooldown_time * 1000) && !can_attack:
		can_attack = true

	if can_attack && Input.is_action_pressed("attack"):
		last_attack_time = Time.get_ticks_msec()
		can_attack = false
		is_attacking = true
		attack()

func attack():
	$AnimationPlayer.stop()
	if (direction == Direction.LEFT || direction == Direction.RIGHT):
		$AnimationPlayer.play('attack-side')

		if (direction == Direction.LEFT):
			$Sprite2D.flip_h = true;
		else:
			$Sprite2D.flip_h = false;

	if (direction == Direction.DOWN):
		$AnimationPlayer.play('attack-down')

	if (direction == Direction.UP):
		$AnimationPlayer.play('attack-up')


func _on_animation_player_animation_finished(anim_name):
	if "attack" in anim_name:
		is_attacking = false;
