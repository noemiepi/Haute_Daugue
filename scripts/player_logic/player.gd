extends CharacterBody2D

# Movement logic
@export_group("Movement Settings")
@export var SPEED: float = 200.0
@export var RUN_SPEED: float = 1.4
var can_move: bool = true
var is_sneaked: bool = false
var is_hided: bool = false
var is_detected: bool = false

@export_group("Stamina Settings")
@onready var stamina_bar: ProgressBar = $Visuals/HeadAnimatedSprite2D/StaminaBar
@export var max_stamina: float = 100.0
@export var stamina_regen: float = 10.0
@export var stamina_consumption: float = 23.3
var stamina: float = 100.0
var is_exhausted: bool = false

@export_group("Camera Settings")
@export var default_zoom: Vector2 = Vector2(0.9, 0.9)

# Body logic
@export_group("Body Logic")
@export var body_growth_amount: float = 1.0
var segment_scene = preload("res://scenes/characters/body_segment.tscn")
var BODY_LENGTH: int = -16

@export_group("Sounds")
@export var detected_sounds: Array[AudioStream] = []

@export_group("Other")
@export var has_golden_sausage: bool = false

# Animation
@onready var head_animated_sprite_2d: AnimatedSprite2D = $Visuals/HeadAnimatedSprite2D
@onready var body_legs: Area2D = $Visuals/BodyLegs
@onready var body_collision_shape_2d: CollisionShape2D = $Visuals/BodyLegs/BodyCollisionShape2D
@onready var legs_animated_sprite_2d: AnimatedSprite2D = $Visuals/BodyLegs/LegsAnimatedSprite2D
@onready var mouth_position_marker_2d: Marker2D = $MouthPositionMarker2D

# Particle
@onready var body_particle: GPUParticles2D = $Visuals/BodyLegs/GPUParticles2D
@onready var footstep_particles: Node2D = $Visuals/BodyLegs/FootstepParticle/GPUParticles2D

# Score
var score: int = 0
signal score_changed(score: int)

# Signal
signal defeated()
signal win()
signal easter_egg()
signal extra_sausage_found()

func _ready() -> void:
	#call_deferred("get_golden_sausage")
	pass

# ----------------
#  PHYSIC MANAGEMENT
# ----------------

func _physics_process(delta: float) -> void:
	if can_move:
		# Walk animation
		if velocity.length() > 0:
			head_animated_sprite_2d.animation = "run"
			legs_animated_sprite_2d.animation = "run"
		else:
			head_animated_sprite_2d.animation = "idle"
			legs_animated_sprite_2d.animation = "idle"
		
		# Move the player into the 8 directions
		var input_vector := Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_down")  - Input.get_action_strength("move_up")
		)
		
		# Running et stamina logic
		var actual_speed = SPEED
		legs_animated_sprite_2d.speed_scale = 1.0
		head_animated_sprite_2d.speed_scale = 1.0
		
		if stamina >= 100.0:
			stamina_bar.visible = false
		
		if Input.is_action_pressed("run") and velocity.length() > 0 and not is_exhausted:
			actual_speed *= RUN_SPEED
			stamina -= stamina_consumption * delta
			legs_animated_sprite_2d.speed_scale = 5.0
			head_animated_sprite_2d.speed_scale = 3.0
			stamina_bar.visible = true
			if stamina <= 0:
				is_exhausted = true
		else:
			stamina += stamina_regen * delta
			legs_animated_sprite_2d.speed_scale = 1.0
			head_animated_sprite_2d.speed_scale = 1.0
			if is_exhausted and stamina >= 100.0:
				is_exhausted = false
		
		stamina = clamp(stamina, 0, max_stamina)
		stamina_bar.value = stamina

		if is_exhausted:
			stamina_bar.modulate = Color.RED
		else:
			stamina_bar.modulate = Color.WEB_GREEN

		velocity = input_vector.normalized() * actual_speed
		move_and_slide()

	# Change direction based on velocity
	if velocity.x > 0.1:
		$Visuals.scale.x = 1
		stamina_bar.fill_mode = 1
	elif velocity.x < -0.1:
		$Visuals.scale.x = -1
		stamina_bar.fill_mode = 0

# ----------------
#  END MANAGMENT
# ----------------

func player_detected() -> void:
	can_move = false
	stamina_bar.visible = false
	$"../MenuGroup/PauseMenu".can_pause = false
	head_animated_sprite_2d.animation = "detected"
	legs_animated_sprite_2d.animation = "idle"

	play_detected_sound()
	
	var tween_in = create_tween()
	var zoom_v = Vector2(1.5, 1.5)
	tween_in.tween_property($Camera2D, "zoom", zoom_v, 0.4).set_trans(Tween.TRANS_SINE)
	
	await get_tree().create_timer(2.0).timeout
	defeated.emit()

