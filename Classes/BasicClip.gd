class_name BasicClip extends Clip  # Replace with the actual path to Clip.gd

var dimensions : Vector2 # stores the dimentions of the image. Useful for spritesheets, since the app will need to split the spritesheet based on dimentions.
#if both x and y are equal or less than the actual image, then the image will consist of 1 sprite.
#var image_texture: ImageTexture = null

var texture_array
var image: Image = null
var path

var _sprites

func render_frame(frame: int, position : Vector2, canvas, zoom) -> void: # overriden in BasicClip and ComplexClip
	print("before crash clip name: " + clip_name)
	var clips_number_of_frames = frame_layer_table_hbox.get_child_count() - 1 # -1 because of the labels
	var actual_frame = frame % clips_number_of_frames
	# If frames are higher than the clip's frames, we get the remainder of that division.
	# So e.g. trying to access frame 11 of a clip with 10 frames will get us the 1st frame.
	print(clip_name)
	var texture_rect = TextureRect.new()
	if texture_array == null:
		return
	texture_rect.texture = texture_array[actual_frame-1]
	texture_rect.stretch_mode = 0#ignore size#rect_min_size = image_texture.get_size()
	#texture_rect.expand_mode = 1
	texture_rect.custom_minimum_size = dimensions * zoom
	texture_rect.set_position(position*zoom)
	#for child in canvas.get_children(): #not here.
	#	canvas.remove_child(child)
	texture_rect.texture_filter = 1
	canvas.add_child(texture_rect)

func set_image_dimensions(dim):
	print("setting image dimensions", clip_name)
	dimensions = dim
	if image == null:
		_sprites = 1
		return
	texture_array = []
	var clip_x = int(dimensions.x)
	#var y = dimensions.y # we don't care about that. Only the x dimension matters. The given spritesheets must be one row of sprites.
	var image_x = image.get_width()
	
	if clip_x == 0:
		_sprites = 1 # set the dimensions here as well?
		dimensions = Vector2(image.get_width(), image.get_height())
	elif image_x % clip_x == 0:
		_sprites = int(image_x/clip_x)
		if _sprites == 0:
			_sprites = 1
	else:
		print("The image width is not divisible with the clip's width.")
		_sprites = 1
	print("creating texture_array", clip_name)
	for i in range(_sprites):
		print("creating texture_array repeat", clip_name)
		texture_array.append(ImageTexture.new())
		texture_array[i].set_image(image.get_region(Rect2(Vector2(dimensions.x * i, 0), Vector2(dimensions.x, dimensions.y))))
		#texture_array[i].flags = 0#texture_array[i].flags & ~int(ImageTexture.FLAG_FILTER)
		#texture_array[i].texture_filter = 1

		#texture_array.append(image.get_region(Rect2(Vector2(dimensions.x * i, 0), Vector2(dimensions.x, dimensions.y))))
		print("BasicClip Image size: ", texture_array[i].get_size())
		
func get_sprites():
	return _sprites
	
#func _init(frames: int, image: ImageTexture) -> void:
#	self.frames = frames
#	self.image_texture = image

# Overrides the render_frame method from the parent class
#func render_frame(frame: int) -> void:
#	# Here you would render the frame from the image_texture
#	pass
func arg_clip_is_child_of_self(parent_clip_to_check):
	return false
