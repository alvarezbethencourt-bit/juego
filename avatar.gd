extends Node2D
class_name HallwaysAvatar

var skin := Color("#c98e69")
var hair := Color("#49352e")
var shirt := Color("#303b55")
var hair_style := "Corto"

func _draw() -> void:
    # Personaje provisional original construido con formas vectoriales.
    draw_rect(Rect2(-23, -4, 46, 58), shirt)
    draw_circle(Vector2(0, -29), 23, skin)
    draw_circle(Vector2(-21, -28), 5, skin)
    draw_circle(Vector2(21, -28), 5, skin)
    match hair_style:
        "Rizado":
            for i in range(-2, 3):
                draw_circle(Vector2(i * 9, -48 - (abs(i) % 2) * 3), 8, hair)
        "Largo":
            draw_rect(Rect2(-23, -47, 8, 49), hair)
            draw_rect(Rect2(15, -47, 8, 49), hair)
            draw_arc(Vector2(0, -31), 23, PI, TAU, 24, hair, 9)
        _:
            draw_arc(Vector2(0, -31), 23, PI, TAU, 24, hair, 10)
    draw_circle(Vector2(-8, -29), 2.5, Color("#25252b"))
    draw_circle(Vector2(8, -29), 2.5, Color("#25252b"))
    draw_line(Vector2(-6, -17), Vector2(6, -17), Color("#603c36"), 2)
    draw_rect(Rect2(-15, 54, 12, 31), Color("#252a35"))
    draw_rect(Rect2(3, 54, 12, 31), Color("#252a35"))
    draw_rect(Rect2(-18, 82, 18, 8), Color("#171a22"))
    draw_rect(Rect2(1, 82, 18, 8), Color("#171a22"))
