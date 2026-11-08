alphabet = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']

direction = input("Type 'encode' to encrypt, type 'decode' to decrypt:\n").lower()
text = input("Type your message:\n").lower()
shift = int(input("Type the shift number:\n"))

def caesar(text, shift, direction):
    if direction == 'encode':
        cipher_text = ""
        for letter in text:
            shifted_position = alphabet.index(letter) + shift
            shifted_position %= len(alphabet)
            cipher_text += alphabet[shifted_position]
        print(f"Here is the encoded result: {cipher_text}")
    else:
        decrypt_text = ""
        for letter in text:
            shifted_position_decrypt = alphabet.index(letter) - shift
            shifted_position_decrypt %= len(alphabet)
            decrypt_text += alphabet[shifted_position_decrypt]
        print(f"Here is the decoded result: {decrypt_text}")

caesar(text, shift, direction)

# proposed solution
# def caesar(original_text, shift_amount, encode_or_decode):
#     output_text = ''
#     for letter in original_text:
#         
#         if encode_or_decode == 'decode':
#             shift_amount *= -1
# 
#         shifted_position = alphabet.index(letter) + shift_amount
#         shifted_position %= len(alphabet)
#         output_text += alphabet[shifted_position]
#     print(f"Here is the decoded result: {decrypt_text}")
