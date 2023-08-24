class_name NumberedFrameLayerButton extends Button

var frameLayer

func _init(frame_number : int, layer_number : int) -> void:  #STARTS FROM 1,1
	self.frameLayer = FrameLayer.new(frame_number, layer_number)

func get_frame():
	return frameLayer.frame_number
	
func get_layer():
	return frameLayer.layer_number

func set_frame(frame):
	frameLayer.frame_number = frame

func set_layer(layer):
	frameLayer.layer_number = layer

func create_deep_copy():
	var copied_framelayer_button = NumberedFrameLayerButton.new(frameLayer.frame_number, frameLayer.layer_number)
	copied_framelayer_button.frameLayer.clip_button_used = frameLayer.clip_button_used
	copied_framelayer_button.frameLayer.frame_of_clip = frameLayer.frame_of_clip
	copied_framelayer_button.frameLayer.offset_framelayer = Vector2(frameLayer.offset_framelayer.x, frameLayer.offset_framelayer.y)
	return copied_framelayer_button
