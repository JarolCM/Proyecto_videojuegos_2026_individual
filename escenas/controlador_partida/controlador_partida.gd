class_name ControladorPartida

extends Node

@export var partida: DatosPartida


var _ruta: String = "user://partida.tres"

func guardar_partida():
	partida.nivel = SeñalesGlobales.nivel
	partida.muertes = SeñalesGlobales.muertes
	partida.maullidos = SeñalesGlobales.maullidos
	
	ResourceSaver.save(partida, _ruta)

func cargar_partida():
	if ResourceLoader.exists(_ruta):
		partida = load(_ruta)
		
		SeñalesGlobales.nivel = partida.nivel
		SeñalesGlobales.muertes = partida.muertes
		SeñalesGlobales.maullidos = partida.maullidos
