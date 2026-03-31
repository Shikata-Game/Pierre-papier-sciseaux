extends Control

@onready var barre = $Barre

var max_health = 100
var current_health = 100

func _ready():
	barre.max_value = max_health
	barre.value = current_health

func update_health(value):
	current_health = clamp(value, 0, max_health)
	
	# animation fluide 🔥
	var tween = create_tween()
	tween.tween_property(barre, "value", current_health, 0.3)

	# effet couleur (optionnel)
	if current_health < 30:
		barre.modulate = Color(1, 0, 0)
	else:
		barre.modulate = Color(1, 1, 1)
