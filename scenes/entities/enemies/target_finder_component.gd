class_name TargetFinderComponent extends Node

func find_first_target_in_group(group_name: String) -> Node:
	return get_tree().get_first_node_in_group(group_name)
