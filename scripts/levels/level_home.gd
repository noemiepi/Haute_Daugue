extends Node2D

@export var sausage_needed_to_unlock_garden: int = 4

var score: int = 0
var is_player_near_cave: bool = false
var can_enter_cave: bool = false
var house_visible: bool = true

func _ready() -> void:
	$Garden.visible = false
	$SoundsEffectGroup/CaveGuySound.stop()
	$CaveGroup/CaveEntrance.disabled = true
	$CollectiblesGroup/GardenSausages.visible = false
	$Bushes.visible = false
	$HideHouse.visible = true
	$Enemies/EnemiesGarden.visible = false
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.score_changed.connect(_on_score_changed)
		player.defeated.connect(_on_player_defeated)
		player.easter_egg.connect(_when_player_get_golden_sausage)
		
func _start_level_and_timer() -> void:
	$BackgroundMusic.play()
	$Player/UI._start_game()

func _on_score_changed(new_score: int) -> void:
	score = new_score
	if score == 1:
		_start_level_and_timer()
		$CollisionsGroup/StartCollision.disabled = true
		$Control.visible = false
	if score == sausage_needed_to_unlock_garden:
		$CollisionsGroup/DoorCollision.disabled = true
		$Player/UI/CanvasLayer/MidText.visible = true
		$SoundsEffectGroup/DoorSoundEffect.play()
		$Garden.visible = true
		$CollectiblesGroup/GardenSausages.visible = true
		$Bushes.visible = true
		$Enemies/EnemiesGarden.visible = true

func _on_player_defeated() -> void:
	$BackgroundMusic.stop()
	$GameOverMusic.play()
	$Player/UI._stop_game()

func _when_player_get_golden_sausage() -> void:
	print("cc")
	$Player/UI/CanvasLayer/EasterEgg.visible = true
	$SoundsEffectGroup/CaveGuySound.play()
	$CaveGroup/CaveEntrance.disabled = false
	can_enter_cave = true

func _on_cave_group_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_near_cave = true

func _on_cave_group_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_near_cave = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and is_player_near_cave and can_enter_cave:
		get_tree().change_scene_to_file("res://scenes/levels/dungeon_scene.tscn")

# --------------
#   HIDE HOUSE
# --------------

func _on_house_interior_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
			var tween = create_tween()
			tween.tween_property($HideHouse, "modulate:a", 0.0, 0.3)

func _on_house_interior_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		var tween = create_tween()
		tween.tween_property($HideHouse, "modulate:a", 1.0, 0.3)


func _on_sound_beer_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$SoundBeer/SoundBeer.play()
		call_deferred("_disable_beer_coll")

func _disable_beer_coll() -> void:
	$SoundBeer/CollisionShape2D.disabled = true
