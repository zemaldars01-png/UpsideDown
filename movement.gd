
extends Sprite2D

var speed = 150

func _process(delta):
	var move = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += move * speed * delta

	position.x = clamp(position.x, 45, 465)
	position.y = clamp(position.y, 340, 455)
