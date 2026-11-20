from question_model import Question
from data import question_data

# TODO
# question_bank = [
#     Question(q1, a1),
#     Question(q2, a2),
#     Question(q3, a3)
# ...
# ]
# Write a for loop to iterate over the question_data.
# Create a Question object from each entry in question_data
# Append each Question object to the question_bank.

question_bank = []

for question_data_item in question_data:
     question_text = question_data_item['text'].question_bank.append(question_text)
     question_answer = question_data_item['answer'].question_bank.append(question_answer)
     question = Question(question_text, question_answer)
