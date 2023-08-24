class_name ClipButton extends Button

var clip

#func _init(clip_name : String, clip_type) -> void:  #STARTS FROM 1,1
#	clip = clip_type.new()
#	set_clip_name(clip_name)

func set_clip_name(clip_name):
	clip.clip_name = clip_name
	text = clip_name
