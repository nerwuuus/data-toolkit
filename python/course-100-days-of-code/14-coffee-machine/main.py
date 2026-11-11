# Import resources, cost and recipes
import coffee_data

user_input = True
order = []


while user_input:
    # Request user input
    user_choice = input('What would you like (Espresso/Latte/Cappuccino)? Type in "Report" to see coffee machine available resources. ').lower()
    if user_choice in coffee_data.recipes:
            order.append(user_choice)
            selected_coffee = coffee_data.recipes[user_choice]
    elif user_choice == 'report':
        print(coffee_data.resources)
    elif user_choice == 'off':
        print('Service maintenance. Machine turned off!')
        user_input = False
    else:
        print('Please type in Espresso or Latte or Cappuccino.')



for ingredient, value in selected_coffee.items():
     resources = ingredient, value
     print(resources)

    



