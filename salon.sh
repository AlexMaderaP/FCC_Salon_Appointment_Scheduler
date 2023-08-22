#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon shop ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
  then echo -e "\n$1"
  fi

  echo -e "\nWelcome to My Salon, how can I help you?\n"
  SERVICES=$($PSQL "SELECT * FROM services")
  
  # display services
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done
  # read service selection
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  # if not found
  SERVICE_ID_SELECTEDFOUND=$($PSQL "SELECT service_id FROM services WHERE service_id =$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID_SELECTEDFOUND ]]
  then
    # display same list of services
    MAIN_MENU "Please select one of the services offered"
  else
    # get customer info customer phone
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # if customer doesn't exist
    if [[ -z $CUSTOMER_ID ]]
    then
      # get new customer name
      echo -e "\nI don't have a record for that phone, What's your name?"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
      # get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi

    # get service time
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
    read SERVICE_TIME

    # insert appoinment
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID_SELECTEDFOUND,'$SERVICE_TIME')")

    # output message
    echo -e "\nI have put you down for a cut at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

  fi

  
}

MAIN_MENU