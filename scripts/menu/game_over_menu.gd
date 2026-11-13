extends Control

@onready var score_label: Label = $CanvasLayer/Score


func _ready() -> void:
	$CanvasLayer.visible = false
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.score_changed.connect(_on_score_changed)
		player.defeated.connect(_on_player_defeated)


func _on_continue_button_pressed() -> void:
	$SoundManager.play_click_sound()
	get_tree().change_scene_to_file("res://scenes/levels/level_home.tscn")


func _on_main_menu_button_pressed() -> void:
	$SoundManager.play_click_sound()
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")


func _on_player_defeated() -> void:
	$CanvasLayer.visible = true


func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score
