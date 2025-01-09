class_name XDUT_CanceledCancel extends Cancel

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

func get_requested() -> bool:
	return true

func request() -> void:
	pass

#-------------------------------------------------------------------------------

func _to_string() -> String:
	return "(requested)<CanceledCancel#%d>" % get_instance_id()
