import os
# Check for legacy DB to not break anything
if (os.path.exists('./ytdl-server-database.db')):
    DATABASE_PATH = ('./ytdl-server-database.db')
else:
    DATABASE_PATH = os.path.join('db' + os.sep + 'ytdl-server-database.db')
# LEGACY DATABASE_PATH
#DATABASE_PATH = ('./ytdl-server-database.db')
