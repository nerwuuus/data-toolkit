import random
import art

cards = [11, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10]
values = [("A",11), (2,2), (3,3), (4,4),(5,5), (6,6), (7,7), (8,8), (9,9), (10,10),("J",10), ("Q",10), ("K",10)]

ask_user = input("Do you want to play a game of Blackjack? Type 'y' or 'n': ").lower()

if ask_user == 'y':
    print(art.logo)
    user_cards = [random.choice(values)[1], random.choice(values)[1]]
    user_score = []
    user_score.append(sum(user_cards))
    print(f"Your cards: {user_cards}, current score: {user_score}.")

    computer_cards = random.choice(values)[1]
    computer_score = []
    computer_score.append(computer_cards)
    print(f"Computer's first card: {computer_cards}.")

    ask_user2 = input("Type 'y' to get another card, type 'n' to pass: ").lower()
    if ask_user2 == 'y':
        if sum(user_cards) < 21:
            user_cards.append(random.choice(values)[1])
            sum(user_cards)
            print(f"Your cards: {user_cards}, current score: {user_score}.")
            
