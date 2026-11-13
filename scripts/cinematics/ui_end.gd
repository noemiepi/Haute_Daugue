extends Control

var score: int = 0
var total: int = 0

func _ready() -> void:
	$CanvasLayer.visible = false

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.score_changed.connect(_on_score_changed)
		player.win.connect(_on_win)
		player.extra_sausage_found.connect(_add_sausage_in_total)

	var collectibles_folder = get_tree().current_scene.get_node_or_null("CollectiblesGroup")
	if collectibles_folder:
		var all_collectibles = collectibles_folder.find_children("*", "Area2D")
		total = all_collectibles.size()

func _on_score_changed(new_score: int) -> void:
	score = new_score

func _add_sausage_in_total() -> void:
	total += 1

func _on_win() -> void:
	$CanvasLayer/Score.text = "%d/%d" % [score, total]
	$CanvasLayer.visible = true
	$"../../Player/UI"._stop_game()
	$"../../BackgroundMusic".stop()
	
	var ratio = float(score) / float(total)
	if ratio >= 1.0:
		$VictoryTOTAL.play()
	elif ratio <= 0.3:
		$VictoryBAD.play()
	else:
		$VictoryNORMAL.play()


func _on_main_menu_button_pressed() -> void:
	$SoundManager.play_click_sound()
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
