#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")

GAMECOUNTER=1

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do 
  if [[ $WINNER != "winner" ]]
  then
    # get winning team
    TEAM_ID=$($PSQL "Select team_id FROM teams WHERE name='$WINNER'")
    
    # if team not found
    if [[ -z $TEAM_ID ]]
    then
      # insert team
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
    
    # get new team_id
    TEAM_ID=$($PSQL "Select team_id FROM teams WHERE name='$WINNER'")
    fi
  fi
  
  if [[ $OPPONENT != "opponent" ]]
  then
    # get opponent team
    OPPONENT_ID=$($PSQL "Select team_id FROM teams WHERE name='$OPPONENT'")
    
    # if opponent team not found
    if [[ -z $OPPONENT_ID ]]
    then
      # insert opponent team
      INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi
    
    # get new team_id
    OPPONENT_ID=$($PSQL "Select team_id FROM teams WHERE name='$OPPONENT'")
    fi

  fi

  if [[ $YEAR != "year" ]]
  then
    
    INSERT_GAME_DATA=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR, '$ROUND', $TEAM_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    echo Inserted into games, Game $GAMECOUNTER
    GAMECOUNTER=$(( $GAMECOUNTER + 1 )) 
  fi

done

