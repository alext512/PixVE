# Logger.gd
extends Node


var vbox_log_container = VBoxContainer.new()
var vertical_log_scroll = ScrollContainer.new()

#var log_text = Label.new()
var last_message = ""

var need_to_scroll_down = false

func _ready():
	vbox_log_container.add_theme_constant_override("separation", -5)
func _process(delta):
	if need_to_scroll_down:
		vertical_log_scroll.scroll_vertical = vertical_log_scroll.get_v_scroll_bar().max_value
		need_to_scroll_down = false
func set_parent(parent): #runs during _ready() of the main script. This is not the line that is shown in the error.
	parent.add_child(vertical_log_scroll)
	vertical_log_scroll.add_child(vbox_log_container)
	#log_text.bbcode_enabled = true
	#log_text.scroll_active = true
	vertical_log_scroll.custom_minimum_size = Vector2(50, 50)
	vbox_log_container.custom_minimum_size = Vector2(50, 50)

func log_message(message):
	var log_text = Label.new()
	log_text.set_size(Vector2(100,100))
	log_text.text = log_text.text + (message)
	vbox_log_container.add_child(log_text)
	need_to_scroll_down = true


func log_canvas_movement_message(message):
	if vbox_log_container.get_child_count() > 0:
		var last_child = vbox_log_container.get_child(vbox_log_container.get_child_count()-1)
		if last_child.text.begins_with("Relative Move"):
			vbox_log_container.remove_child(last_child)
	log_message(message)
	

