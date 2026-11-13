extends CharacterBody2D

@onready var detection_zone: Area2D = $Zone
@onready var kill_zone: Area2D = $KillZone
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $Hitbox

@export_group("Speed Settings")
@export var SPEED: float = 150.0
@export var CHASING_SPEED: float = 200.0
@export var PATROL_RADIUS: float = 200.0

@export_group("Sounds")
@export var detect_sounds: Array[AudioStream] = []

var current_state: State = State.PATROL
var target: Node2D = null
var spawn_pos: Vector2
var patrol_timer: float = 0.0
var patrol_duration: float = 3.0

enum State {PATROL, CHASE, END}

func _ready() -> void:
	spawn_pos = global_position
	if not detection_zone.body_entered.is_connected(_on_detection_entered):
		detection_zone.body_entered.connect(_on_detection_entered)
	if not detection_zone.body_exited.is_connected(_on_detection_exited):
		detection_zone.body_exited.connect(_on_detection_exited)
	if not kill_zone.body_entered.is_connected(_on_kill_zone_body_entered):
		kill_zone.body_entered.connect(_on_kill_zone_body_entered)

	if not detection_zone.area_entered.is_connected(_on_detection_area_entered):
		detection_zone.area_entered.connect(_on_detection_area_entered)
	if not 	detection_zone.area_exited.is_connected(_on_detection_area_exited):
		detection_zone.area_exited.connect(_on_detection_area_exited)
	if not kill_zone.area_entered.is_connected(_on_kill_zone_area_entered):
		kill_zone.area_entered.connect(_on_kill_zone_area_entered)

	set_new_patrol_point()

func _physics_process(delta: float) -> void:
	match current_state:
		State.PATROL:
			patrol(delta)
		State.CHASE:
			chase()
		State.END:
			velocity = Vector2.ZERO
			move_and_slide()

	if velocity.x > 0.1:
		sprite.flip_h = false
		kill_zone.scale.x = 1
		detection_zone.scale.x = 1
		hitbox.position.x = -10
	elif velocity.x < -0.1:
		sprite.flip_h = true
		kill_zone.scale.x = -1
		detection_zone.scale.x = -1
		hitbox.position.x = 10

func set_new_patrol_point() -> void:
	var random_offset = Vector2(randf_range(-PATROL_RADIUS, PATROL_RADIUS), randf_range(-PATROL_RADIUS, PATROL_RADIUS))
	var target_point = spawn_pos + random_offset
	navigation_agent.target_position = target_point
	patrol_timer = 0.0

func patrol(delta: float) -> void:
	patrol_timer += delta
	if navigation_agent.is_navigation_finished() or patrol_timer >= patrol_duration:
		set_new_patrol_point()
		return

	var next_pos = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(next_pos)
	velocity = direction * SPEED
	move_and_slide()

func chase() -> void:
	if not target or not is_instance_valid(target):
		current_state = State.PATROL
		set_new_patrol_point()
		return

	var direction = global_position.direction_to(target.global_position)
	velocity = direction * CHASING_SPEED
	move_and_slide()

func _on_detection_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body
		current_state = State.CHASE
		play_sound()

func _on_detection_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_body"):
		target = area
		current_state = State.CHASE

func _on_detection_exited(body: Node2D) -> void:
	if body == target:
		target = null
		current_state = State.PATROL
		set_new_patrol_point()

func _on_detection_area_exited(area: Area2D) -> void:
	if area == target:
		target = null
		current_state = State.PATROL
		set_new_patrol_point()

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
	$DetectSound.play()
