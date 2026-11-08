# add
def add(n1, n2):
    return n1 + n2

# subtract
def subtract(n1, n2):
    return n1 - n2

# multiply
def multiply(n1, n2):
    return n1 * n2

# divide
def divide(n1, n2):
    return n1 / n2

operations = {
    '+' : add,
    '-' : subtract,
    '*' : multiply,
    '/' : divide
}

# print(operations['*'](4, 8))
def calculator():
    should_accumulate = True
    num1 = float(input("What's the first number?: "))

    while should_accumulate:
        for symbol in operations:
            print(symbol)
        operation_symbol = input("Pick an operation: ")
        num2 = float(input("What's the next number?: "))
        answer = operations[operation_symbol](num1, num2)
        print(f'{num1} {operation_symbol} {num2} = {answer}')

        continue_calculation = input(f"Type 'y' to continue calculating with {answer}, or type 'n' to start a new calculation: ").lower()

        if continue_calculation == 'y':
            num1 = answer
        else:
            should_accumulate = False
            print('\n' * 100)
            calculator()

calculator()
