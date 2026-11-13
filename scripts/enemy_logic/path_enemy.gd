extends CharacterBody2D

@onready var zone: Area2D = $Zone
@onready var kill_zone: Area2D = $KillZone
@onready var path_follow_2d: PathFollow2D = get_parent()
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $Hitbox

@export_group("Speed Settings")
@export var SPEED: float = 150.0
@export var CHASING_SPEED: float = 200.0

@export_group("Sounds")
@export var detect_sounds: Array[AudioStream] = []

var current_state: State = State.PATROL
var target: Node2D = null
var last_position_x: float = 0.0

enum State {PATROL, CHASE, RETURN_BASE, END}

func _ready() -> void:
	if not zone.body_entered.is_connected(_on_zone_body_entered):
		zone.body_entered.connect(_on_zone_body_entered)
	if not zone.body_exited.is_connected(_on_zone_body_exited):
		zone.body_exited.connect(_on_zone_body_exited)
	if not kill_zone.body_entered.is_connected(_on_kill_zone_body_entered):
		kill_zone.body_entered.connect(_on_kill_zone_body_entered)

	if not zone.area_entered.is_connected(_on_zone_area_entered):
		zone.area_entered.connect(_on_zone_area_entered)
	if not zone.area_exited.is_connected(_on_zone_area_exited):
		zone.area_exited.connect(_on_zone_area_exited)
	if not kill_zone.area_entered.is_connected(_on_kill_zone_area_entered):
		kill_zone.area_entered.connect(_on_kill_zone_area_entered)
		
	last_position_x = global_position.x

func _physics_process(delta: float) -> void:
	match current_state:
		State.PATROL:
			base_movement(delta)
		State.CHASE:
			chasing()
		State.RETURN_BASE:
			return_start_pos()
		State.END:
			velocity = Vector2.ZERO
			move_and_slide()

	var delta_x = global_position.x - last_position_x

	if delta_x > 0.01:
		sprite.flip_h = false
		kill_zone.scale.x = 1
		zone.scale.x = 1
		hitbox.position.x = -10
	elif delta_x < -0.01:
		sprite.flip_h = true
		kill_zone.scale.x = -1
		zone.scale.x = -1
		hitbox.position.x = 10

	last_position_x = global_position.x

	if velocity.x > 0.1:
		sprite.flip_h = false
	elif velocity.x < -0.1:
		sprite.flip_h = true

func base_movement(delta: float) -> void:
	if path_follow_2d:
		path_follow_2d.progress += SPEED * delta

func chasing() -> void:
	if target:
		var direction_to_player = (target.global_position - global_position).normalized()
		velocity = direction_to_player * CHASING_SPEED
		move_and_slide()

func _on_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body
		current_state = State.CHASE
		play_sound()

func _on_zone_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		current_state = State.RETURN_BASE

func _on_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_body"):
		target = area
		current_state = State.CHASE

func _on_zone_area_exited(area: Area2D) -> void:
	if area == target:
		target = null
		current_state = State.RETURN_BASE

func return_start_pos() -> void:
	if not path_follow_2d:
		return

	if global_position.distance_to(path_follow_2d.global_position) < 5.0:
		position = Vector2.ZERO
		current_state = State.PATROL
	else:
		var direction_to_start = (path_follow_2d.global_position - global_position).normalized()
		velocity = direction_to_start * CHASING_SPEED
		move_and_slide()

func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("player_detected"):
			body.player_detected()
			current_state = State.END

func _on_kill_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_body"):
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("player_detected"):
			player.player_detected()
			current_state = State.END

func player_detected() -> void:
	pass

func play_sound() -> void:
	var choosed_sound = detect_sounds.pick_random()
	$DetectSound.stream = choosed_sound
	print(choosed_sound)
	$DetectSound.play()
