import random

rock = '''
    _______
---'   ____)
      (_____)
      (_____)
      (____)
---.__(___)
'''

paper = '''
    _______
---'   ____)____
          ______)
          _______)
         _______)
---.__________)
'''

scissors = '''
    _______
---'   ____)____
          ______)
       __________)
      (____)
---.__(___)
'''

# list of choices
list_of_choices = [rock, paper, scissors]

# user choice
user_choice = int(input("What do you choose? Type 0 for Rock, 1 for Paper or 2 for Scissors.\n"))

# validate user input before it can be used as an index into list_of_choices
if user_choice >= 0 and user_choice <= 2: 
    # display an image if index is between 0 and 2
    print(f'You chose:')
    print(list_of_choices[user_choice])
    # computer choice
    computer_choice = random.randint(0, 2)
    print(f'Computer chose:')
    print(list_of_choices[computer_choice])
else:
    print('Type 0 for Rock, 1 for Paper or 2 for Scissors.')

if user_choice >= 3 or user_choice < 0:
    print("You typed an invalid number. You lose!")
elif user_choice == 0 and computer_choice == 2:
    print("You win!")
elif computer_choice == 0 and user_choice == 2:
    print("You win!")
elif computer_choice > user_choice:
    print("You lose!")
elif user_choice > computer_choice:
    print("You win!")
elif user_choice == computer_choice:
    print("Draw.")
