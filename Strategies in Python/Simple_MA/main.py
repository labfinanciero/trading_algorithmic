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

apple = Asset('AAPL', 'Stock', 'Technology', 'US')
data = apple.market_data()
sma = apple.simple_moving_average(20)
