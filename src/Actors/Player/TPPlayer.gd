class_name TPPlayer
extends CharacterBody2D

@export var speed = 200
@export var sprint_multiplier = 1.4
@export var sprint_animation_multiplier = 1.2
@export var attack_cooldown_time = 0.3

var screen_size

enum Direction { LEFT, RIGHT, DOWN, UP }
var direction: Direction = Direction.DOWN

var attack_timer = 0;
var is_attacking: bool = false


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

func initAnimation():
	if (!$AnimatedSprite2D.is_playing()):
		$AnimatedSprite2D.play("idle")


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

	if (velocity.length() > 0):
		currentVelocity = currentVelocity.normalized() * speed

		if (Input.is_action_pressed("sprint")):
			currentVelocity = currentVelocity * sprint_multiplier
	
	velocity = currentVelocity
	
	var motion = velocity * delta / 2

	move_and_collide(motion)
	move_and_slide()
	


func handleAnimation():
	if velocity.x == 0 && velocity.y == 0: 
		handleIdleAnimation()	

	if velocity.x != 0 || velocity.y != 0:
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
		$AnimatedSprite2D.animation = 'idle'

	if (direction == Direction.LEFT || direction == Direction.RIGHT):
		$AnimatedSprite2D.animation = 'idle-side'

		if (direction == Direction.LEFT):
			$AnimatedSprite2D.flip_h = true;
		else:
			$AnimatedSprite2D.flip_h = false;
	
	if (direction == Direction.UP):
		$AnimatedSprite2D.animation = 'idle-up'


func handleMoveAnimation():
	if (direction == Direction.LEFT || direction == Direction.RIGHT):
		$AnimatedSprite2D.animation = 'run-side'

		if (direction == Direction.LEFT):
			$AnimatedSprite2D.flip_h = true;
		else:
			$AnimatedSprite2D.flip_h = false;

	if (direction == Direction.DOWN):
		$AnimatedSprite2D.animation = 'run-down'

	if (direction == Direction.UP):
		$AnimatedSprite2D.animation = 'run-up'

	if (Input.is_action_pressed("sprint")):
		$AnimatedSprite2D.speed_scale = sprint_animation_multiplier
	else:
		$AnimatedSprite2D.speed_scale = 1