func player_win() -> void:
	can_move = false
	stamina_bar.visible = false
	$"../MenuGroup/PauseMenu".can_pause = false
	head_animated_sprite_2d.animation = "idle"
	legs_animated_sprite_2d.animation = "idle"
	
	var tween_in = create_tween()
	var zoom_v = Vector2(1.5, 1.5)
	tween_in.tween_property($Camera2D, "zoom", zoom_v, 0.4).set_trans(Tween.TRANS_SINE)
	win.emit()

func get_golden_sausage() -> void:
	has_golden_sausage = true
	easter_egg.emit()

# -------------
# 	  BODY 
# --------------

func add_body() -> void:
	var new_segment = segment_scene.instantiate()
	
	body_legs.position.x -= body_growth_amount
	new_segment.position.x = BODY_LENGTH
	footstep_particles.position.x += 1
	$Visuals/BodyParts.add_child(new_segment)

	var shape = body_collision_shape_2d.shape as RectangleShape2D
	shape.size.x += body_growth_amount
	body_collision_shape_2d.position.x += body_growth_amount / 2.0

	BODY_LENGTH -= 1
	stamina = 100
	if stamina_regen >= 5:
		stamina_regen -= 1
		
	add_score()

# -------------
# 	  SCORE 
# --------------

func add_score() -> void:
	score += 1
	score_changed.emit(score)

func _search_bush(item_name: String) -> void:
	can_move = false
	
	var tween_in = create_tween()
	var zoom_v = Vector2(1.5, 1.5)
	tween_in.tween_property($Camera2D, "zoom", zoom_v, 0.4).set_trans(Tween.TRANS_SINE)
	
	if item_name == "golden_sausage":
		get_golden_sausage()
	elif item_name == "sausage":
		add_score()
		extra_sausage_found.emit()
	elif item_name == "stick":
		pass

func _search_bush_finish() -> void:
	can_move = true
	
	var tween_out = create_tween()
	tween_out.tween_property($Camera2D, "zoom", default_zoom, 0.6).set_trans(Tween.TRANS_SINE)


# -----------------------
#   ANIMATION MANAGEMENT
# -----------------------

func anim_eat_sausage(target_zoom: float, sausage_node: Area2D) -> void:
	can_move = false
	stamina_bar.visible = false
	velocity = Vector2.ZERO
	
	# Front zoom
	var tween_in = create_tween()
	var zoom_v = Vector2(target_zoom, target_zoom)
	tween_in.tween_property($Camera2D, "zoom", zoom_v, 0.4).set_trans(Tween.TRANS_SINE)
	
	# Play animation
	head_animated_sprite_2d.animation = "eat"
	legs_animated_sprite_2d.animation = "idle"
	await get_tree().create_timer(1.0).timeout
	
	$EatSound.play()
	
	# Move sausage sprite to player mouth
	var sausage_sprite = sausage_node.get_node("Sprites/collectible_sprite")
	if sausage_sprite:
		var tween_move = create_tween()
		tween_move.tween_property(sausage_sprite, "global_position", mouth_position_marker_2d.global_position, 0.3).set_trans(Tween.TRANS_QUINT)
	
	# Tiny shake while eating
	await get_tree().create_timer(0.2).timeout
	_screenshake(10.0, 0.1)
	
	if is_instance_valid(sausage_node):
		sausage_node.queue_free()
	
	# Add new body part
	body_particle.emitting = true
	add_body()
	
	await get_tree().create_timer(0.5).timeout
	
	# Zoom out
	var tween_out = create_tween()
	tween_out.tween_property($Camera2D, "zoom", default_zoom, 0.6).set_trans(Tween.TRANS_SINE)
	
	can_move = true

func _on_legs_animated_sprite_2d_frame_changed() -> void:
	if legs_animated_sprite_2d.animation == "run":
		if legs_animated_sprite_2d.frame % 3 == 0:
			footstep_particles.restart()
			footstep_particles.emitting = true
			$FoodstepsSound.play()

# ---------
#   SOUNDS
# ---------

func play_detected_sound() -> void:
	var choosed_sound = detected_sounds.pick_random()
	$DetectedSounds.stream = choosed_sound
	$DetectedSounds.play()

# ---------
#   UTILS
# ---------

func _screenshake(intensity: float, duration: float) -> void:
	var tween = create_tween()
	for i in range(10):
		var random_offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property($Camera2D, "offset", random_offset, duration / 20.0)

	tween.tween_property($Camera2D, "offset", Vector2.ZERO, duration / 20.0)
