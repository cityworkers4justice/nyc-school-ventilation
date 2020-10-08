import csv
import json
import os
import pandas
import requests

## This script was used to scrape NYC DOE ventilation data and compile it into a single CSV file for analysis.
## The script performs 3 primary functions:
##    Extract the NYC school building codes from existing data
##    Download the ventilation report data using the building codes
##    Compile the report data into a single file
## There are approximately 1201 unique reports to download so this may take a few minutes to complete
## School reports will be written to the schoolData directory
## The final compiled file will be written to the ouput directory

########################################################
# Extract the building codes from school location data #
########################################################

# Open school locations CSV and extract unique primary building codes (PBC)
primaryBuildingCodes = pandas.read_csv('locationData/2019_-_2020_School_Locations.csv').Primary_building_code

# Initialize list to hold unique PBC's
codes = []

# Loop through PCB's and append unique codes to list
for index, value in primaryBuildingCodes.items():
  if value not in codes:
    codes.append(value)

#################################################
# Use school codes to download ventilation data #
#################################################

# NYC school ventilation data URL
URL = 'https://www.nycenet.edu/roomassessment/home/getdata?code='

# For each code:
  # Append code to data URL and make a GET request
  # Parse the JSON response
  # Write it to CSV file
    # Each row in the CSV represents a room at the given school
for code in range(len(codes)):
  r = requests.get(URL + codes[code])
  room_data = json.loads(r.json())

  # check data exists
  if len(room_data) > 0:

    # create .csv file and a writer object
    output = open('schoolData/' + codes[code] + '.csv', 'w')
    writer = csv.writer(output)

    # used to write header of each file
    count = 0

    for room in room_data:
      # write headers
      if count == 0:
        header = room.keys()
        writer.writerow(header)
        count += 1

      # write data
      writer.writerow(room.values())

    output.close()

  # resonse was empty
  else:
    print(codes[code] + ' is empty.')

#####################################################################
# Compile the room data from each school CSV into a single document #
#####################################################################

"""Gets a Series and value and returns the count of a the selected value from the series

Args:
  series (Series): The series of unique values extracted from the school building data
  value (String): The requested value from the series

Returns:
  (String): The count of the requested value as a string, or '0' if data value is empty
"""
def countQuality(series, value):
  x = series.get(value)
  if x:
    return str(x)
  else:
    return '0'

# Create a csv file and writer object for the compilied data
output = open('output/NYC_Schools_Ventilation_Data.csv', 'w')
writer = csv.writer(output)

# Create headers & write to file
headers = ['Primary_building_code', 'rooms_total', 'windows', 'windows_open', 'supplyFan_operational', 'supplyFan_partOperational', 'supplyFan_nonOperational', 'exhaustFan_operational', 'exhaustFan_partOperational', 'exhaustFan_nonOperational', 'unitVentilator_operational', 'unitVentilator_partOperational', 'unitVentilator_nonOperational']
writer.writerow(headers)

# Columns to generate Series objects from, & values to be extracted from those Series
columns = ['PrimaryUsage', 'Windows', 'Atleast', 'SupplyFan', 'ExhaustFan', 'UnitVentilators']
values = [['Student-Staff Space'], ['Yes'], ['yes'], ['Operational', 'Partially Operational', 'Not Operational'], ['Operational', 'Partially Operational', 'Not Operational'], ['Operational', 'Partially Operational', 'Not Operational']]

# For every school data file:
#   Read the school data file
#   Create a series object for each column in columns
#   Send the series to the countQualty helper along with the value to extract from the column
#   Push all values into row, and write the contents to a new row in the compilied data file
for file in os.listdir('schoolData/'):
  try:
    df = pandas.read_csv('schoolData/' + file)
    row = []
    series = []
    row.append(df.values[0][1]) #Write the primary building code as first column

    for column in columns:
      series.append(df[column].value_counts(dropna=False))

    for i, c in enumerate(columns):
      for value in values[i]:
        row.append(countQuality(series[i], value))

    writer.writerow(row)

  except pandas.errors.EmptyDataError:
    print(file + ' is causing problems.')
    continue

output.close()