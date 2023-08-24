class_name Canvas extends Panel

var grid

func _ready():
	clip_contents = true
	grid = Grid.new()
	add_child(grid)
	grid.z_index = 1
	
func toggle_grid():
	grid.toggle_grid()

func get_zoom_level():
	return grid.zoom_level

func set_zoom_level(level):
	grid.set_zoom_level(level)

func remove_children():
	for child in get_children(): #removing the already rendered stuff.
		remove_child(child)
	add_child(grid)
	

