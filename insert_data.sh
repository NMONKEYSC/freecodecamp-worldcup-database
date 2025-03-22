#!/bin/bash

if [[ $1 == "test" ]]
then
  psql="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  psql="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi
# Do not change code above this line. Use the PSQL variable above to query your database.

# clear existing data (reset tables)
$psql "
  truncate    games, teams 
  restart     identity cascade
"

# read csv and insert data into worldcup database
cat games.csv | while IFS="," read year round winner opponent winner_goals opponent_goals
do 
  if [[ $year != "year" ]]
  then 
    # check if winner team exists, if not insert it
    winner_id=$($psql "
                select    team_id 
                from      teams 
                where     name='$winner'
    ")

    if [[ -z $winner_id ]]
    then
      $psql "
        insert into teams(name) 
        values('$winner')
      "
      winner_id=$($psql "
                  select    team_id 
                  from      teams 
                  where     name='$winner'
      ")
    fi

    # check if opponent team exists, if not insert it
    opponent_id=$($psql "
                  select    team_id 
                  from      teams 
                  where     name='$opponent'
    ")

    if [[ -z $opponent_id ]]
    then
      $psql "
        insert into teams(name) 
        values('$opponent')
      "
      opponent_id=$($psql "
                    select    team_id 
                    from      teams 
                    where     name='$opponent'
      ")
    fi

    # insert game data into the games table
    $psql "
      insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
      values($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals)
    "
  fi
done

echo "✅ data has been successfully inserted into the worldcup database!"
