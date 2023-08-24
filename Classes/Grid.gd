class_name Grid extends Control


var grid_size : Vector2 = Vector2(16, 16)  # The size of a grid cell in pixels
var grid_offset : Vector2 = Vector2(0, 0)   # The offset of the grid
var zoom_level = 2

var grid_color

func _ready():
	print("Grid _ready called")
	grid_color = Color(1, 1, 1, 0) # invisible- disabled
	_draw()

func _draw():
	var size = get_rect().size
	var color = grid_color  # Grid lines will be semi-transparent white
	print(color)
	# Apply zoom level to grid size and offset
	var zoomed_grid_size = grid_size * zoom_level
	var zoomed_grid_offset = grid_offset * zoom_level

	# Draw vertical grid lines
	for x in range(int(zoomed_grid_offset.x), int(size.x), int(zoomed_grid_size.x)):
		draw_line(Vector2(x, 0), Vector2(x, size.y), color)

	# Draw horizontal grid lines
	for y in range(int(zoomed_grid_offset.y), int(size.y), int(zoomed_grid_size.y)):
		draw_line(Vector2(0, y), Vector2(size.x, y), color)

func set_grid_size(new_grid_size : Vector2):
	grid_size = new_grid_size
	queue_redraw()  # Request a redraw

func set_grid_offset(new_grid_offset : Vector2):
	grid_offset = new_grid_offset
	queue_redraw()  # Request a redraw

func set_zoom_level(new_zoom_level : float):
	zoom_level = new_zoom_level
	queue_redraw()  # Request a redraw

func toggle_grid():
	if grid_color.a == 0: # is disabled
		print("enabled")
		grid_color = Color(1, 1, 1, 0.5)
		print(grid_color)
	else:
		grid_color = Color(1, 1, 1, 0)
	queue_redraw()
