# Create a new class.
class User:

    def __init__(self, user_id, username):
        self.id = user_id
        self.username = username
        self.followers = 0 
        self.following = 0

    def follow(self, user):
        user.followers += 1
        self.following += 1

# Create a new object for that class.
user_1 = User('001', 'admin')
user_2 = User('002', 'jack')

user_1.follow(user_2)
