# ====================================================================================
# This script downloads all .csv files containing data for every Premier League match:
#   - during the 2021/2022 season
#   - or from 2015 to 2022 seasons
# ====================================================================================
import pandas as pd

# URL structure and parameters 
URL = 'https://www.football-data.co.uk/mmz4281/2122/E0.csv'
root = 'https://www.football-data.co.uk/mmz4281/'
leagues = ['E0', 'E1', 'E2', 'E3', 'EC'] # create a list of leagues: Premier League + lower divisions + Championship
frames = [] # initialise an empty list to collect intermediate results from the loop

# ------------------------------------------------------------------------------------
# one season
# # loop through leagues, read multiple .csv, append into a list
# for league in leagues:
#     df = pd.read_csv(root + '2122' + '/' + league + '.csv', encoding='unicode_escape')
#     frames.append(df)

# # check the length of frames list. Expected result: 5 (1 season x 5 leagues)
# # len(frames)
# ------------------------------------------------------------------------------------

# multiple seasons
# loop through leagues, seasons, read multiple .csv, append into a list
for league in leagues:
    for season in range(15, 21):
        df = pd.read_csv(root + (str(season) + str(season+1)) + '/' + league + '.csv', encoding='unicode_escape')
        df.insert(1, 'season', season)
        frames.append(df)

# check the length of frames list. Expected result: 30 (6 seasons x 5 leagues)
len(frames)
# show the firs element
frames[0]

