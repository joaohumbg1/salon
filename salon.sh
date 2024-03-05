#! /bin/bash

echo -e "\n~~~~~ SALON ~~~~~\n"

# Connect to database by calling $PSQL
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\nWelcome, what are you interested in today?"

SERVICES=$($PSQL "SELECT * FROM services")

PICK_SERVICE() {

# Print available services
SERVICES_MENU() {
  SERVICES_FORMATTED=$(echo "$SERVICES" | sed 's/ | / /g')

  echo "$SERVICES_FORMATTED" | while read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

  SERVICES_MENU

  while [[ -z $SERVICE_ID ]];
  do

    # Pick a service
    read SERVICE_ID_SELECTED

    # If it's not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      echo -e "\nThat service ID doesn't exist. Try again."
      SERVICES_MENU

    # If it's a number, check if it's in the services table
    else
      SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      # Get the service name as well
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
 
      # If the service doesn't exist
      if [[ -z $SERVICE_ID ]]
      then
        # Return to services menu
        echo -e "\nThat service ID doesn't exist. Try again."
        SERVICES_MENU 
      fi
    fi
  done
}

# Get customer information
CUSTOMER_INFO () {
  # Read phone number
  echo "What is your phone number?"
  read CUSTOMER_PHONE

  # Find name through phone number
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # If customer isn't registered:
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nIt appears you aren't registered in our database.\nPlease input your name:"
    # Ask customer to input name
    read CUSTOMER_NAME
    # Insert into customer into database
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    echo "Successfully created your account, $CUSTOMER_NAME."
  else
    echo "Welcome,$CUSTOMER_NAME!"
  fi
  # After ensuring that the customer is in the database, get their ID.
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
}

# Schedule appointment
SCHEDULE_APPOINTMENT () {
  echo -e "\nAt what time do you want to schedule the appointment?"
  # Read service time
  read SERVICE_TIME
  # Insert into database
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
  # Output success message
  echo "I have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
}

PICK_SERVICE
CUSTOMER_INFO
SCHEDULE_APPOINTMENT

