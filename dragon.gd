
extends Sprite2D

var time = 0.0
var reached = false

func _process(delta):
	if not reached:
		position.y += 80 * delta
		if position.y >= 370:
			reached = true
	else:
		time += delta
		position.y = 370 + sin(time * 3) * 35
