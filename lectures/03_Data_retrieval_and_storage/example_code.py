# 1. create kaggle account
# 2. get API keys and save to ~/.kaggle/kaggle.json
# 3. download the NBA database from: https://www.kaggle.com/datasets/wyattowalsh/basketball
# %%
import sqlite3 as sql

import kaggle
import pandas as pd

kaggle.api.authenticate()

kaggle.api.dataset_download_files("wyattowalsh/basketball", unzip=True)

# %%

# setup sqlite connection
con = sql.connect("nba.sqlite")

df_games = pd.read_sql("select * from game limit 10", con)

df_games.head()

# %%
