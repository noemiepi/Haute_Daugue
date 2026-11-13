extends Node2D

@onready var progress_bar: ProgressBar = $CanvasLayer/ProgressBar

@export_group("Cinematic Settings")
@export var skip_time: float = 0.0
@export var time_to_skip: float = 1.5

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		skip_time += delta
		progress_bar.visible = true
		progress_bar.value = skip_time
		
		if skip_time >= time_to_skip:
			start_game()
	else:
		skip_time = 0.0
		progress_bar.visible = false

func start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_home.tscn")
