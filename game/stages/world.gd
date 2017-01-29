extends Node

var egg
func _ready():
	egg = get_node("egg")
	game.connect("start_game", self, "_on_start_game")
	game.connect("end_game", self, "_on_end_game")
	egg.connect("state_changed", self, "_on_egg_state_changed")	

func _on_start_game():
	egg.reset_state()
	
func _on_end_game():
	egg.stop()

func _on_egg_state_changed():
	if !game.is_started:
		return
	if egg.get_state() == egg.STATE_WASTED:
		game.used_eggs += 1
	elif egg.get_state() == egg.STATE_BROKEN:
		game.score_current += 1
		game.used_eggs += 1
