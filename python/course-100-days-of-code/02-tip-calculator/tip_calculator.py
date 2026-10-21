print("Welcome to the tip calculator!")

bill = float(input("What was the total bill? $"))
tip = int(input("What percentage tip would you like to give? 10, 12 or 15?"))
people = int(input("How many people to split the bill?"))

bill_with_tip = bill + (bill * tip / 100)
bill_split_per_person = round(bill_with_tip / people, 2)
print(f"Everybody should pay ${bill_split_per_person}.")

# ======================================================
# simpler way to calculate the bill split
# ======================================================
tip_percentage = (tip / 100) + 1
bill_split = round((bill / people) * tip_percentage, 2)

print(f"Each person should pay {bill_split}.")
