# Bulk Exercise Create Charge

This exercise aims to develop the fundamentals on how to create bulk charge using Omise api and uploading the csv file with the credentials like primary, secret keys, and other card information in order to create charge. 

This project utlizes active storage for storing csv files and follow the story as follows: 


- There is JUST 1 USER, so no need maintain distinction between user data for now. (don’t need to create users table)
- As the user of the application, we should be able to bulk create card charges based on the input CSV. 
- As a app user, I can download previous CSV uploaded.

- As the user of application, we should be able to see previous transaction attempts for each CSV row, and API response returned for each of them (both token and charge endpoints)

- Processing of the CSV should be using background job.

- We should be able to see status of each CSV file uploaded

- pending - CSV is yet to be picked up for processing

- in_process - CSV is currently processing

- finished - CSV successfully processed all rows. (all token and charge requests were successfull)

- finished_with_errors - CSV processed but some rows had API errors

- We should be able to configure the endpoint for making the request (vault and core) using ENV variable.

- Minimal usable UI should be enough.

- Write unit test for all models/controllers/background jobs/service classes.