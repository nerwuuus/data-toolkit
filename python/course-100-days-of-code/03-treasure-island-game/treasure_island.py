print("Welcome to Treasure Island.")
print("Your mission is to find the treasure.")

choice1 = input("You're at a crossroad. Where do you want to go? Type 'left' or 'right'.\n").lower()
if choice1 == "right":
    print("You fall into a pit of snakes. Game Over.")
else:
    choice2 = input("You've come to a lake. There is an island in the middle of the lake. "
                    "Type 'wait' to wait for a boat. Type 'swim' to swim across:\n").lower()
    if choice2 == "swim":
        print("You are attacked by hungry crocodiles. Game Over.")
    else:
        print("A boat arrives and takes you safely to the island.")
        choice3 = input("You arrive at the island unharmed. There is a house with 3 doors: one red, "
                        "one yellow, and one blue. Which colour do you choose?\n").lower()
        if choice3 == "red":
            print("It's a room full of fire. Game Over.")
        elif choice3 == "blue":
            print("You enter a room of beasts. Game Over.")
        elif choice3 == "yellow":
            print("You found the treasure! You Win!")
        else:
            print("You chose a door that doesn't exist. Game Over.")
