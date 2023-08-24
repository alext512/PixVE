class_name Clip

var frames: int = 0 # Default number of frames, can be overridden by subclasses (not used?)
var clip_name
var frame_layer_table_hbox #starts from 1,1 since the 2d array contains an extra row and column for labels.
# Render frame method, to be overridden by subclasses

var color_bg
var color_text

func render_frame(frame: int, position : Vector2, canvas, zoom) -> void: # overriden in BasicClip and ComplexClip
	pass

"""
func clip_is_child(clip_to_check): # when assigning a clip as reference in another clip, the parent clip should now be referenced in the newly referenced clip, to avoid circular reference.
	#This function should be executed by the newly referenced clip.
	for i in range(1, frame_layer_table_hbox.child_count()):
		for j in range(1, frame_layer_table_hbox.get_child(i).child_count()):
			var framelayer_button_to_check = frame_layer_table_hbox.get_child(i).get_child(j)
			if framelayer_button_to_check.frameLayer.get_clip() == clip_to_check:
				return true
			else:
				return false
				"""
#func child_clip_is_circular_reference(child_clip)
