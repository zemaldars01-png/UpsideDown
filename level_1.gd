
extends Node2D

@onready var clue = $ClueText
@onready var player = $Player
@onready var key = $Key2
@onready var portal = $Portal
@onready var message = $WorldMessage

var key_found = false
var changing_world = false


func _ready():
	portal.hide()
	message.hide()

	# Show message only when returning from Level 2
	if get_tree().get_meta("returning_from_upside_down", false):
		get_tree().remove_meta("returning_from_upside_down")
		message.text = "YOU'RE BACK IN REALITY!\nBut was it all just a dream?"
		message.show()
		hide_message()

	# First clue
	clue.text = "Something strange is written on the wall..."
	await typing()

	# Glowing letters
	for letter in ["GlowR", "GlowU", "GlowN"]:
		var glow = get_node(letter)

		for i in range(2):
			glow.show()
			await get_tree().create_timer(0.2).timeout
			glow.hide()
			await get_tree().create_timer(0.2).timeout

	# Find the key
	if not key_found:
		clue.text = "Find the key. It's coming..."
		await typing()


func typing():
	clue.visible_characters = 0

	for i in range(clue.text.length()):
		clue.visible_characters += 1
		await get_tree().create_timer(0.04).timeout


func hide_message():
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(message):
		message.hide()


func _process(delta):
	if changing_world:
		return

	# Collect key and open portal
	if not key_found and player.position.distance_to(key.position) < 80:
		key_found = true
		key.hide()
		portal.show()
		portal.play("Portal")
		clue.text = "PORTAL OPEN! RUN!"
		clue.visible_characters = -1


func _on_area_2d_area_entered(area: Area2D) -> void:
	if portal.visible and not changing_world:
		changing_world = true
		get_tree().change_scene_to_file("res://level_2.tscn")
