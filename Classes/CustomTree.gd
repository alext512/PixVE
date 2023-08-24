class_name CustomTree extends Tree

#var dragged_item = null
var dragged_item_cell = 0
var tree_type

var simple_dict
var editable_dict
var shortcut_dict

signal item_dragged(item)

func _ready():
	set_drop_mode_flags(Tree.DropModeFlags.DROP_MODE_ON_ITEM | Tree.DropModeFlags.DROP_MODE_INBETWEEN)
	var callable = Callable(self, "_on_item_dragged")
	connect("item_dragged", callable)
	pass
	
func _on_item_dragged(item):
	print("MOVED!!")
	pass
	
func a_is_child_of_b(a: TreeItem, b: TreeItem) -> bool:
	var a_parent = a.get_parent()
	while a_parent:
		if a_parent == b:
			return true
		a_parent = a_parent.get_parent()
	return false

func _get_drag_data(position):
	var item = get_item_at_position(position)
	if item:
		DragDrop.dragged_item = item
		#dragged_item = item
		emit_signal("item_dragged", item)
		return item
	return null

func _can_drop_data(position, data) -> bool:
	print("checkinggg")
	var target_item = get_item_at_position(position)
	if target_item and data is TreeItem and !a_is_child_of_b(target_item, DragDrop.dragged_item):
		if target_item == DragDrop.dragged_item:
			print("false1")
			return false
			
#		for i in range(target_item.get_child_count()):
#			var child_item = target_item.get_child(i)
#			if child_item.get_text(0) == DragDrop.dragged_item.get_text(0):
#				print("false2")
#				return false
				
		print("true")
		return true
		
	print("false3")
	return false
	

func _drop_data(position, data):
#var dragged_item = null
#var source_tree = null
	var source_tree = DragDrop.dragged_item.get_tree()
	if source_tree != self:
		var clip_to_move
		if (source_tree.tree_type == "simple" || source_tree.tree_type == "editable") && tree_type == "shortcut":
			
			if source_tree.tree_type == "simple":
				if simple_dict.has(DragDrop.dragged_item):
					clip_to_move = simple_dict[DragDrop.dragged_item]
				else:
					Logger.log_message("Folders cannot be copied")
					return #possibly trying to move a folder
			elif source_tree.tree_type == "editable":
				if editable_dict.has(DragDrop.dragged_item):
					clip_to_move = editable_dict[DragDrop.dragged_item]
				else:
					Logger.log_message("Folders cannot be copied")
					return #possibly trying to move a folder
			# ADD CODE HERE
			# Create a new TreeItem and add it to this tree
			var root = get_root() # we are in shortcut tree
			for i in range(root.get_child_count()):
				var child_item = root.get_child(i)
				if child_item.get_text(0) == DragDrop.dragged_item.get_text(0):
					if child_item.get_text(0) != DragDrop.dragged_item.get_text(0):
						Logger.log_message("A clip or folder with this name already exist. Cannot copy this clip.")
					return
					
			var new_item = self.create_item()
			new_item.set_text(0, DragDrop.dragged_item.get_text(0)) # Modify as needed
			new_item.set_text(1, DragDrop.dragged_item.get_text(1))
			var target_item = get_item_at_position(position)
			if target_item:
				var drop_section = get_drop_section_at_position(position)
				if shortcut_dict.has(target_item) && drop_section == 0:
					new_item.move_before(target_item) #just copy it wherever
				elif drop_section == 0: #this is a folder
					get_root().remove_child(new_item)
					target_item.add_child(new_item)
				elif drop_section == -1:
					new_item.move_before(target_item)
				elif drop_section == 1:
					new_item.move_after(target_item)
				#new_item.move_before(target_item) # Modify as needed
				new_item.set_custom_bg_color(1, clip_to_move.color_bg)
				new_item.set_custom_color(1, clip_to_move.color_text)
				shortcut_dict[new_item] = clip_to_move
			# TODO: copy over the features of the dragged TreeItem to the new TreeItem
		return # end the function here, as we don't want to run the rest of the code when moving to a different tree
	
	var target_item = get_item_at_position(position)
	
	for i in range(target_item.get_child_count()):
		var child_item = target_item.get_child(i)
		if child_item.get_text(0) == DragDrop.dragged_item.get_text(0):
			if child_item != DragDrop.dragged_item: # no need to show error if it's just the same item. It will mean that the item was left where it was.
				Logger.log_message("A clip or folder with this name already exist. Cannot move.")
			return
	
	if target_item and data is TreeItem and DragDrop.dragged_item:
		var parent = DragDrop.dragged_item.get_parent()

		var drop_section = get_drop_section_at_position(position)
		parent.remove_child(DragDrop.dragged_item)
		if drop_section == 0: # dropped on the item
			if (editable_dict.has(target_item) || shortcut_dict.has(target_item)):
				DragDrop.dragged_item.move_before(target_item)
			else: #target is a folder
				target_item.add_child(DragDrop.dragged_item)
		else: # dropped in-between items
			if drop_section == -1: # above the target item
				DragDrop.dragged_item.move_before(target_item)
			elif drop_section == 1: # below the target item
				DragDrop.dragged_item.move_after(target_item)
		print(DragDrop.dragged_item.get_text(0))
		print(parent.get_text(0))
		DragDrop.dragged_item = null



"""class_name CustomTree extends Tree

var dragged_item = null
var dragged_item_cell = 0
var tree_type

func _ready():
	set_drop_mode_flags(Tree.DropModeFlags.DROP_MODE_ON_ITEM  | Tree.DropModeFlags.DROP_MODE_INBETWEEN )
	pass
	#set_drag_forwarding(true)
	
	
func a_is_child_of_b(a: TreeItem, b: TreeItem) -> bool:
	# Recursive function to check if 'potential_child' is a child of 'parent'
	var a_parent = a.get_parent()
	while a_parent:
		if a_parent == b:
			return true
		a_parent = a_parent.get_parent()
	return false

func _get_drag_data(position):
	var item = get_item_at_position(position)
	if item:
		dragged_item = item
		return item
	return null

func _can_drop_data(position, data) -> bool:
	var target_item = get_item_at_position(position)
	if target_item and data is TreeItem and !a_is_child_of_b(target_item, dragged_item):
		if target_item == dragged_item:
			return false
		for i in range(target_item.get_child_count()):
			var child_item = target_item.get_child(i)
			if child_item.get_text(0) == dragged_item.get_text(0):
				return false
		return true
	return false

func _drop_data(position, data):
	var target_item = get_item_at_position(position)
	if target_item and data is TreeItem and dragged_item:
		
		var parent = dragged_item.get_parent()
		var index = parent.get_child_count() - 1
		parent.remove_child(dragged_item)
		target_item.add_child(dragged_item)
		print(dragged_item.get_text(0))
		print(parent.get_text(0))
		dragged_item = null
"""
