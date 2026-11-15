
extends Node2D

@onready var player = $Player
@onready var dragon = $Dragon
@onready var bullet = $Bullet
@onready var fire = $Fireorange
@onready var star = $FieryStarburst
@onready var flash = $Flash
@onready var portal = $Portal
@onready var restart = $RestartButton
@onready var win_label = $WinLabel
@onready var play_again = $PlayAgainButton
@onready var message = $UpsideDownMessage

var player_hearts = []
var dragon_hearts = []

var player_lives = 3
var dragon_lives = 3

var shooting = false
var fire_moving = false
var game_won = false
var changing_world = false
var portal_ready = false

var target = Vector2.ZERO
var fire_target = Vector2.ZERO

var time = 0.0
var attacks = 0
var speed = 180.0


func _ready():
	bullet.hide()
	fire.hide()
	star.hide()
	flash.hide()
	restart.hide()
	win_label.hide()
	play_again.hide()

	message.text = "YOU'VE ENTERED THE UPSIDE DOWN WORLD..."
	message.show()
	hide_message()

	for node in get_children():
		var n = str(node.name).to_lower()

		if n.begins_with("playerheart"):
			player_hearts.append(node)

		if n.begins_with("dragonheart"):
			dragon_hearts.append(node)

	player_hearts.sort_custom(func(a, b): return a.position.x < b.position.x)
	dragon_hearts.sort_custom(func(a, b): return a.position.x < b.position.x)

	update_hearts()

	restart.pressed.connect(restart_level)
	play_again.pressed.connect(play_again_game)

	portal.play("Portal")
	await get_tree().create_timer(0.8).timeout
	portal_ready = true


func hide_message():
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(message):
		message.hide()


func update_hearts():
	for i in range(player_hearts.size()):
		player_hearts[i].visible = i >= 3 - player_lives

	for i in range(dragon_hearts.size()):
		dragon_hearts[i].visible = i >= 3 - dragon_lives


func _input(event):
	if game_won or changing_world or player_lives == 0:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not shooting and dragon_lives > 0:
			target = get_global_mouse_position()
			bullet.position = player.position + Vector2(40, -45)
			bullet.show()
			shooting = true
			gun_flash()


func gun_flash():
	star.show()
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(star):
		star.hide()


func _process(delta):
	if changing_world or game_won or player_lives == 0:
		return

	# Player movement
	var direction = Vector2.ZERO

	if Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1
	if Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1
	if Input.is_key_pressed(KEY_UP):
		direction.y -= 1
	if Input.is_key_pressed(KEY_DOWN):
		direction.y += 1

	player.position += direction.normalized() * speed * delta
	player.position.x = clamp(player.position.x, 30, 482)
	player.position.y = clamp(player.position.y, 50, 475)

	# Portal to Reality
	if portal_ready and player.global_position.distance_to(portal.global_position) < 55:
		changing_world = true
		get_tree().set_meta("returning_from_upside_down", true)
		get_tree().change_scene_to_file("res://level_1.tscn")
		return

	time += delta

	# Player shoots dragon
	if shooting:
		bullet.position = bullet.position.move_toward(target, 600 * delta)

		if bullet.position.distance_to(dragon.position) < 45:
			bullet.hide()
			shooting = false
			dragon_lives -= 1
			update_hearts()

			if dragon_lives == 0:
				dragon.hide()
				fire.hide()
				portal.hide()
				fire_moving = false
				game_won = true
				blink()
				win_label.show()
				play_again.show()

		elif bullet.position.distance_to(target) < 5:
			bullet.hide()
			shooting = false

	# Dragon shoots fire
	if time >= 1.0 + attacks * 3.0 and not fire_moving:
		if player_lives > 0 and dragon_lives > 0:
			fire.position = dragon.position + Vector2(-35, 20)
			fire_target = player.position + Vector2(0, -30)
			fire.show()
			fire_moving = true
			attacks += 1

	# Fire hits player
	if fire_moving:
		fire.position = fire.position.move_toward(fire_target, 400 * delta)

		if fire.position.distance_to(fire_target) < 5:
			fire.hide()
			fire_moving = false
			player_lives -= 1
			update_hearts()

			if player_lives == 0:
				player.hide()
				bullet.hide()
				shooting = false
				blink()
				restart.show()


func blink():
	flash.show()
	flash.modulate.a = 0.7
	await get_tree().create_timer(0.3).timeout
	if is_instance_valid(flash):
		flash.hide()


func restart_level():
	get_tree().reload_current_scene()


func play_again_game():
	get_tree().remove_meta("returning_from_upside_down")
	get_tree().change_scene_to_file("res://start_screen.tscn")
