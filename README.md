# Compound Noun Chain Game

This is a daily game where players find a chain of compound nouns from noun-A to noun-B. Each entered noun is validated to form a compound noun with the previous noun. If a prefix chain is invalid, progress cannot be made until the last noun in the chain is cleared and replaced with a valid compound. If noun-B is reached, the user’s solution is registered, something celebratory happens (confetti perhaps), and the user’s cumulative stats are shown.

## Dictionary API

The Dictionary API validates prefix chains of compound nouns:

GET /q?w[]=cow&w[]=bell&w[]=hop&...


It responds with JSON `{“result”:0}` or `{“result”:1}` indicating whether the given array of words is a valid chain of compound nouns.

## Backend API

The API endpoints are as follows:

### GET /game

Responds with the daily game. E.g.

{“from”:”dog”,”to”:”blade”,”steps”:6,”expires”:ts}


### GET /stats

Responds with the user’s stats. E.g.

{“played”:100,”won”:60,”current_streak”:6,”max_streak”:10,”dist”:[60,20,10,2,1,1,7]}


"dist" is a distribution of the user’s solutions: +0 (i.e. shortest valid solution), +1, +2, +3, +4, +5, +more than 5.

### PUT /soln

Allows the user to submit a solution to the daily game. Responds with a success Boolean and the updated user stats.

## Tables

### Games

Associations: `has_many solutions`

Fields: Game number, Date, Start word, End word, Shortest path

### Users

Associations: `has_many solutions`

Fields: UUID, Won, Current_streak, Max_streak, Plus_1, Plus_2, Plus_3, Plus_4, Plus_5, Plus_more

### Solutions

Associations: `belongs_to Game`, `belongs_to User`

Fields: User_id, Game_id, Timestamp, Chain (comma-separated list of words)

## Authentication 

Anonymous identity is provided through a UUID stored in a cookie. Best practices should be adopted for using this cookie to create a secure authenticated session with the user.

## Game Generation

Daily games will be pre-generated (e.g. a year in advance) with offline tools that Ben and Louis have written, manually created, and stored in a table on the backend server.