# meta-name: Effect
# meta-description: An effect which can be applied to a target, like damage or block
class_name MyEffectName
extends Effect

var amount := 0 

func execute(targets: Array[Node]) -> void:
	print("My effect targets: %s" % targets)
	print("It does %s something" % amount)
