extends RayCast3D

@export var world_gen: GridMap

func _physics_process(_delta: float) -> void:
	if is_colliding():
		var target_block: Node3D = get_collider()
		target_block.visible = false
		if Input.is_action_just_pressed("primary_action"):
			world_gen.set_cell_item(get_collision_point(), 4)
