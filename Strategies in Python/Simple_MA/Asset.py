# ----- import the libraries to be used -----
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
#import scipy as scipy
from datetime import datetime as dt
import inspect
#import yfinance as yf


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
    
    # Define the main attributes or descriptions of the asset.
    def __init__(self, ticker, asset_class, sector, country):
        """Build the constructor to store the information of the asset."""
        self.ticker = ticker
        self.asset_class = asset_class
        self.sector = sector
        self.country = country
    
    # Import the market data from the folder. However, it would be interesting
    # to use the yahoo finance API to get more recent data.
    def market_data(self):
        """Import and store the market data."""
        file_folder = data_folder + '\\' + self.ticker + ".csv"
        col_names = ['dates', 'open', 'high', 'low', "close", 'volume', 'adj_close']
        self.data = pd.read_csv(file_folder, sep=',', skiprows=[0] , names=col_names)
        return self.data
    
    
    # Create the indicators for the asset.
    def simple_moving_average(self, PERIODS):
        """Calculate the simple moving average (SMA) time series.
            - Returns a pd.DataFrame with the close price and the SMA.
        """ 
        self.PERIODS = PERIODS
        self.simple_ma_df = self.data.loc[:, ['dates', 'close']]
        close_prices = self.simple_ma_df.loc[:, 'close'].values
        P = self.PERIODS
        N = len(close_prices)
        simple_ma_prices = np.empty(N)
        simple_ma_prices[0:P-1] = np.nan
        for i in range(P-1, N):
            simple_ma_prices[i] = np.mean(close_prices[(i-P+1):i+1])
        col_name = 'SMA(' + str(P) + ')'
        self.simple_ma_df[col_name] = simple_ma_prices
        return self.simple_ma_df  #.reset_index(drop=False)
    
    
    
    def exp_moving_average(self, PERIODS):
        """Calculate the exponential moving average (EMA) time series.
            - Returns a pd.DataFrame with the close price and the EMA.
        """ 
        self.PERIODS = PERIODS
        self.exp_ma_df = self.data.loc[:, ['dates', 'close']]
        close_prices = self.exp_ma_df.loc[:, 'close'].values
        P = self.PERIODS
        N = len(close_prices)
        K = 2/(P+1)
        exp_ma_prices = np.empty(N)
        exp_ma_prices[0:P-1] = np.nan
        exp_ma_prices[P-1] = np.mean(close_prices[0:P])
        for i in range(P, N):
            exp_ma_prices[i] = close_prices[i]*K + exp_ma_prices[i-1]*(1-K)
        col_name = 'EMA(' + str(P) + ')'
        self.exp_ma_df[col_name] = exp_ma_prices
        return self.exp_ma_df   #.reset_index(drop=False)
        
    
    # Create the strategies
    def strategy_2SMA(self, ):
        """Bla bla bla.
            More bla bla.    
        """
        pass
    
    
    # Plot the data
    def plot_data(self, df_prices):
        """Plot the closing prices as well as the Moving Average."""
        self.df_prices = df_prices
        NB_TS_TO_PLOT = df_prices.shape[1]
        colors = ['b', 'g', 'r', 'c', 'm', 'y', 'k']
        plt.cla()
        for i in range(1, NB_TS_TO_PLOT):
            plt.plot(df_prices.iloc[:,i], label=df_prices.columns[i], 
                     color=colors[int(np.random.uniform(0,7))], linewidth=0.5)


        plt.legend()
        plt.xlabel('Obs')
        plt.ylabel('Price')
        plt.title('Close Price vs. Moving Average', fontsize=10)
        return plt.show()
        
        
        

