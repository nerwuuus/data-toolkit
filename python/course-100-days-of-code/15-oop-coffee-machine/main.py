from menu import Menu
from coffee_maker import CoffeeMaker
from money_machine import MoneyMachine

coffee_machine_is_on = True
profit = 0

coffee_maker = CoffeeMaker()
money_machine = MoneyMachine()
menu = Menu()

while coffee_machine_is_on:

    choice = input('What would you like (Espresso/Latte/Cappuccino)? ').lower()

    if choice == 'off':
        coffee_machine_is_on = False
        print('Service maintenance. Machine turned off!')
    elif choice == 'report':
        coffee_maker.report()
        money_machine.report()
    else:
        drink = menu.find_drink(choice)
        if coffee_maker.is_resource_sufficient(drink) and money_machine.make_payment(drink.cost):
            coffee_maker.make_coffee(drink)
