extends CharacterBody2D

@export var animacion: AnimatedSprite2D
@export var area_2d: Area2D


const SPEED = 120.0

# Variable para almacenar al jugador cuando entra en el rango
# (Se renombra ligeramente a "jugador_max" para evitar confusiones de nombres)
var jugador_max: CharacterBody2D = null

func _physics_process(delta: float) -> void:
	# Aplica gravedad si es un enemigo terrestre (elimina o comenta esto si es volador)
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if jugador_max:
		# 1. Calcular la dirección hacia el jugador
		var direction = (jugador_max.global_position - global_position).normalized()
		
		# 2. Aplicar la velocidad y mover al enemigo
		# Usamos direction.x para que el enemigo se mueva horizontalmente hacia Max 
		# y no flote en el aire si está más alto o más bajo.
		velocity.x = direction.x * SPEED
		
	else:
		# Si no hay jugador cerca, detener al enemigo
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()

	#animacion
	animacion.play("idle")


# Señal que se activa cuando algo entra en el área de visión
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("max"):
		jugador_max = body
		print("¡Max detectado!")

# Señal que se activa cuando el jugador sale del área de visión
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("max"):
		jugador_max = null
		print("Max salió del rango")
