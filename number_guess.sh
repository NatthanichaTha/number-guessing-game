#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GAME() {
  echo "Enter your username:"
  read USERNAME
  # find if username exist
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'") 
  if [[ -z $USER_ID ]]; then
    USER_INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    USER_INFO=$($PSQL "SELECT games_played, best_game from users WHERE username='$USERNAME'")
    GAMES_PLAYED=$(echo $USER_INFO | cut -d "|" -f 1)
    BEST_GAME=$(echo $USER_INFO | cut -d "|" -f 2)
    echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
  fi

  # generate random number 1-1000
  NUMBER=$((1 + RANDOM % 1000))
  GUESSED=0
  WIN=false
  # ask user to guess a number
  echo "Guess the secret number between 1 and 1000:"

  while [[ $WIN == false ]]; do
    read NUMBER_TO_GUESS
    #while input not integer, ask again until get the integer as input
    while [[ ! $NUMBER_TO_GUESS =~ ^[0-9]+$ ]]; do
      echo "That is not an integer, guess again:"
      read NUMBER_TO_GUESS
    done
    #every time that user enter valid guessing, increment GUESSED  
    ((GUESSED += 1))
    # if number_to_guess > number:
    if [[ $NUMBER_TO_GUESS > $NUMBER ]]; then
      echo "It's lower than that, guess again:"
    # elif number_to_guess < number:
    elif [[ $NUMBER_TO_GUESS < $NUMBER ]]; then
      echo "It's higher than that, guess again:"
    #(if correct guess)
    else
      echo "You guessed it in $GUESSED tries. The secret number was $NUMBER. Nice job!"
      #update games_played (+=1)
      UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played=games_played+1 WHERE username='$USERNAME'")

      #if best_game is null
      if [[ -z $BEST_GAME ]]; then
        #set guessed to best_game
        UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game =$GUESSED WHERE username='$USERNAME'")

      elif [[ $GUESSED < $BEST_GAME ]]; then
      #update best_game
        UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game =$GUESSED WHERE username='$USERNAME'")
      fi
      WIN=true
      return
    fi
  done

}

GAME