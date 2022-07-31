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
    def simple_moving_average(self, PERIODS = False):
        """Calculate the simple moving average (SMA) time series.
            - Input the parameter PERIODS as integer.
            - Returns a pd.DataFrame with the close price and the SMA.
        """ 
        self.PERIODS = PERIODS
        if self.PERIODS is False:
            return print('Please insert a period for the MA')
        
        self.simple_ma_df = self.data.loc[:, ['dates', 'close']]
        close_prices = self.simple_ma_df.loc[:, 'close'].values
        P = self.PERIODS
        N = len(close_prices)
        simple_ma_prices = np.empty(N)
        simple_ma_prices[0:P-1] = np.nan
        simple_ma_prices[P-1:] = [np.mean(close_prices[(i-P+1):i+1]) for i in range(P-1, N)]
        col_name = 'SMA(' + str(P) + ')'
        self.simple_ma_df[col_name] = simple_ma_prices
        return self.simple_ma_df  #.reset_index(drop=False)
    
    
    
    def exp_moving_average(self, PERIODS):
        """Calculate the exponential moving average (EMA) time series.
            - Input the parameter PERIODS as integer.
            - Returns a pd.DataFrame with the close price and the EMA.
        """ 
        self.PERIODS = PERIODS
        if self.PERIODS is False:
            return print('Please insert a period for the MA')
        
        self.exp_ma_df = self.data.loc[:, ['dates', 'close']]
        close_prices = self.exp_ma_df.loc[:, 'close'].values
        P = self.PERIODS
        N = len(close_prices)
        K = 2/(P+1)
        exp_ma_prices = np.empty(N)
        exp_ma_prices[0:P-1] = np.nan
        exp_ma_prices[P-1] = np.mean(close_prices[0:P])
        exp_ma_prices[P:] = [close_prices[i]*K + exp_ma_prices[i-1]*(1-K) for i in range(P, N)]
        col_name = 'EMA(' + str(P) + ')'
        self.exp_ma_df[col_name] = exp_ma_prices
        return self.exp_ma_df   #.reset_index(drop=False)
        
    
    # Create the strategies
    def strategy_MMA(self, type_of_MA, periods = False, TAKE_PROFIT = False):
        """2MA strategy (2 Moving Average: Simple or Exponential).
            The strategy consists on taking 2 MA: one short term (i.e: p=8) and one medium
            term (i.e: p=21) and evaluate the crossing up or down of the short term MA through
            the medium term MA. For example, when the ST MA crosses up the MT MA the startegy
            buys the asset. Inversely, if it crosses down the startegy sells the asset.
            The parameter for clossing a position is defined by the user ! (For now)
            
            The inputs are the periods to be used as integer.
            The strategy will return the following items:
                - Statistics (Long, Short and Global).
                - Number of buys and closes.
                - Batting average
        """
        self.type_of_MA = type_of_MA
        self.periods = periods
        self.TAKE_PROFIT = TAKE_PROFIT
        
        # Input control:
        if self.periods is False:
            return print('No periods where passed into the function')
        if type(self.periods) is int:
            return print('Please enter at least 2 periods')
        
        # Strategy:
        self.periods.sort()
        NB_OF_MA = len(self.periods)
        if self.type_of_MA == 'SMA':
            self.sma_df = self.simple_moving_average(self.periods[0])
            for i in range(1, len(self.periods)):
                col_name = 'SMA(' + str(self.periods[i]) + ')'
                self.sma_df.insert(self.sma_df.shape[1], col_name,
                                   self.simple_moving_average(self.periods[i]).iloc[:,2].values)
            
            if NB_OF_MA == 2:
                crosses = np.zeros(self.sma_df.shape[0])
                for i in range(self.periods[1], len(self.crosses)-1):
                    if self.sma_df.iloc[i,2] <= self.sma_df.iloc[i,3] and \
                        self.sma_df.iloc[i+1,2] >= self.sma_df.iloc[i+1,3]:
                           crosses[i+1] = 1
                    elif self.sma_df.iloc[i,2] >= self.sma_df.iloc[i,3] and \
                        self.sma_df.iloc[i+1,2] < self.sma_df.iloc[i+1,3]:
                            crosses[i+1] = -1                       
                self.sma_df.insert(self.sma_df.shape[1], 'signal', crosses)
            elif NB_OF_MA > 2:
                
                pass
            
            self.output = [self.sma_df]
            return self.output
        
        elif self.type_of_MA == 'EMA':
            self.exp_moving_average()
            pass
        
        

    
    
    # Plot the data
    def plot_data(self, df_prices, date_to = False, date_from = False):
        """Plot the closing prices as well as the Moving Average.
            The inputs are:
                - Data Frame with the prices and MA.
                - Date from and Date to plot.
                
            Returns the plot of the prices and the MAs.
        """
        self.df_prices = df_prices
        self.date_from = date_from
        self.date_to = date_to
        if self.date_from is False and self.date_to is False:
            LIM_INF = 0
            LIM_SUP = df_prices.shape[0] + 1
        elif self.date_from is False and self.date_to is not False:
            LIM_INF = 0
            LIM_SUP = int(np.where(df_prices.iloc[:,0].values == self.date_to)[0][0]) + 1
        elif self.date_from is not False and self.date_to is False:
            LIM_INF = int(np.where(df_prices.iloc[:,0].values == self.date_from)[0][0])
            LIM_SUP = df_prices.shape[0] + 1
        else:
            LIM_INF = int(np.where(df_prices.iloc[:,0].values == self.date_from)[0][0])
            LIM_SUP = int(np.where(df_prices.iloc[:,0].values == self.date_to)[0][0]) + 1
        
        NB_TS_TO_PLOT = df_prices.shape[1]
        colors = ['','black','b', 'r', 'y', 'c', 'm', 'g', 'o']
        plt.cla()
        for i in range(1, NB_TS_TO_PLOT):
            plt.plot(df_prices.iloc[LIM_INF:LIM_SUP,i].values, label=df_prices.columns[i], 
                     color=colors[i], linewidth=0.5)
            

        plt.legend()
        plt.xlabel('Obs')
        plt.ylabel('Price')
        plt.title(str(self.ticker) + ': Close Price vs. Moving Average', fontsize=10)
        return plt.show()
        
        
        

