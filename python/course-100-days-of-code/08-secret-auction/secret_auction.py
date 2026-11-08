from art import logo
print(logo)

bidders = {}
continue_bidding = True

while continue_bidding:
    name = input('What is your name? ').strip()
    bid = float(input('What is your bid? '))
    bidders[name] = bid
    print('\n' * 100)
    add_bidders = input('Are there any other bidders? Type "yes" or "no".').lower()

    if add_bidders:
        continue
    else:
        max_value = max(bidders.values())
        max_value_name = max(bidders, key=bidders.get)
        print(f"The winner is {max_value_name} with a bid of {max_value}.")
        continue_bidding = False

# ============================================================================
# instructors' solution
# ============================================================================
# def find_the_highest_bidder(bids):
#     winner = ''
#     highest_bid = 0
#     for bid in bids:
#         bid_amount = bids[bid]
#         if bid_amount > highest_bid:
#             highest_bid = bid_amount
#             winner = bid
#
#     print(f"The winner is {bid}")
