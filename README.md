# Bulk Exercise Create Charge

This exercise aims to develop the fundamentals on how to create bulk charge using Omise api and uploading the csv file with the credentials like primary, secret keys, and other card information in order to create charge. 

This project utlizes active storage for storing csv files 

T he story is as follows: 


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

Please set this in your root directory for the env file

```vim .env```

And put these values inside 

```OMISE_VAULT_URL=https://vault.staging-omise.co```

```OMISE_API_URL=https://api.staging-omise.co```

Now make sure that you have redis set up in yout computer 

```brew services start redis```

Also, make sure that you have the access to Omise staging dashboard and is connected to the internal VPN. 

To run the server please run 

```rails s```

In order to check the background processing job via sidekiq, please type

```bundle exec sidekiq```

This will display all the logs for the api calls and the rows being processed.

Thankyou!