class_name TextClip extends Clip

var texts = []
var text_images = []
var image_path
var font_data_path

var font_image: Image = null # image of pixel font
var font_data_text
var texture_array


var textbox_size


func construct_texts():
	#var example_image = Image.new()
	#example_image.create(10, 15, false, Image.FORMAT_RGBA8)
	#print("example image dims: ", example_image.get_size())
	var log_message = ""
	#var font_image = Image.new()
	var font_data = {}
	
	""" # loaded when creating/modifying the clip
	# Load the font image.
	var image_texture = load(image_path)
	if image_texture == null:
		print("Failed to load image from path:", image_path)
		return
	font_image = image_texture.get_data()
	"""
	
	""" # loaded when creating/modifying the clip
	# Load the font data.
	var file = FileAccess.open(font_data_path, FileAccess.READ)
	var err = file.get_error()
	if err != OK:
		print("Failed to open file:", font_data_path)
		return
	var font_data_text = file.get_as_text()
	file.close()
	"""
	
	var json_object = JSON.new()
	var parse_err = json_object.parse(font_data_text)
	font_data = json_object.get_data()
	
	if typeof(font_data) != TYPE_DICTIONARY:
		print("Failed to parse JSON data from:", font_data_path)
		return
	
	var line_height = font_data["lineHeight"]
	var character_widths = font_data["characters"]
	var order = font_data["order"]
	
	var char_index = {}  # A dictionary mapping each character to its index.
	
	# Build the char_index dictionary.
	for i in range(order.size()):
		char_index[order[i]] = i
	
	# Now you have:
	# - line_height, an integer.
	# - character_widths, a dictionary mapping characters to widths.
	# - order, an array of characters in order.
	# - char_index, a dictionary mapping characters to their indices in order.
	
	# Now you have font_image and font_data available.
	# You can proceed to the next steps...
	
	
	var font_images = []  # Array to store the images of individual characters.
	var current_x = 0  # Initialize current x-coordinate to 0.
	var chars_not_in_font_file = ""
	# For each character in the order array...
	for char in order:
		if character_widths.has(char):
				
			# Find the width of the current character.
			var width = character_widths[char]
			print("char width: ", width)

			# Create a Rect2 to represent the portion of the image to extract.
			# The position is (current_x, 0), and the size is (width, image height).
			var rect = Rect2(Vector2(current_x, 0), Vector2(width, font_image.get_height()))

			# Get the portion of the image and add it to the font_images array.
			font_images.append(font_image.get_region(rect))

			# Move the current x-coordinate to the right by the width of the character.
			current_x += width
		else:
			chars_not_in_font_file = chars_not_in_font_file + char
		# Now font_images is an array of images, each image representing a character.\
		
	
	# Initialize text_images
	text_images = []

	# Loop through the texts
	for text in texts:
		# Create a new Image for each text
		var text_image = Image.new()

		# Calculate the total width of the text_image
		#var total_width = 0
		
		#for char in text:
		#	if character_widths.has(char):
		#		print("looping chars... ", char, " ", character_widths[char], " line height: ", line_height, " total width: ", total_width)
		#	else:
		#		chars_not_in_font_file = chars_not_in_font_file + char

		#	total_width += character_widths[char]
		#if chars_not_in_font_file != "":
		#	Logger.log_message("character(s) " + chars_not_in_font_file + "is/are not in the font file. These characters are ignored.")

		# Initialize the text_image
		text_image = Image.create(textbox_size, 500, false, Image.FORMAT_RGBA8) # TODO: FIXED HEIGHT HERE TO TEMPORARILY ALLOW MULTIPLE LINES. BETTER SOLUTION NEEDED, TO CHECK THE NUMBER OF LINES NEEDED BEFOREHAND.
		print("image dims1: ", text_image.get_size())
		# Add each character to the text_image
		var x_offset = 0
		var y_offset = 0
		#textbox_size
		for char in text:
			if char == "\n":
				x_offset = 0
				y_offset = y_offset + line_height
			elif character_widths.has(char):
				# Get the image of the character
				var char_image = font_images[char_index[char]]
				if x_offset + character_widths[char] > textbox_size:
					if x_offset <= character_widths[char]:
						if log_message == "":
							log_message += "Character(s) skipped because text box too narrow:"
						log_message =  log_message + char + " "
					x_offset = 0
					y_offset = y_offset + line_height
				
				# Blit the character image onto the text_image at the current x_offset
				text_image.blit_rect(char_image, Rect2(Vector2.ZERO, char_image.get_size()), Vector2(x_offset, y_offset))

				# Increase the x_offset by the width of the character
				x_offset += character_widths[char]
				if x_offset > textbox_size:
					x_offset = 0
					y_offset = y_offset + line_height
			else:
				chars_not_in_font_file = chars_not_in_font_file + char
		print("image dims2: ", text_image.get_size())
		# Append the text_image to text_images
		text_images.append(text_image)
		
		
	# Initialize texture_array
	texture_array = []

	# Convert each text_image to a Texture and add to the texture_array
	for text_image in text_images:
		print("image dims3: ", text_image.get_size())
		# Create a new ImageTexture
		var text_texture = ImageTexture.create_from_image(text_image)
		
		# Load the text_image into the ImageTexture
		#text_texture.create_from_image(text_image)
		
		# Append the text_texture to texture_array
		texture_array.append(text_texture)
		print("texture dims: eee ", text_texture.get_size())
	print("texture dims: ", texture_array[0].get_size())
	if log_message != null:
		Logger.log_message(log_message)

func render_frame(frame: int, position : Vector2, canvas, zoom) -> void: # overriden in BasicClip and ComplexClip
	print("tryin to render...")
	var clips_number_of_frames = frame_layer_table_hbox.get_child_count() - 1 # -1 because of the labels
	var actual_frame = frame % clips_number_of_frames
	# If frames are higher than the clip's frames, we get the remainder of that division.
	# So e.g. trying to access frame 11 of a clip with 10 frames will get us the 1st frame.
	print(clip_name)
	var texture_rect = TextureRect.new()
	if texture_array == null:
		print("texture_array = null...")
		return
	texture_rect.texture = texture_array[actual_frame-1]
	texture_rect.stretch_mode = 0#ignore size#rect_min_size = image_texture.get_size()
	#texture_rect.expand_mode = 1
	texture_rect.custom_minimum_size = texture_array[actual_frame-1].get_size() * zoom#dimensions * zoom
	texture_rect.set_position(position*zoom)
	#for child in canvas.get_children(): #not here.
	#	canvas.remove_child(child)
	texture_rect.texture_filter = 1
	canvas.add_child(texture_rect)


func arg_clip_is_child_of_self(parent_clip_to_check):
	return false
