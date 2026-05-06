extends Control

@onready var label_timer = get_node("Label_Timer")
@onready var label_info = get_node_or_null("Label_Info")

var time_left := 5
var round_active := true

var choice_p1 := ""
var choice_p2 := ""

func _ready():
	start_round()


func start_round():
	time_left = 5
	round_active = true
	_update_timer_display()


func _process(delta):
	if not round_active:
		return

	time_left -= delta

	if time_left <= 0:
		time_left = 0
		round_active = false
		_on_time_up()

	_update_timer_display()


func _update_timer_display():
	label_timer.text = "Temps : " + str(int(time_left))


func _on_time_up():
	print("Temps écoulé !")

	if choice_p1 == "":
		choice_p1 = _random_choice()

	if choice_p2 == "":
		choice_p2 = _random_choice()

	_check_result()


func _random_choice():
	var choices = ["Rock", "Paper", "Scissors"]
	return choices.pick_random()


func register_choice(player_id, choice):
	if player_id == 1:
		choice_p1 = choice
	else:
		choice_p2 = choice

	print("P1:", choice_p1, " | P2:", choice_p2)

	_check_result()


func _check_result():
	if choice_p1 == "" or choice_p2 == "":
		return

	var result = _get_winner(choice_p1, choice_p2)
	label_info.text = result

	_reset_round()


func _get_winner(p1, p2):
	if p1 == p2:
		return "Égalité !"

	if (p1 == "Rock" and p2 == "Scissors") \
	or (p1 == "Paper" and p2 == "Rock") \
	or (p1 == "Scissors" and p2 == "Paper"):
		return "Joueur 1 gagne !"

	return "Joueur 2 gagne !"


func _reset_round():
	await get_tree().create_timer(2.0).timeout

	choice_p1 = ""
	choice_p2 = ""

	if label_info:
		label_info.text = "Faites votre choix"

	for btn in get_tree().get_nodes_in_group("buttons"):
		btn.reset_button()

	start_round()
