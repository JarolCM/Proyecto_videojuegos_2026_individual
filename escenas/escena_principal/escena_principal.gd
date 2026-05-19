extends Node2D

@export var niveles: Array[PackedScene]
@export var controlador_partida: ControladorPartida
@export var sound_track: AudioStreamPlayer

var _nivel_actual: int = 1
var _nivel_instanciado: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SeñalesGlobales.nivel > 1:
		_cargar_nivel()
	else:
		_crear_nivel(_nivel_actual)


func _crear_nivel(numero_nivel: int):
	_nivel_instanciado = niveles[numero_nivel - 1].instantiate()
	add_child(_nivel_instanciado)
	
	var hijos := _nivel_instanciado.get_children()
	for hijo in hijos:
		if hijo.is_in_group("max"):
			hijo.max_muerto.connect(_reiniciar_nivel)
			break
	
	SeñalesGlobales.nivel = numero_nivel
	controlador_partida.guardar_partida()


func _elimiminar_nivel():
	_nivel_instanciado.queue_free()

func _reiniciar_nivel():
	_elimiminar_nivel()
	_crear_nivel.call_deferred(_nivel_actual)
	
func siguiente_nivel():
	_nivel_actual += 1
	_elimiminar_nivel()
	_crear_nivel.call_deferred(_nivel_actual)

func _cargar_nivel():
	_nivel_actual = SeñalesGlobales.nivel
	_crear_nivel.call_deferred(_nivel_actual)

# Queria usar esta linea para agradecer a AlvaMajo quien me ayudo mucho con su tuto
