"""
Main file for the execution of the strategy.

    1) Main function

    An instance of the class "Asset" is instantiated as: Asset(ticker, asset_class, sector, country) 

"""

# ---------------------------------- Path management -------------------------------- #
import os
import pathlib
import sys

parent_folder = str(pathlib.PurePath(os.getcwd()).parent)
strategy_folder = parent_folder + "\\Strategies in Python\\Simple_MA"
sys.path.append(strategy_folder)
# ----------------------------------------------------------------------------------- #

# Import needed packages

from Asset import *


# ------------------------------------- Main ---------------------------------------- #

amazon = Asset('AMZN', 'Stock', 'Technology', 'US')
data = amazon.market_data()
sma = amazon.simple_moving_average(20)
ema = amazon.exp_moving_average(8)
#amazon.plot_data(df_test, '2012-12-10')

strategy_result = amazon.strategy_MMA('SMA', [8, 21])[0]


