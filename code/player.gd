extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_sound: AudioStreamPlayer2D = $AttackSound

@export var health_bar: Control

var is_attacking = false
var is_dead = false  # 💀 état de mort

# Vie
var max_health = 100
var current_health = 100

# Sons
var son_attaque_1 = preload("res://asset/sons/666herohero-slash-21834.mp3")
var son_attaque_2 = preload("res://asset/sons/daviddumaisaudio-sword-slash-and-swing-185432 (1).mp3")

func _ready():
	animated_sprite_2d.play("idle")
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	print(health_bar)
	if health_bar:
		health_bar.update_health(current_health)

func _process(_delta):
	# 💀 si mort → plus rien
	if is_dead:
		return

	# 🚫 bloque les attaques si en cours
	if is_attacking:
		return

	# Attaques
	if Input.is_action_just_pressed("pierre"):
		play_attack("attaque_1", son_attaque_1)

	if Input.is_action_just_pressed("papier"):
		play_attack("attaque_2", son_attaque_2)

	if Input.is_action_just_pressed("sciseaux"):
		play_attack("attaque_3", son_attaque_1)

	# TEST dégâts
	if Input.is_action_just_pressed("test"):
		take_damage(10)

func play_attack(anim, son):
	is_attacking = true
	animated_sprite_2d.play(anim)
	attack_sound.stream = son
	attack_sound.play()

# 💥 dégâts + mort
func take_damage(damage):
	if is_dead:
		return

	current_health -= damage
	current_health = clamp(current_health, 0, max_health)

	if health_bar:
		health_bar.update_health(current_health)

	# 💥 jouer animation de hit si pas déjà en attaque
	if not is_attacking:
		is_attacking = true
		animated_sprite_2d.play("take_hit")

	# 💀 vérifier mort
	if current_health <= 0:
		die()

func die():
	is_dead = true
	animated_sprite_2d.play("death")
	print("Le joueur est mort 💀")

func _on_animation_finished():
	if is_dead:
		return

	# Si animation d'attaque ou de hit terminée → idle
	if animated_sprite_2d.animation.begins_with("attaque") or animated_sprite_2d.animation == "take_hit":
		is_attacking = false
		animated_sprite_2d.play("idle")
