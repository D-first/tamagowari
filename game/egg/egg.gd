extends Node2D

const MAX_HP = 10
const MAX_DAMAGE = 3
const MIN_DAMAGE = 1
const LIMIT_POWER = 150

const STATE_BASIC  = 0
const STATE_CRACK1 = 1
const STATE_CRACK2 = 2
const STATE_CRACK3 = 3
const STATE_CRACK4 = 4
const STATE_CRACK5 = 5
const STATE_WASTED = 6
const STATE_BROKEN = 7

export var TP_SPEED_BASIC = 10
export var TP_SPEED_CRACK1 = 20
export var TP_SPEED_CRACK2 = 40
export var TP_SPEED_CRACK3 = 70
export var TP_SPEED_CRACK4 = 150
export var TP_SPEED_CRACK5 = 300

onready var texture = get_node("texture")
onready var anim = get_node("anim")
onready var anim_success = get_node("anim_success")
onready var se = get_node("se")
onready var tp = get_node("tp")

var state

var hp = MAX_HP
var power = 0 setget _set_power
var is_hold = false
var is_broken = false

signal state_changed

func _ready():
	randomize()
	state = BasicState.new(self)
	set_process(true)

func _process(delta):
	if is_hold:
		utils.play_anim(anim, "hold", false, ["knock"])
		state.put_in_power(delta)
	else:
		self.power = 0

	if power > LIMIT_POWER:
		crush()

func knock():
	state.knock()

func hold():
	is_hold = true

func unhold():
	utils.stop_anim(anim, "hold")
	if get_state() != STATE_WASTED:
		texture.set_rotd(-20)
	is_hold = false

func try_to_break():
	state.try_to_break()

func change_state():
	if is_broken and get_state() != STATE_BROKEN:
		state = BrokenState.new(self)
	elif hp >= MAX_HP - 1:
		state = BasicState.new(self)
	elif hp >= MAX_HP - 3:
		state = Crack1State.new(self)
	elif hp >= MAX_HP - 5:
		state = Crack2State.new(self)
	elif hp >= MAX_HP - 7:
		state = Crack3State.new(self)
	elif hp >= MAX_HP - 9:
		state = Crack4State.new(self)
	elif hp >= 0:
		state = Crack5State.new(self)
	elif hp < 0:
		state = WastedState.new(self, state.choice_sprite())
	
	emit_signal("state_changed")

func get_state():
	if state extends BasicState:
		return STATE_BASIC
	elif state extends Crack1State:
		return STATE_CRACK1
	elif state extends Crack2State:
		return STATE_CRACK2
	elif state extends Crack3State:
		return STATE_CRACK3
	elif state extends Crack4State:
		return STATE_CRACK4
	elif state extends Crack5State:
		return STATE_CRACK5
	elif state extends WastedState:
		return STATE_WASTED
	elif state extends BrokenState:
		return STATE_BROKEN

func crush():
	unhold()
	hp = -1
	change_state()

func _set_power(new_value):
	power = new_value
	tp.set_value(new_value)

func reset_state():
	hp = MAX_HP
	change_state()

func stop():
	if is_processing():
		set_process(false)
	utils.stop_anim(anim)

class EggState:
	var egg
	var hp_condition
	var tp_speed = 0

	func _init(egg):
		self.egg = egg

	func knock():
		egg.se.play("knock")
		egg.anim.play("knock")
		damage()

		if egg.hp < hp_condition:
			egg.change_state()
	
	func damage():
		egg.hp = egg.hp - ((randi() % egg.MAX_DAMAGE) + egg.MIN_DAMAGE)
#		print(egg.hp)
	
	func put_in_power(delta):
		egg.power += tp_speed * delta
#		print(egg.power)
	
	func try_to_break():
		if egg.tp.get_value() == egg.tp.get_max():
			do_break()
			return true
		else:
			return false
	
	func do_break():
		egg.is_broken = true
		egg.change_state()

class BasicState extends EggState:
	
	var wasted_sprites = [
		load("res://egg/textures/wasted_1.tex")
	]

	func _init(egg).(egg):
