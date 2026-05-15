extends Node2D

# Cargamos las texturas desde el inspector
@export var textura_vacio: Texture2D
@export var textura_con_max: Texture2D

@onready var sprite = $Sprite2D

func _ready():
	add_to_group("escondite")
	sprite.texture = textura_vacio

func ocupar():
	sprite.texture = textura_con_max

func desocupar():
	sprite.texture = textura_vacio
