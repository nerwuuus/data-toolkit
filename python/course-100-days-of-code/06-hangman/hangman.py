import random

# use the 'word_list' from hangman_words.py
from hangman_words import word_list
lives = 6

# print logo at the start of the game.
from hangman_art import logo
# can be also from hangman_art import logo, stages
print(logo)

chosen_word = random.choice(word_list)
print(chosen_word)

placeholder = ""
word_length = len(chosen_word)
for position in range(word_length):
    placeholder += "_"
print("Word to guess: " + placeholder)

game_over = False
correct_letters = []

while not game_over:

    # the code below tells the user how many lives they have left
    print(f"****************************{lives} LIVES LEFT****************************")
    guess = input("Guess a letter: ").lower()

    # if the user has entered a letter they've already guessed, print the letter and let them know.
    display = ""

    for letter in chosen_word:
        if letter == guess:
            display += letter
            correct_letters.append(guess)
        elif letter in correct_letters:
            display += letter
        else:
            display += "_"

    print("Word to guess: " + display)

    if guess in correct_letters:
        print(f'You have already used {guess}!')

    # if the letter is not in the chosen_word, print out the letter and let them know it's not in the word.
    if guess not in chosen_word:
        lives -= 1
        print(f"You guessed {guess}, that's not in the word. You lose a life.")

        if lives == 0:
            game_over = True

            # give the user the correct word they were trying to guess
            print(f"***********************IT WAS {chosen_word}! YOU LOSE**********************")

    if "_" not in display:
        game_over = True
        print("****************************YOU WIN****************************")

    # use the stages List from the file hangman_art.py
    from hangman_art import stages
    print(stages[lives])
