extends Node

func _ready():
	pass

func get_main_node():
	var root_node = get_tree().get_root()
	return root_node.get_child(root_node.get_child_count() - 1)

func save_play_data(path, data):
    var f = File.new()
    f.open(path, File.WRITE)
    f.store_var(data)
    f.close()

func load_play_data(path):
    var f = File.new()
    if f.file_exists(path):
        f.open(path, File.READ)
        var data = f.get_var()
        f.close()
        return data
    return null

func play_anim(anim_node, anim_name, forced=false, exc=[]):
	if forced:
		for exc_name in exc:
			if anim_node.is_playing() and anim_node.get_current_animation() == exc_name:
				return
		anim_node.play(anim_name)
	else:
		for exc_name in exc:
			if anim_node.is_playing() and anim_node.get_current_animation() != exc_name:
				return
		anim_node.play(anim_name)

func stop_anim(anim_node, anim_name=null):
	if !anim_name or anim_node.get_current_animation() == anim_name:
		anim_node.stop()