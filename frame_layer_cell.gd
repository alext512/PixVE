class_name FrameLayerCell

var image_file_path : String = ""  # The path to the image file
var image : ImageTexture = null  # The ImageTexture for this cell
var position : Vector2 = Vector2.ZERO  # The position of the image

func _init(file_path : String):
	image_file_path = file_path
	load_image()

# This function loads an image into the ImageTexture
func load_image():
	var texture = load(image_file_path) as ImageTexture
	image = texture
