extends Button
class_name MovingButton

@export var speed := 80.0
@export var min_change_time := 1.0
@export var max_change_time := 2.5
@export var player_id := 1

var choice := ""
var is_locked := false

var direction := Vector2.ZERO
var change_time := 0.0

@onready var manager = get_tree().get_first_node_in_group("ui_manager")


func _ready():
	randomize()
	_set_random_direction()


func _process(delta):
	if is_locked:
		return

	change_time -= delta

	if change_time <= 0:
		_set_random_direction()

	position += direction * speed * delta
	_bounce_on_screen()


func _set_random_direction():
	direction = Vector2(
		randf_range(-1, 1),
		randf_range(-1, 1)
	).normalized()

	change_time = randf_range(min_change_time, max_change_time)


func _bounce_on_screen():
	var parent = get_parent() as Control
	if parent == null:
		return

	var parent_size = parent.size

	# rebond horizontal
	if position.x <= 0:
		position.x = 0
		direction.x *= -1
	elif position.x + size.x >= parent_size.x:
		position.x = parent_size.x - size.x
		direction.x *= -1

	# rebond vertical
	if position.y <= 0:
		position.y = 0
		direction.y *= -1
	elif position.y + size.y >= parent_size.y:
		position.y = parent_size.y - size.y
		direction.y *= -1
	var screen_size = get_viewport_rect().size

	# rebond horizontal
	if position.x <= 0:
		position.x = 0
		direction.x *= -1
	elif position.x + size.x >= screen_size.x:
		position.x = screen_size.x - size.x
		direction.x *= -1

	# rebond vertical
	if position.y <= 0:
		position.y = 0
		direction.y *= -1
	elif position.y + size.y >= screen_size.y:
		position.y = screen_size.y - size.y
		direction.y *= -1


func _pressed():
	if is_locked:
		return

	if manager == null:
		push_error("UI Manager introuvable (group 'ui_manager')")
		return

	choice = text
	manager.register_choice(player_id, choice)

	lock_choice()

	print("Joueur ", player_id, " a choisi : ", choice)


func lock_choice():
	is_locked = true
	speed = 0


func reset_button():
	is_locked = false
	speed = 80.0
	_set_random_direction()
