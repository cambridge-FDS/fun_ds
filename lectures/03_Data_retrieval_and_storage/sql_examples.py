# 1. create kaggle account
# 2. get API keys and save to ~/.kaggle/kaggle.json
# 3. download the NBA database from: https://www.kaggle.com/datasets/wyattowalsh/basketball
# %%
import sqlite3 as sql

import duckdb as ddb
import kaggle
import pandas as pd

# %%
kaggle.api.authenticate()

kaggle.api.dataset_download_files("wyattowalsh/basketball", unzip=True)

# %%

# setup sqlite connection
con = sql.connect("nba.sqlite")

# let's check that it works
df_games = pd.read_sql("SELECT * FROM game LIMIT 10", con)

df_games.head()

# %%
# let's find the earliest and latest recorded game
query = """
    SELECT *
    FROM game
    ORDER BY game_date
    LIMIT 1
"""

pd.read_sql(query, con)

query = """
    SELECT *
    FROM game
    ORDER BY game_date DESC
    LIMIT 1
"""

pd.read_sql(query, con)


# %%
# let's check the teams which played the playoffs at some point
query = """
    SELECT DISTINCT team_name_home
    FROM game
    WHERE season_type='Playoffs'
"""

pd.read_sql(query, con)

# now let's count how many playoff games the teams played at home
query = """
    SELECT team_name_home,
        COUNT(game_id) as home_games
    FROM game
    WHERE season_type='Playoffs'
    GROUP BY team_name_home
    ORDER BY home_games DESC
"""

pd.read_sql(query, con)

# %%
# let's also account for away games
query = """
    SELECT team_name_home, (home_games + away_games) as games
    FROM
        (SELECT team_name_home,
        COUNT(game_id) as home_games
        FROM game
        WHERE season_type='Playoffs'
        GROUP BY team_name_home) AS home
    INNER JOIN
        (SELECT team_name_away,
        COUNT(game_id) as away_games
        FROM game
        WHERE season_type='Playoffs'
        GROUP BY team_name_away) AS away
    ON home.team_name_home=away.team_name_away
    ORDER BY games DESC
"""

pd.read_sql(query, con)

# %%
# we can also avoid the join by simply taking the union
query = """
    SELECT team_name, (home_games + away_games) AS games
    FROM (
        SELECT team_name_home AS team_name,
            COUNT(*) AS home_games,
            0 AS away_games
        FROM game
        WHERE season_type = 'Playoffs'
        GROUP BY team_name_home

        UNION ALL

        SELECT team_name_away AS team_name,
            0 AS home_games,
            COUNT(*) AS away_games
        FROM game
        WHERE season_type = 'Playoffs'
        GROUP BY team_name_away
    ) AS stats
    GROUP BY team_name
    ORDER BY games DESC
"""

pd.read_sql(query, con)

# %%
# some of the teams with many playoff games haven't won in a while, so let's check the last 5 years
query = """
    SELECT team_name_home, (home_games + away_games) as games
    FROM
        (SELECT team_name_home,
        COUNT(game_id) as home_games
        FROM game
        WHERE season_type='Playoffs'
        AND strftime('%Y', game_date) > '2019'
        GROUP BY team_name_home) AS home
    INNER JOIN
        (SELECT team_name_away,
        COUNT(game_id) as away_games
        FROM game
        WHERE season_type='Playoffs'
        AND strftime('%Y', game_date) > '2019'
        GROUP BY team_name_away) AS away
    ON home.team_name_home=away.team_name_away
    ORDER BY games DESC
"""

pd.read_sql(query, con)

# %%
#  what where the top 10 games with the most plays?
query = """
CREATE TEMPORARY TABLE plays_per_game AS
    SELECT game_id, COUNT(*) as number_of_plays
    FROM play_by_play
    GROUP BY game_id
"""

con.execute(query)

query = """
    SELECT *
    FROM game as g
    LEFT JOIN plays_per_game as ppg
    ON g.game_id = ppg.game_id
    WHERE season_type = 'Playoffs'
    ORDER BY ppg.number_of_plays DESC
    LIMIT 10
"""

pd.read_sql(query, con)


# %%
# duckdb to directly query e.g. csv, parquet. This might be particularly helpful if the data does not fit in memory.
query = """
    SELECT team_name_home, (home_games + away_games) as games
    FROM
        (SELECT team_name_home,
        COUNT(game_id) as home_games
        FROM 'csv/game.csv'
        WHERE season_type='Playoffs'
        AND strftime('%Y', game_date) > '2019'
        GROUP BY team_name_home) AS home
    INNER JOIN
        (SELECT team_name_away,
        COUNT(game_id) as away_games
        FROM 'csv/game.csv'
        WHERE season_type='Playoffs'
        AND strftime('%Y', game_date) > '2019'
        GROUP BY team_name_away) AS away
    ON home.team_name_home=away.team_name_away
    ORDER BY games DESC
"""

ddb.sql(query)

# we can also turn this into a dataframe
ddb.sql(query).to_df()

# %%
import duckdb as ddb

ddb.sql("INSTALL sqlite;")  # install the sqlite extension
ddb.sql("LOAD sqlite;")  # load the sqlite extension
# con = ddb.connect("nba.sqlite", config={'allow_unsigned_extensions': 'true'})

con = ddb.connect("nba.sqlite")
con.sql("SELECT * FROM game LIMIT 10").show()
# %%
