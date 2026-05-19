extends Node2D

@export var label: Label

var _texto : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_calificacion_final(SeñalesGlobales.muertes, SeñalesGlobales.maullidos)


func _calificacion_final(muertes, maullidos):
	if muertes == 0 and maullidos <= 3:
		_texto = "Gatito Ninja, experto en sigilo"
	
	elif muertes <= 2 and maullidos >= 10:
		_texto = "Gatito Rey de la Bulla y el Caos"
	
	elif muertes <= 4:
		_texto = "Gatito Experto en atunes"
	
	else:
		_texto = "Gatito noob, manquito, pero feliz :3"
	
	_actualizar_texto()

func _actualizar_texto():
	label.text = _texto
