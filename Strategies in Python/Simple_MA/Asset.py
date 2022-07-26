# ----- import the libraries to be used -----
import pandas as pd
import numpy as np
#import matplotlib as mplib
#import scipy as scipy
from datetime import datetime as dt

# ----- import the paths to be used -----

import os
import pathlib
import sys

parent_folder = str(pathlib.PurePath(os.getcwd()).parent)
data_folder = parent_folder + "\\Strategies in Python\\data\\assets"


class Asset:  
    """
    class "Asset".

    Define the class "Asset" used to store the attributes of the asset an the data.
        
    -----------
    
    Attributes
    ----------
        .mkt_data() imports the market data from the folder and returns it as a pd.DataFrame
        
        
        
    """
    
    def __init__(self, ticker, asset_class, sector, country):
        """Build the constructor to store the information of the asset."""
        self.ticker = ticker
        self.asset_class = asset_class
        self.sector = sector
        self.country = country
    
    
    def market_data(self):
        """Import and store the market data."""
        file_folder = data_folder + '\\' + self.ticker + ".csv"
        col_names = ['dates', 'open', 'high', 'low', "close", 'volume', 'adj_close']
        self.data = pd.read_csv(file_folder, sep=',', skiprows=[0] , names=col_names)
        return self.data
    
    
    def simple_moving_average(self, periods):
        """Calculate and returns the simple moving average time series.""" 
        self.periods = periods
        self.simple_ma_df = self.data.loc[:, ['dates', 'close']]
        close_prices = self.simple_ma_df.loc[:, 'close'].values
        p = self.periods
        n = len(close_prices)
        simple_ma_prices = np.zeros(n)
        for i in range(p-1, n):
            simple_ma_prices[i] = np.mean(close_prices[(i-p+1):i+1])
        col_name = 'SMA(' + str(p) + ')'
        self.simple_ma_df[col_name] = simple_ma_prices
        return self.simple_ma_df.reset_index(drop=False)


    
    def plot_data(self):
        """Plot the closing prices as well as the Moving Average."""
        pass

