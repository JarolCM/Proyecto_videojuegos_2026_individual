extends CharacterBody2D

signal max_muerto
signal mostrar_interaccion
signal mostrar_escondite
signal ocultar_interfaz

@export var animacion: AnimatedSprite2D
@export var area_enemigo: Area2D
@export var area_victoria: Area2D
@export var area_interaccion: Area2D
@export var reproductor: AudioStreamPlayer2D
@export var material_max_rojo: ShaderMaterial

@onready var hitbox = $Area_Enemigo/CollisionShape2D
@onready var indicadorInteraccion = $Indicador_Interaccion

# Constantes de movimiento
const _SPEED = 65.0
const _JUMP_VELOCITY = -230.0

# Condicionales
var _muerto: bool
var _victoria: bool

# Estados
var escondido := false
var escondite_actual = null
var mostrando_ui := false
var tipo_actual := ""

func _ready():
	add_to_group("max")
	area_enemigo.body_entered.connect(_on_area_enemigo_body_entered)
	area_victoria.body_entered.connect(_on_area_victoria_body_entered)
	indicadorInteraccion.visible = false


func _physics_process(delta: float) -> void:
	if _muerto:
		return
	
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Bloqueo de acciones
	var bloqueado := (
		(animacion.animation == "maullido" or animacion.animation == "tirar_objeto" or _victoria == true)
		and animacion.is_playing()
	)
	
	# Estado Escondido
	if escondido:
		if Input.is_action_just_pressed("esconderse"):
			salir_escondite()
		return
	
	# Para hacer aparecer el indicador
	var objeto_cerca = detectar_interactuable()
	var escondite_cerca = detectar_escondite()
	
	if objeto_cerca or escondite_cerca:
		indicadorInteraccion.visible = true
	else:
		indicadorInteraccion.visible = false
	
	# UI esquina pantalla
	if escondite_cerca:
		mostrar_escondite.emit()

	if objeto_cerca:
		mostrar_interaccion.emit()

	if !escondite_cerca and !objeto_cerca:
		ocultar_interfaz.emit()
	
	# Movimiento
	if not bloqueado:
		var direction := Input.get_axis("izquierda", "derecha")
		
		if Input.is_action_just_pressed("saltar") and is_on_floor():
			velocity.y = _JUMP_VELOCITY
		
		if direction < 0:
			velocity.x = direction * _SPEED
			animacion.flip_h = true
			indicadorInteraccion.position = Vector2(-4.5,-18.0)

		elif direction > 0:
			velocity.x = direction * _SPEED
			animacion.flip_h = false
			indicadorInteraccion.position = Vector2(4.5,-18.0)

		else:
			velocity.x = move_toward(velocity.x, 0, _SPEED)
	
	else:
		# Frenar mientras hace acciones
		velocity.x = 0
	move_and_slide()
	
	# No interrumpir animaciones especiales
	if bloqueado:
		return
	
	# Animaciones y acciones
	# Para que no se interrumpa las animaciones
	if (animacion.animation == "maullido" or animacion.animation == "tirar_objeto") and animacion.is_playing():
		return

	# Accion maullido
	if Input.is_action_just_pressed("maullido"):
		animacion.play("maullido")
		SeñalesGlobales.sonido_generado.emit(global_position)
		SeñalesGlobales.sumar_maullido()
		
		reproductor.play()
		# Sound Effect by Yomecerlm3 from Pixabay
		# Solo pongo creditos porque me parece genial incluirlo
		return
	
	# Accion Escondite
	if Input.is_action_just_pressed("esconderse"):
		# Salir del escondite
		if escondido:
			salir_escondite()
			return

		# Entrar al escondite
		var escondite = detectar_escondite()

		if escondite:
			entrar_escondite(escondite)
			return

	
	# Accion interaccion
	if Input.is_action_just_pressed("interactuar"):
		animacion.play("tirar_objeto")
		
		var objeto = detectar_interactuable()
		if objeto:
			# Empujar hacia donde Max esta mirando
			var direccion = -1.0 if animacion.flip_h else 1.0
			objeto.ser_empujado(direccion)
		return
	
	
	
	# Animaciones de movimiento
	if !is_on_floor():
		animacion.play("saltar")
	elif velocity.x != 0:
		animacion.play("correr")
	else:
		animacion.play("idle")
	

func detectar_escondite():
	var areas = area_interaccion.get_overlapping_areas()
	for area in areas:
		# Verificamos si el area o su padre están en el grupo
		if area.is_in_group("escondite"):
			return area 
		elif area.get_parent().is_in_group("escondite"):
			return area.get_parent()
	return null

func entrar_escondite(escondite):
	escondido = true
	escondite_actual = escondite
	
	# Desactivar colisiones físicas
	set_collision_layer_value(3, false)
	hitbox.disabled = true
	
	velocity = Vector2.ZERO
	visible = false 
	escondite.ocupar()

func salir_escondite():
	escondido = false
	
	# Volver a ser detectable
	set_collision_layer_value(3, true) 
	hitbox.disabled = false
	
	visible = true
	if escondite_actual:
		escondite_actual.desocupar()
	escondite_actual = null

func detectar_interactuable():
	var areas = area_interaccion.get_overlapping_areas()
	for area in areas:
		var padre = area.get_parent()
		if padre.is_in_group("interactuable"):
			return padre
	return null

# Funcion colision de daño (Game Over)
func _on_area_enemigo_body_entered(_body: Node2D) -> void:
	animacion.material = material_max_rojo
	_muerto = true
	animacion.stop()
	
	# Tiempo de espera antes de reiniciar nivel
	await get_tree().create_timer(0.5).timeout
	max_muerto.emit()
	
	SeñalesGlobales.sumar_muerte()

# Funcion al llegar meta (WIN)
func _on_area_victoria_body_entered(_body: Node2D) -> void:
	_victoria = true
	animacion.play("victoria")
	
	# Tiempo de espera antes de pasar al siguiente nivel
	await get_tree().create_timer(1.0).timeout
	get_parent().get_parent().siguiente_nivel()
