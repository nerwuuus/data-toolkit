# =====================================================================
# Blackjack Game - Current Status Summary
# ✅ Features implemented:
# - Initial dealing of cards for player and computer
# - Displaying player's hand and computer's first card
# - User can choose to hit or stand
# - Basic Ace handling: converts 11 to 1 if sum > 21
# - Computer draws cards automatically until reaching 17
# - Basic win/lose/draw logic implemented

# ❌ Issues / Not working perfectly:
# - Ace handling only adjusts **one Ace at a time**; multiple Aces may not be correctly recalculated
# - Computer's hand may not always display fully at the right moment
# - Win/lose messages may trigger before computer finishes drawing cards
# - Hit/stand loop can be confusing; user may see inconsistent print outputs
# - No separation between turns; computer draws while user is still making decisions
# - Some redundant or unused global variables

# 💡 Notes / Ideas for improvement:
# - Refactor Ace logic to handle multiple Aces in a loop
# - Separate computer's turn from user's turn for clarity
# - Ensure all print statements reflect the **current correct scores**
# - Consider returning updated scores from functions instead of relying on global
# - Improve overall game flow and readability
# =====================================================================
import random
import art

cards = [11, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10]
values = [("A",11), (2,2), (3,3), (4,4),(5,5), (6,6), (7,7), (8,8), (9,9), (10,10),("J",10), ("Q",10), ("K",10)]

start = input("Type 's' to start the game: ").lower()

user_won = False
user_blackjack = False
computer_won = False
computer_blackjack = False

def computer_choice():
    global computer_cards, computer_score
    computer_cards = [random.choice(values)[1], random.choice(values)[1]]
    computer_score = sum(computer_cards)
    print(f"Computer's first card: {computer_cards[0]}.")

def user_choice():
    global user_cards, user_score
    user_cards = [random.choice(values)[1], random.choice(values)[1]]
    user_score = sum(user_cards)
    print(f"Your cards: {user_cards}, current score: {user_score}.")

def ace():
    global user_score, computer_score
    # co jeśli jest więcej niż dwa asy??
    if user_score > 21 and 11 in user_cards:
        i = user_cards.index(11) # find index of the first ace occurrence
        user_cards[i] = 1 # replace 11 with 1
        user_score = sum(user_cards)

    if computer_score > 21 and 11 in computer_cards:
        x = computer_cards.index(11) # find index of the first ace occurrence
        computer_cards[x] = 1 # replace 11 with 1
        computer_score = sum(computer_cards)

def who_wins():
    global user_won, computer_won, computer_blackjack, user_blackjack
    if (11 in computer_cards and 10 in computer_cards) and (11 in user_cards and 10 in user_cards):
        computer_blackjack = False
        computer_won = False
        user_blackjack = False
        user_won = False
        print('Draw!')
    elif 11 in user_cards and 10 in user_cards:
        user_blackjack = True
        user_won = True
        print(f'Blackjack! You win!')
    elif 11 in computer_cards and 10 in computer_cards:
        computer_blackjack = True
        computer_won = True
        user_blackjack = False
        user_won = False
        print(f'Blackjack! Computer wins!')
    elif user_score > 21:
        print(f'Computer wins!')
    elif user_score == 21:
        print(f'Blackjack! You win!')
    elif user_score == computer_score:
        print(f'Draw!')
    elif user_score > computer_score:
        print(f'You win!')
    elif computer_score > user_score:
        print(f'Computer wins!')

if start == 's':
    print(art.logo)

    user_choice()
    computer_choice()
    ace()

    hit_or_stand = input("Type 'y' to get another card, type 'n' to pass: ").lower()
    another_choice = True
    if hit_or_stand == 'n':
        who_wins()
    else:
        while another_choice and user_score < 21:
            hit_or_stand = input("Type 'y' to get another card, type 'n' to pass: ").lower()
            if hit_or_stand == 'n':
                who_wins()
                break
            else:
                user_cards.append(random.choice(values)[1])
                user_score = sum(user_cards)
                ace()
                print(f"Your cards: {user_cards}, current score: {user_score}")
                print(f"Computer's first card: {computer_cards[0]}.")

                if user_score > 21:
                    another_choice = False
                    user_won = False
                    computer_won = True
                    print(f'Computer wins!')
                    break

                    if hit_or_stand == 'n':
                        who_wins()

                while computer_score < 17:
                    computer_cards.append(random.choice(values)[1])
                    computer_score = sum(computer_cards)
                    ace()
