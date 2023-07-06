# The challenge
* You have been provided with a JSON file of data of 1,000 users.
* The goal is to read in the data, massage it according to the requirements, and save the
massaged data to JSON files of no more than 100 entries each.


# Requirements
[x] The output must be in multiple files of max 100 entries

### Data must be massaged to the following rules:

[x] Empty arrays must be removed
[x] The _id field (note the underscore) must be removed, leaving just the id
[] Anything but alpha-numeric characters and hashtags must be removed from the
bio field
[] Provide clear usage instructions to allow us to easily verify the solution

### Optional Bonus Points:

[] write tests to demonstrate the workings of the data massaging
[x] Be able to support very large JSON files by streaming the file in/out
[] generate a report upon completion of the process, which can include data such as: process duration, average followers/followers, most followed users, average number of mentions etc

