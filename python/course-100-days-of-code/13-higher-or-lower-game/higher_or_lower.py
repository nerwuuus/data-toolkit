# ============================================================
# HIGHER/LOWER GAME LOGIC EXPLANATION
# ============================================================
# 1. The game uses a dataset "data", which is a list of dictionaries.
#    Each dictionary represents a person with keys:
#      'name', 'follower_count', 'description', 'country'.
#
# 2. Functions choose_a() and choose_b() pick a random person from the data
#    and print their info (name, description, country).
#    NOTE: follower counts inside these functions are currently local,
#          so comparisons outside the functions will not work correctly.
#
# 3. The main game loop logic should be:
#    - Show A and B to the user
#    - Ask who has more followers
#    - Check if the user's guess is correct
#    - If correct:
#        - increment score
#        - shift B to A
#        - pick a new B
#    - Repeat until the user guesses incorrectly
#
# 4. CURRENT ISSUES/BUGS:
#    - Every call to choose_a() or choose_b() picks a new random person,
#      so names may not match the follower counts being compared.
#    - The same person can appear as both A and B, which should not happen.
#    - Updating A and B after a correct guess is not implemented yet.
#    - Only the first round works properly; no continuous loop for multiple rounds.
#    - If the first guess is wrong, the game ends immediately.
#
# 5. SUGGESTED FIXES:
#    - Store selected A and B globally or return them from functions.
#    - Only pick a new B after a correct guess, and shift old B to A.
#    - Ensure A and B are never the same person.
#    - Implement a proper while loop until game_over = True.
#    - Keep follower counts consistent with the displayed names.
#    - Optionally, improve input validation for user guesses.
# ============================================================
import random
from game_data import data
from art import logo
from art import vs

print(logo)
print("\n")

user_score = 0
game_over = False

# picks a random full dictionary from data (game_data) file. It contains all the info
a_item = random.choice(data)
b_item = random.choice(data)

# picks up a follower count number
a_follower_count = a_item['follower_count']
b_follower_count = b_item['follower_count']
print(a_follower_count) # TEST
print(b_follower_count) # TEST

def choose_a():
    # extract each property from randomly selected dictionary
    a_name = a_item['name']
    a_description = a_item['description']
    a_country = a_item['country']
    print(f"Compare A: {a_name}, {a_description}, {a_country}.")

def choose_b():
    b_name = b_item['name']
    b_description = b_item['description']
    b_country = b_item['country']
    print(f"Against B: {b_name}, {b_description}, {b_country}.")

def render_choices():
    choose_a()
    print(vs)
    choose_b()

render_choices()
user_choice = input("Who has more followers? Type 'A' or 'B': ").lower()

if user_choice == 'a' and (a_follower_count > b_follower_count):
    user_score += 1
    print(f"You're right! Current score: {user_score}")
    b_item = random.choice(data)
    choose_b()
    print(vs)
    choose_b()
    user_choice = input("Who has more followers? Type 'A' or 'B': ").lower()
elif user_choice == 'b' and (b_follower_count > a_follower_count):
    user_score += 1
    print(f"You're right! Current score: {user_score}")
    a_item = random.choice(data)
    choose_a()
    print(vs)
    choose_b()
    user_choice = input("Who has more followers? Type 'A' or 'B': ").lower()
# elif:
#     game_over = True
#     print(f"You lost!")
else:
    while not game_over:
        


