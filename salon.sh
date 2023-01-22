#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
	  echo -e "Welcome to My Salon, how can I help you?\n" 
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
	then
		MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_DETAILS=$($PSQL "SELECT service_id,name from services WHERE service_id = $SERVICE_ID_SELECTED")
    read SERVICE_ID BAR SERVICE_NAME <<< $(echo $SERVICE_DETAILS)
    if [[ -z $SERVICE_ID ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_DETAILS=$($PSQL "SELECT customer_id,name from customers where phone = '$CUSTOMER_PHONE'")
      read CUSTOMER_ID BAR CUSTOMER_NAME <<< $(echo $CUSTOMER_DETAILS)
      if [[ -z $CUSTOMER_ID ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where phone = '$CUSTOMER_PHONE'")
      fi
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
      if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
      then
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi
	fi

}

MAIN_MENU
