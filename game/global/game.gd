extends Node

const TIME_LIMIT = 30

var is_started = false setget _set_game_started
var score_current = 0 setget _set_score_current
var used_eggs = 0
var score_best = 0
var total_eggs = 0
var time
var bonus_time setget _set_bonus_time
var rank

signal start_game
signal end_game
signal score_current_changed
signal time_changed

func _ready():
	randomize()

func _process(delta):
	time -= delta
	emit_signal("time_changed")
	
	if time <= 0:
		time_up()

func _set_game_started(new_value):
	if new_value:
		is_started = true
		score_current = 0
		used_eggs = 0
		var load_data = utils.load_play_data("user://play.data")
		if load_data != null:
			score_best = load_data["score_best"]
			total_eggs = load_data["total_eggs"]
		time = TIME_LIMIT
		set_process(true)
		emit_signal("start_game")
	else:
		is_started = false
		update_score_best()
		update_total_eggs()
		var save_data = { "score_best" : score_best,
		                  "total_eggs" : total_eggs
		}
		utils.save_play_data("user://play.data", save_data)
		emit_signal("end_game")

func _set_score_current(new_value):
	if is_started:
		score_current = new_value
		self.bonus_time = round(rand_range(1, 3) * 10) / 10
		emit_signal("score_current_changed")

func _set_bonus_time(new_value):
	bonus_time = new_value
	time += bonus_time

func is_high_score(score):
	if score > score_best:
		return true
	else:
		return false

func update_score_best():
	if is_high_score(score_current):
		score_best = score_current

func update_total_eggs():
	total_eggs += used_eggs

func time_up():
	set_process(false)
	self.is_started = false