#		egg.hp = self.egg.MAX_HP
		egg.texture.set_texture(load("res://egg/textures/normal.tex"))
		egg.texture.set_transform(Matrix32(deg2rad(-20), Vector2(0,0)))
		egg.texture.set_opacity(1)
		egg.texture.show()
		egg.anim_success.hide()
		egg.anim_success.set_frame(0)
#		egg.tp.show()
		hp_condition = egg.MAX_HP - 1
		tp_speed = egg.TP_SPEED_BASIC
	
	func knock():
		.knock()
	
	func choice_sprite():
		return wasted_sprites[randi() % wasted_sprites.size()]

class Crack1State extends EggState:

	var wasted_sprites = [
		load("res://egg/textures/wasted_1.tex")
	]

	func _init(egg).(egg):
		egg.texture.set_texture(load("res://egg/textures/crack_1.tex"))
		hp_condition = egg.MAX_HP - 3
		tp_speed = egg.TP_SPEED_CRACK1
	
	func knock():
		.knock()

	func choice_sprite():
		return wasted_sprites[randi() % wasted_sprites.size()]

class Crack2State extends EggState:

	var wasted_sprites = [
		load("res://egg/textures/wasted_2.tex")
	]

	func _init(egg).(egg):
		egg.texture.set_texture(load("res://egg/textures/crack_2.tex"))
		hp_condition = egg.MAX_HP - 5
		tp_speed = egg.TP_SPEED_CRACK2
	
	func knock():
		.knock()

	func choice_sprite():
		return wasted_sprites[randi() % wasted_sprites.size()]

class Crack3State extends EggState:
	
	var wasted_sprites = [
		load("res://egg/textures/wasted_3.tex")
	]

	func _init(egg).(egg):
		egg.texture.set_texture(load("res://egg/textures/crack_3.tex"))
		hp_condition = egg.MAX_HP - 7
		tp_speed = egg.TP_SPEED_CRACK3
	
	func knock():
		.knock()

	func choice_sprite():
		return wasted_sprites[randi() % wasted_sprites.size()]

class Crack4State extends EggState:
	
	var wasted_sprites = [
		load("res://egg/textures/wasted_4.tex"),
		load("res://egg/textures/wasted_4-2.tex"),
		load("res://egg/textures/wasted_4-3.tex"),
		load("res://egg/textures/wasted_4-4.tex")
	]

	func _init(egg).(egg):
		egg.texture.set_texture(load("res://egg/textures/crack_4.tex"))
		hp_condition = egg.MAX_HP - 9
		tp_speed = egg.TP_SPEED_CRACK4

	
	func knock():
		.knock()
	
	func choice_sprite():
		return wasted_sprites[randi() % wasted_sprites.size()]

class Crack5State extends EggState:
	
	var wasted_sprites = [
		load("res://egg/textures/wasted_5.tex"),
		load("res://egg/textures/wasted_5-2.tex"),
		load("res://egg/textures/wasted_5-3.tex"),
		load("res://egg/textures/wasted_5-4.tex")
	]

	func _init(egg).(egg):
		egg.texture.set_texture(load("res://egg/textures/crack_5.tex"))
		hp_condition = egg.MAX_HP
		tp_speed = egg.TP_SPEED_CRACK5
	
	func knock():
		.knock()
		
	func choice_sprite():
		return wasted_sprites[randi() % wasted_sprites.size()]	

class WastedState extends EggState:

	func _init(egg, texture).(egg):
		egg.texture.set_texture(texture)
		egg.se.play("wasted")
		
		egg.anim.play("wasted")
		yield(egg.anim, "finished")	
		change_state()
	
	func knock():
		pass
	
	func put_in_power(delta):
		pass
	
	func try_to_break():
		pass
		
	func change_state():
		egg.hp = egg.MAX_HP
		egg.state = egg.BasicState.new(egg)


class BrokenState extends EggState:

	func _init(egg).(egg):
		egg.tp.hide()
		egg.texture.set_texture(load("res://egg/textures/success_shell.tex"))
		egg.se.play("break")
		
		egg.anim.play("success")
		yield(egg.anim, "finished")	
		change_state()
	
	func knock():
		pass
	
	func put_in_power(delta):
		pass
	
	func try_to_break():
		pass
	
	func change_state():
		egg.is_broken = false
		egg.hp = egg.MAX_HP
		egg.state = egg.BasicState.new(egg)
