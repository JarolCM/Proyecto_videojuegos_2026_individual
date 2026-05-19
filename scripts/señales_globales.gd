extends Node

signal sonido_generado(posicion)
signal muertes_actualizado()
signal maullidos_actualizado()

var nivel: int
var muertes: int
var maullidos: int


func sumar_muerte():
	muertes += 1
	muertes_actualizado.emit()
	
func sumar_maullido():
	maullidos += 1
	maullidos_actualizado.emit()

func _input(event):
	if event.is_action_pressed("salir"):
		get_tree().quit()
