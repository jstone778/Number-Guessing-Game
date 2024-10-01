#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))
COUNTER=1
GUESSES=()

echo Enter your username:
read USERNAME

if [[ ${#USERNAME} -gt 22 ]]
then
  echo "Your username can't be longer than 22 characters."
else
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  if [[ -z $USER_ID ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  GUESSES+=($GUESS)
  echo $RANDOM_NUMBER

  while [[ $RANDOM_NUMBER != $GUESS ]]
  do
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      read GUESS
      GUESSES+=($GUESS)
      ((COUNTER=COUNTER+1))
    elif [[ $GUESS -lt $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      read GUESS
      GUESSES+=($GUESS)
      ((COUNTER=COUNTER+1))
    elif [[ $GUESS -gt $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      read GUESS
      GUESSES+=($GUESS)
      ((COUNTER=COUNTER+1))
    fi
  done
  
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
  GAMES_PLAYED=$(($GAMES_PLAYED + 1))
  INSERT_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE user_id=$USER_ID")
  
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
  if [[ -z $BEST_GAME ]]
  then
    INSERT_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game=$COUNTER WHERE user_id=$USER_ID")
  elif [[ $BEST_GAME > $COUNTER ]]
  then
    INSERT_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game=$COUNTER WHERE user_id=$USER_ID")
  fi
  echo "You guessed it in $COUNTER tries. The secret number was $RANDOM_NUMBER. Nice job!"
fi