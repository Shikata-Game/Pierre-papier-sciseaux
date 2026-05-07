extends Control

@onready var label_timer = get_node("Label_Timer")
@onready var label_info = get_node("Label_Info")

var time_left := 5.0
var round_active := false
var round_ended := false

var choice_p1 := ""
var choice_p2 := ""


func _ready():
	start_round()


func start_round():
	time_left = 5.0

	round_active = true
	round_ended = false

	choice_p1 = ""
	choice_p2 = ""

	label_info.text = "Faites votre choix"

	_update_timer_display()

	print("====================")
	print("NOUVEAU ROUND")



func _process(delta):
	if not round_active:
		return

	time_left -= delta

	if time_left <= 0:
		time_left = 0
		_update_timer_display()

		_end_round_by_timeout()
		return

	_update_timer_display()


func _update_timer_display():
	label_timer.text = "Temps : " + str(ceil(time_left))


func register_choice(player_id, choice):
	# sécurité anti-double input
	if not round_active:
		return

	if round_ended:
		return

	if player_id == 1:
		choice_p1 = choice
	else:
		choice_p2 = choice

	print("P1:", choice_p1, " | P2:", choice_p2)

	# vérifier si les deux joueurs ont choisi
	if choice_p1 != "" and choice_p2 != "":
		_finish_round()


func _end_round_by_timeout():
	if round_ended:
		return

	print("Temps écoulé !")

	# choix auto si joueur n'a rien choisi
	if choice_p1 == "":
		choice_p1 = _random_choice()

	if choice_p2 == "":
		choice_p2 = _random_choice()

	_finish_round()


func _finish_round():
	if round_ended:
		return

	round_ended = true
	round_active = false

	var result = _get_winner(choice_p1, choice_p2)

	label_info.text = result

	print(result)

	_reset_round()


func _random_choice():
	var choices = ["Rock", "Paper", "Scissors"]
	return choices.pick_random()


func _get_winner(p1, p2):
	if p1 == p2:
		return "Égalité !"

	if (p1 == "Rock" and p2 == "Scissors") \
	or (p1 == "Paper" and p2 == "Rock") \
	or (p1 == "Scissors" and p2 == "Paper"):
		return "Joueur 1 gagne !"

	return "Joueur 2 gagne !"


func _reset_round():
	await get_tree().create_timer(3.0).timeout

	# reset boutons
	for btn in get_tree().get_nodes_in_group("buttons"):
		btn.reset_button()

	start_round()
