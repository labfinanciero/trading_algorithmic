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
strategy_folder = parent_folder + "r\Strategies in Python\Simple_MA"
sys.path.append(strategy_folder)
# ----------------------------------------------------------------------------------- #

# Import needed packages

from Asset import Asset
import pandas as pd

# ------------------------------------- Main ---------------------------------------- #

# Test one asset ----------------------------------------------------------------------:
## instanciate an object
asset = Asset('AAP', 'Stock', 'Technology', 'US')
## Gets the data on the csv files --> we could use the yf API to get more updated data
data = asset.market_data()
# Calculate the Moving averages: Simple SMA(p) and Exponential EMA(p)
sma = asset.simple_moving_average(8)
ema = asset.exp_moving_average(21)

# Plot the price and the moving averages
df_test = pd.concat([asset.simple_moving_average(8),
                     asset.simple_moving_average(21).iloc[:,2],
                     asset.simple_moving_average(200).iloc[:,2]], axis = 1, ignore_index=False)
asset.plot_data(df_test)

# Get the results for each asset on both Buy and Sell
results_2MA = asset.strategy_MMA('EMA', [8, 21])
results_3MA = asset.strategy_MMA('EMA', [8, 21, 200])
#-----------------------------------------------------------------------------------------


# Test all assets ----------------------------------------------------------------------:
data_folder = parent_folder + r'\Strategies in Python\data\assets'
assets_names = [x.replace(".csv","")  for x in os.listdir(data_folder)] 
