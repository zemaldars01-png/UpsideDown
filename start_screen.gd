
extends Node2D

@onready var title = $GameTitle
@onready var story = $StoryLabel
@onready var start_button = $StartButton

func _ready():
	start_button.hide()
	title.visible_characters = 0
	story.visible_characters = 0

	start_button.pressed.connect(start_game)

	# Title types first
	for i in range(title.get_total_character_count()):
		title.visible_characters += 1
		await get_tree().create_timer(0.08).timeout

	await get_tree().create_timer(0.4).timeout

	# Story types quickly
	for i in range(story.get_total_character_count()):
		story.visible_characters += 1
		await get_tree().create_timer(0.025).timeout

	# Start button appears
	await get_tree().create_timer(0.5).timeout
	start_button.show()


func start_game():
	get_tree().change_scene_to_file("res://level_1.tscn")
