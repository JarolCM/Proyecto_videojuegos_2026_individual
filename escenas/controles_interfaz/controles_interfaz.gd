extends Control

@onready var interact_label = $Interact
@onready var hide_label = $Hide

var max_actual = null

# Called when the node enters the scene tree for the first time.
func _ready():
	interact_label.visible = false
	hide_label.visible = false
	conectar_jugador()

func conectar_jugador():

	await get_tree().process_frame

	var max = get_tree().get_first_node_in_group("max")

	if max and max != max_actual:

		max_actual = max

		max.mostrar_interaccion.connect(_mostrar_interact)
		max.mostrar_escondite.connect(_mostrar_hide)
		max.ocultar_interfaz.connect(_ocultar_ui)

func _process(_delta):
	# Si el jugador fue destruido
	if !is_instance_valid(max_actual):
		max_actual = null
		conectar_jugador()


func _mostrar_interact():
	interact_label.visible = true
		
func _mostrar_hide():
		hide_label.visible = true

func _ocultar_ui():
	interact_label.visible = false
	hide_label.visible = false
