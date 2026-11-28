from turtle import Turtle, Screen
import random

turtle = Turtle()
screen = Screen()

def random_distance():
    move_distance = random.randrange(100)
    return move_distance

def random_angle():
    rotation_angle = random.randrange(180)
    return rotation_angle

def forwards():
    turtle.forward(random_distance())

def backwards():
    turtle.backward(random_distance())

def counter_clockwise():
    turtle.left(random_angle())
    
def clockwise():
    turtle.right(random_angle())

def clear():
    turtle.clear()
    turtle.penup()
    turtle.home()
    turtle.pendown()

screen.listen()
screen.onkey(forwards, 'w')
screen.onkey(backwards, 's')
screen.onkey(counter_clockwise, 'a')
screen.onkey(clockwise, 'd')
screen.onkey(clear, 'c')
screen.exitonclick()
