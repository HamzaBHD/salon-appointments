#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

# GET SERVICES
SERVICE_MENU() {
if [[ $1 ]]
then 
echo -e "\n$1"
fi
GET_SERVICES=$($PSQL "SELECT * FROM services")
if [[ -z $GET_SERVICES ]]
then
echo NO
else
echo "$GET_SERVICES" | while read SERVICE_ID BAR NAME
do
echo "$SERVICE_ID) $NAME"
done 
fi
}

# USER INPUT
USER_INPUT() {
read SERVICE_ID_SELECTED
# IF INPUT IS NOT A NUMBER
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
# SEND TO SERVICE MENU
SERVICE_MENU "I could not find that service. What would you like today?"
else
# GET SERVICE CHOOSEN
SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE name IS NOT NULL AND service_id=$SERVICE_ID_SELECTED")
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE name IS NOT NULL AND service_id=$SERVICE_ID_SELECTED")
echo "$SERVICE_NAME"
# IF NOT FOUND
if [[ -z $SERVICE_ID ]]
then
SERVICE_MENU "I could not find that service. What would you like today?"
else
# IF SERVICE FOUND
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
# CHECK FOR USER
USER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
if [[ -z $USER_ID ]]
then
echo -e "\nI don't have a record for that phone number, what's your name?"
read CUSTOMER_NAME
echo "$CUSTOMER_NAME"

echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g'), $CUSTOMER_NAME?"
read SERVICE_TIME
# INSERT NEW CUSTOMER AND NEW APPOINTMENT
INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $CUSTOMER_NAME."
else
# IF USER FOUND
USER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
echo "$USER_NAME"
echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g'), $(echo $USER_NAME | sed -E 's/^ *| *$//g')?"
read SERVICE_TIME
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($USER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $USER_NAME | sed -E 's/^ *| *$//g')."
fi
fi
fi
}

SERVICE_MENU "Welcome to My Salon, how can I help you?\n"
USER_INPUT