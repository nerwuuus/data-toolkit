from question_model import Question
from data import question_data


question_bank = []

for question in question_data:
     q_text = question['text']
     q_answer = question['answer']
     new_q = Question(q_text, q_answer)
     question_bank.append(new_q)


