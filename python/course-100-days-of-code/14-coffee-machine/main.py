# Import resources, cost and recipes
import coffee_data

user_input = True
order = []

# Main logic starts here
while user_input:
    # Request user input
    user_choice = input('What would you like (Espresso/Latte/Cappuccino)? Or type in "Report" to see coffee machine available resources. ').lower()
    if user_choice in ['espresso', 'latte', 'cappuccino']:
            order.append(user_choice)
    elif user_choice == 'report':
        print(coffee_data.resources)
    elif user_choice == 'off':
        print('Service maintenance. Machine turned off!')
        user_input = False
    else:
        print('Please type in Espresso or Latte or Cappuccino.')



