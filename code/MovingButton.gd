extends Button
class_name MovingButton

@export var player_id := 1

@export var base_speed := 120.0
@export var max_speed := 260.0
@export var acceleration := 10.0
@export var slowdown := 15.0

var speed := 0.0
var velocity := Vector2.ZERO

var is_locked := false
var choice := ""

var collision_cooldown := 0.0

@onready var manager = get_tree().get_first_node_in_group("ui_manager")


func _ready():
	randomize()

	speed = base_speed

	# direction initiale fixe aléatoire
	var directions = [
		Vector2.LEFT,
		Vector2.RIGHT,
		Vector2.UP,
		Vector2.DOWN,
		Vector2(1,1).normalized(),
		Vector2(-1,1).normalized(),
		Vector2(1,-1).normalized(),
		Vector2(-1,-1).normalized()
	]

	velocity = directions.pick_random()


func _process(delta):
	if is_locked:
		return

	collision_cooldown -= delta

	position += velocity * speed * delta

	_bounce_on_walls()
	_check_button_collisions()


func _bounce_on_walls():
	var parent = get_parent() as Control

	if parent == null:
		return

	var area = parent.size

	var wall_hit = false

	# X
	if position.x <= 0:
		position.x = 0
		velocity.x *= -1
		wall_hit = true

	elif position.x + size.x >= area.x:
		position.x = area.x - size.x
		velocity.x *= -1
		wall_hit = true

	# Y
	if position.y <= 0:
		position.y = 0
		velocity.y *= -1
		wall_hit = true

	elif position.y + size.y >= area.y:
		position.y = area.y - size.y
		velocity.y *= -1
		wall_hit = true

	# aucune modification de vitesse sur mur
	if wall_hit:
		pass


func _check_button_collisions():

	if collision_cooldown > 0:
		return

	for other in get_tree().get_nodes_in_group("buttons"):

		if other == self:
			continue

		if not other is MovingButton:
			continue

		var distance = global_position.distance_to(other.global_position)

		if distance < size.x:

			collision_cooldown = 0.1
			other.collision_cooldown = 0.1

			# direction entre boutons
			var push_direction = (global_position - other.global_position).normalized()

			if push_direction == Vector2.ZERO:
				push_direction = Vector2.RIGHT

			# séparation
			position += push_direction * 8
			other.position -= push_direction * 8

			# rebond
			velocity = push_direction
			other.velocity = -push_direction

			_apply_collision_effect(other)
			


func _apply_collision_effect(other):
	# accélération générale
	speed += acceleration

	# limite vitesse
	speed = clamp(speed, 40, max_speed)

	# ralentissement si touche Rock
	if other.text == "Rock":
		speed -= slowdown

	# Paper = aucune modification

	# clamp sécurité
	speed = clamp(speed, 40, max_speed)


func _pressed():
	if is_locked:
		return

	var local_choice = _extract_choice_from_name()

	var player := 1
	if name.ends_with("J2"):
		player = 2

	if manager == null:
		push_error("Manager introuvable")
		return

	manager.register_choice(player, local_choice)

	lock_choice()

	print("Choix :", choice, " | Player :", player)

func _extract_choice_from_name():
	# Btn_Rock_J1 → Rock
	var parts = name.split("_")

	if parts.size() >= 2:
		return parts[1]

	return ""

func lock_choice():
	is_locked = true


func reset_button():

	is_locked = false

	choice = ""

	speed = base_speed

	randomize()

	var directions = [
		Vector2.LEFT,
		Vector2.RIGHT,
		Vector2.UP,
		Vector2.DOWN,
		Vector2(1,1).normalized(),
		Vector2(-1,1).normalized(),
		Vector2(1,-1).normalized(),
		Vector2(-1,-1).normalized()
	]

	velocity = directions.pick_random()
