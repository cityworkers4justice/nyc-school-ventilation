import csv
import json
import pandas
import requests

###################################################
# Open school locations CSV and extract unique primary building codes (PBC)
primaryBuildingCodes = pandas.read_csv('2019_-_2020_School_Locations.csv').Primary_building_code

# Initialize list to hold unique PBC's
codes = []

# Loop through PCB's and append code if not already in codes list
for index, value in primaryBuildingCodes.items():
  if value not in codes:
    codes.append(value)

# write all unique school building codes to file (for validation purposes, can remove this after number of schools confirmed)
#code_file = open('codes.txt', 'w')
#for code in codes:
#  code_file.write(code + '\n')

###################################################
# Data URL
URL = 'https://www.nycenet.edu/roomassessment/home/getdata?code='

# Loop through codes and:
  # Make a GET request for the data
  # Parse the JSON
  # Write JSON data to CSV file
for code in range(len(codes)):
  r = requests.get(URL + codes[code])
  room_data = json.loads(r.json())
  if len(room_data) > 0:

    output = open('data/' + codes[code] + '.csv', 'w')

    writer = csv.writer(output)

    count = 0

    for room in room_data:
      if count == 0:
        header = room.keys()
        writer.writerow(header)
        count += 1

      writer.writerow(room.values())

    output.close()
  else:
    print(codes[code] + ' is empty.')