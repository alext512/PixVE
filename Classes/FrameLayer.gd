class_name FrameLayer

var frame_number = 0  #STARTS FROM 1,1 # Is this data useful?
var layer_number = 0

var clip_used
var frame_of_clip = 0
var offset_framelayer

# IMPORTANT: In case of basic clips,  the clip_used will be the same clip, and the frame is the frame of the spritesheet. Currently no reordering will be posible for basic clips (but might reconsider later).

func _init(frame_number : int, layer_number : int) -> void:
	self.frame_number = frame_number
	self.layer_number = layer_number
	self.offset_framelayer = Vector2(0, 0)
	
func get_clip():
	if clip_used != null:
		return clip_used
	else:
		return null

func set_clip(clip):
	if clip_used != null:
		clip_used = clip
	else:
		print("clip button was null in a framelayer, while trying to set clip.")
		

