alphabet = [
  'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
]

# collect user inputs
text = input("Type your message:\n").lower()
shift = int(input("Type the shift number:\n"))

# define a new function
def encode(plain_text, shift_amount):
    result = ''
  
    for letter in plain_text:
        shifted_index = ((alphabet.index(letter) + shift_amount) % 26) # 26 letters in the alphabet, keeps the range 0 - 25 and prevents from the out of range error
        shifted_letter = alphabet[shifted_index]
        result += shifted_letter
      
    print(f'Here is your encoded message: {result}')

# call a function (in this case it returns 'ifmmp')
encode(plain_text=text, shift_amount=shift) 
