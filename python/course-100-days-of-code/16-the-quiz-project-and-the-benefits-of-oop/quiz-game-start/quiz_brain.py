# TODO
# 1. Asking the questions
# 2. Checking if the answer was correct
# 3. Checking if we're at the end of the quiz
# =====================================================================
# question_number var will go through the list of questions which will be 
# passed over to QuizBrain object when it gets initalised. question_bank list will be passed to 
# question_list variable in quiz_brain file.

# next_question() method will pull up the question from that list, depending
# on which current question number we're on. It should be displayed like:
# Q.1: {text} {answer}: user input

class QuizBrain:

    def __init__(self, q_list):
        self.question_number = 0
        self.question_list = q_list


