
"""
func is_child_of(parent: TreeItem, potential_child: TreeItem) -> bool:
	# Recursive function to check if 'potential_child' is a child of 'parent'
	var current_parent = potential_child.get_parent()
	while current_parent:
		if current_parent == parent:
			return true
		current_parent = current_parent.get_parent()
	return false

# note: these are just empty placeholders and need to be filled with actual logic
func _on_tree_item_collapsed_or_expanded(tree_item: TreeItem):
	pass

func _on_tree_item_activated(tree_item: TreeItem):
	pass

func _on_tree_item_rmb_selected(pos: Vector2, item: TreeItem, column: int, id: int):
	# this function is triggered when an item is right-clicked
	dragged_item = item
	dragged_item_cell = column

func _on_tree_item_drop(tree_item: TreeItem, column: int):
	# this function is triggered when a dragged item is dropped on another item
	if tree_item and not is_child_of(dragged_item, tree_item):
		var parent = dragged_item.get_parent()
		if parent:
			parent.remove_child(dragged_item)
		tree_item.add_child(dragged_item)
	else:
		print("Cannot move item to its own subtree.")

func add_custom_tree_item(treeItem):
	self.add_child(treeItem)
	assign_signals(self)

func assign_signals(parent_tree):
	get_tree().connect("item_collapsed", self, "_on_tree_item_collapsed_or_expanded")
	get_tree().connect("item_expanded", self, "_on_tree_item_collapsed_or_expanded")
	get_tree().connect("item_activated", self, "_on_tree_item_activated")
"""
