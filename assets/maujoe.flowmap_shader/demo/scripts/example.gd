extends Control

onready var materials = get_node("/root/Node/ExampleMaterials")

func _ready():
	$ExampleSwitcher.add_item("Select Example Scene")
	$ExampleSwitcher.set_item_disabled(0, true)

	$ExampleSwitcher.add_item("Example 1: Water")
	$ExampleSwitcher.add_item("Example 2: Lava")

	for i in range(materials.get_child_count()):
		var example = materials.get_child(i)
		$ExampleOption.add_item("Material: " + example.get_name())

		if example.is_visible():
			$ExampleOption.select(i)


func _on_ExampleSwitcher_item_selected(ID):
	match (ID):
		(1):
			get_tree().change_scene("res://assets/maujoe.flowmap_shader/demo/water_example.tscn")
		(2):
			get_tree().change_scene("res://assets/maujoe.flowmap_shader/demo/lava_example.tscn")
		_:
			printerr("No Scene for this ID")


func _on_ExampleOption_item_selected(ID):
	for example in range(materials.get_child_count()):
		if ID == example:
			materials.get_child(example).show()
		else:
			materials.get_child(example).hide()
