class_name TPPlayer
extends Area2D

@export var speed = 200
@export var sprintMultiplier = 1.2
@export var sprintAnimationMultiplier = 1.2

var screen_size
var velocity

enum Direction { LEFT, RIGHT, DOWN, UP }
var direction: Direction = Direction.DOWN


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	velocity = Vector2.ZERO
	# hide()
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
			currentVelocity = currentVelocity * sprintMultiplier

	print(velocity)
	
	velocity = currentVelocity

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)


func handleAnimation():
	if (velocity.x == 0 && velocity.y == 0): 
		handleIdleAnimation()	

	if (velocity.x != 0 || velocity.y != 0):
		handleMoveAnimation()


func handleDirection():
	if (velocity.x < 0): 
		direction = Direction.LEFT
	if (velocity.x > 0):
		direction = Direction.RIGHT

	# Vertical direction gets priority over horizontal direction
	if (velocity.y < 0):
		direction = Direction.UP
	if (velocity.y > 0):
		direction = Direction.DOWN

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
		$AnimatedSprite2D.speed_scale = sprintAnimationMultiplier
	else:
		$AnimatedSprite2D.speed_scale = 1
		

