extends Area2D

export var speed = 400

var screen_size

var velocity = Vector2.ZERO

var touch_target = null

var is_active

signal hit


func _ready():
	screen_size = get_viewport_rect().size
	is_active = false
	hide()
	

func _process(delta):
	if(!is_active):
		return
	var keyVelocity = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		keyVelocity.x += 1
	if Input.is_action_pressed("ui_left"):
		keyVelocity.x -= 1
	if Input.is_action_pressed("ui_up"):
		keyVelocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		keyVelocity.y += 1
	if keyVelocity.length() > 0:
		velocity = keyVelocity

	if touch_target != null and position.distance_to(touch_target) < 5:
		touch_target = null
		velocity = Vector2.ZERO

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
	
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
	if velocity.x != 0:
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = velocity.y > 0


func _on_Player_body_entered(_body):
	hide()
	emit_signal("hit")
	is_active = false
	velocity = Vector2.ZERO
	$AnimatedSprite.stop()
	$CollisionShape2D.set_deferred("disabled", true)


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func _input(event):
	if(!is_active):
		return
	
	if event is InputEventScreenTouch and event.pressed:
			touch_target = event.position
			velocity = touch_target - position
	
	if event is InputEventScreenDrag:
			touch_target = event.position
			velocity = touch_target - position


func _on_Main_activate_player():
	is_active = true
