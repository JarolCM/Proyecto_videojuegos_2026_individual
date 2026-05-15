extends CharacterBody2D

@export var textura: Texture2D
@export var reproductor: AudioStreamPlayer2D

@onready var sprite = $Sprite2D

var _velocidad_caida_previa := 0.0
const UMBRAL_RUIDO = 150.0 # Qué tan rápido debe caer para hacer ruido

func _ready():
	add_to_group("interactuable")
	if textura:
		sprite.texture = textura

func _physics_process(delta: float) -> void:
	# Aplicar gravedad siempre
	if not is_on_floor():
		velocity += get_gravity() * delta
		_velocidad_caida_previa = velocity.y
	else:
		# Si estaba cayendo rápido y toca el suelo
		if _velocidad_caida_previa > UMBRAL_RUIDO:
			emitir_ruido_choque()
		
		velocity.y = 0
		_velocidad_caida_previa = 0
		# Rozamiento para que no se deslice infinitamente
		velocity.x = move_toward(velocity.x, 0, 10)

	move_and_slide()

# Fuerza al ser empujado
func ser_empujado(direccion_x: float):
	velocity.x = direccion_x * 100 

func emitir_ruido_choque():
	reproductor.play()
	SeñalesGlobales.sonido_generado.emit(global_position)
	# Sound Effect by freesound_community from Pixabay
