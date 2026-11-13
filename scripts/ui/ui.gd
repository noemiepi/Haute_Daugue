extends Control

var game_started: bool = false

@export_group("Time")
@export var minute: int = 7

@onready var timer_label: Label = $CanvasLayer/Timer
@onready var timer: Timer = $Timer
@onready var score_label: Label = $CanvasLayer/Score
@onready var start_text: Label = $CanvasLayer/StartText
@onready var mid_text: Label = $CanvasLayer/MidText
@onready var easter_egg_text: Label = $CanvasLayer/EasterEgg


var text_duration: float = 3.0
var mid_text_duration: float = 5.0
var easter_egg_text_duration: float = 5.0

func _ready() -> void:
	timer_label.visible = false
	start_text.visible = false
	easter_egg_text.visible = false
	$CanvasLayer/GoldenSausage.visible = false
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.score_changed.connect(_on_score_changed)
		player.easter_egg.connect(_show_golden_sausage)
		timer.timeout.connect(player.player_detected)
	
	timer.timeout.connect(_stop_game)
	
	timer.wait_time = minute * 60

func _process(delta: float) -> void:
	if game_started:
		var total_sec = timer.time_left
		
		var time_left_min = int(total_sec / 60)
		var time_left_sec = int(total_sec) % 60
		timer_label.text = "%02d:%02d" % [time_left_min, time_left_sec]

		if start_text.visible:
			text_duration -= delta
			if text_duration <= 0:
				start_text.visible = false
		if mid_text.visible:
			mid_text_duration -= delta
			if mid_text_duration <= 0:
				mid_text.visible = false
		if easter_egg_text.visible:
			easter_egg_text_duration -= delta
			if easter_egg_text_duration <= 0:
				easter_egg_text.visible = false

func _on_score_changed(new_score: int) -> void:
	score_label.text = str(new_score)

func _start_game() -> void:
	print("game started")
	timer_label.visible = true
	start_text.visible = true
	game_started = true
	timer.start()
	
func _stop_game() -> void:
	timer.stop()
	game_started = false
	score_label.visible = false
	$CanvasLayer/Icon.visible = false

func _show_golden_sausage() -> void:
	$CanvasLayer/GoldenSausage.visible = true
