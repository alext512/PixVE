class_name ClipTreeItem extends TreeItem

var clip

#func _init(clip_name : String, clip_type) -> void:  #STARTS FROM 1,1
#	clip = clip_type.new()
#	set_clip_name(clip_name)

func set_clip_name(clip_name):
	clip.clip_name = clip_name
	set_text(0, clip_name)

func set_clip_colors(color_bg, color_text):
	set_custom_color(0, color_bg) # red
	set_custom_bg_color(0, color_text) # semi-transparent green background
	clip.color_bg = color_bg
	clip.color_text = color_text


#func init_basic_clip(clip_name, dimensions, image_absolute_path, color_bg, color_text):
#	clip = BasicClip.new()
#	set_clip_colors(color_bg, color_text)
#	set_clip_name(clip_name)
