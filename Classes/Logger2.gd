"""
# Logger.gd
extends Node

var log_text = Label.new()
var last_message = ""

func set_parent(parent): #runs during _ready() of the main script. This is not the line that is shown in the error.
	parent.add_child(log_text)
	#log_text.bbcode_enabled = true
	#log_text.scroll_active = true
	log_text.custom_minimum_size = Vector2(50, 50)

func log_message(message):
	log_text.text = log_text.text + ("\n" + message)
	last_message = message


func log_canvas_movement_message(message):
	if last_message.begins_with("Relative Move"):
		log_text.text.slice(0, log_text.text.length() - last_message.length())
	log_message(message)

	
func log_add_newline():
	log_text.add_text("\n")
"""
