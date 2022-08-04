# ----- import the libraries to be used -----
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import math
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
    def __init__(self, ticker, asset_class=False, sector=False, country=False):
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
        if self.PERIODS == 0:
            pass
        
        self.simple_ma_df = self.market_data().loc[:, ['dates', 'close']]
        close_prices = self.market_data().loc[:, 'close'].values
        P = self.PERIODS
        N = len(close_prices)
        simple_ma_prices = np.empty(N)
        simple_ma_prices[0:P-1] = np.nan
        simple_ma_prices[P-1:] = [np.mean(close_prices[(i-P+1):i+1]) for i in range(P-1, N)]
        col_name = 'SMA(' + str(P) + ')'
        self.simple_ma_df[col_name] = simple_ma_prices
        return self.simple_ma_df  #.reset_index(drop=False)
    
    
    
    def exp_moving_average(self, PERIODS = False):
        """Calculate the exponential moving average (EMA) time series.
            - Input the parameter PERIODS as integer.
            - Returns a pd.DataFrame with the close price and the EMA.
        """ 
        self.PERIODS = PERIODS
        if self.PERIODS is False:
            return print('Please insert a period for the MA')
        if self.PERIODS == 0:
            pass
        
        self.exp_ma_df = self.market_data().loc[:, ['dates', 'close']]
        close_prices = self.market_data().loc[:, 'close'].values
        P = self.PERIODS
        N = len(close_prices)
        K = 2/(P+1)
        exp_ma_prices = np.empty(N)
        exp_ma_prices[0:P-1] = np.nan
        exp_ma_prices[P-1] = np.mean(close_prices[0:P])
        for p in range(P,N):
            exp_ma_prices[p] = close_prices[p]*K + exp_ma_prices[p-1]*(1-K) 
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
        if len(self.periods) > 3:
            return print('Please enter only 3 periods')
        
        
        #### Strategy:
        self.periods.sort()
        #if len(self.periods) == 2:
        #    self.periods.append(0)
        
        #### For the Simple Moving Average -------------------------------------------------------        
        if self.type_of_MA == 'SMA':
            self.ma_df = self.simple_moving_average(self.periods[0])
            for i in range(1, len(self.periods)):
                col_name = 'SMA(' + str(self.periods[i]) + ')'
                self.ma_df.insert(self.ma_df.shape[1], col_name,
                                   self.simple_moving_average(self.periods[i]).iloc[:,2].values)
                
        #### For the Exponential Moving Average --------------------------------------------------
        elif self.type_of_MA == 'EMA':
            self.ma_df = self.exp_moving_average(self.periods[0])
            for i in range(1, len(self.periods)):
                col_name = 'EMA(' + str(self.periods[i]) + ')'
                self.ma_df.insert(self.ma_df.shape[1], col_name,
                                   self.exp_moving_average(self.periods[i]).iloc[:,2].values)
            
        # Temporary df to avoid altering the original one
        df_temp = self.ma_df.iloc[:,:]
        # Set the vector to store the crosses
        crosses1 = np.zeros(self.ma_df.shape[0])
        crosses2 = np.zeros(self.ma_df.shape[0])
            
        # Croses for the  Short term MA and Medium Term MA
        conditions = [
            ((df_temp[df_temp.columns[2]].values <= df_temp[df_temp.columns[3]].values) &
             (df_temp[df_temp.columns[2]].shift(-1).values > df_temp[df_temp.columns[3]].shift(-1).values)),
            ((df_temp[df_temp.columns[2]].values >= df_temp[df_temp.columns[3]].values) &
             (df_temp[df_temp.columns[2]].shift(-1).values < df_temp[df_temp.columns[3]].shift(-1).values))
            ]
        choices = [1, -1]
        crosses1 = np.select(conditions, choices, default = 0)
            
        # Croses for the Medium Term MA and the Long Term MA
        if df_temp.shape[1] == 5:
            conditions = [
                ((df_temp[df_temp.columns[3]].values <= df_temp[df_temp.columns[4]].values) &
                 (df_temp[df_temp.columns[3]].shift(-1).values > df_temp[df_temp.columns[4]].shift(-1).values)),
                ((df_temp[df_temp.columns[3]].values >= df_temp[df_temp.columns[4]].values) &
                 (df_temp[df_temp.columns[3]].shift(-1).values < df_temp[df_temp.columns[4]].shift(-1).values))
                ]
            choices = [1, -1]
            crosses2 = np.select(conditions, choices, default = 0)
        else:
            crosses2 = np.zeros(len(crosses1))
            
        # Regroup the crosses on one vector
        crosses = crosses1 + crosses2
        crosses = np.insert(crosses, 0, 0) # Insert a 0 in the first position
        crosses = crosses[0:len(crosses)-1]
        
        # Incorporate the crosses in the ma_df
        self.ma_df.insert(self.ma_df.shape[1], 'signal', crosses)
        # Identify the signals for Buy and Sell
        signal_up = self.ma_df[self.ma_df.loc[:,'signal'] >= 1
                               ].loc[:,['dates', 'close']].reset_index(drop=True)
        signal_down = self.ma_df[self.ma_df.loc[:,'signal'] <= -1
                                 ].loc[:,['dates', 'close']].reset_index(drop=True)
        signal_up.columns = ['dates_buy', 'price_buy']
        signal_down.columns = ['dates_sell', 'price_sell']
        
        # Strategy final data frame
        self.buy_strategy_df = pd.concat([signal_up, 
                                     signal_down], axis=1, ignore_index=False)
        self.buy_strategy_df.drop(self.buy_strategy_df.tail(1).index, inplace=True)
        self.buy_strategy_df = self.buy_strategy_df.reindex(columns=['dates_buy',
                                                                     'dates_sell',
                                                                     'price_buy',
                                                                     'price_sell'])
        signal_up = signal_up.drop(0, axis=0).reset_index(drop=True)
        self.sell_strategy_df = pd.concat([signal_down,signal_up], 
                                          axis=1, ignore_index=False)
        self.sell_strategy_df = self.sell_strategy_df.reindex(columns=['dates_sell',
                                                                       'dates_buy',
                                                                       'price_sell',
                                                                       'price_buy'])
        
        # Add a column for the returns of each position Buy and Sell
        self.buy_strategy_df['returns'] = \
            (self.buy_strategy_df.loc[:,'price_sell'].values/
             self.buy_strategy_df.loc[:,'price_buy'].values) - 1
        self.sell_strategy_df['returns'] = \
            ((self.sell_strategy_df.loc[:,'price_buy'].values/
              self.sell_strategy_df.loc[:,'price_sell'].values) - 1)*-1
                
            
        
        
        ## Refine the output dictionary with the information ---------------------------------------
        # Summary for the Buy
        self.buy_strat_summary = self.buy_strategy_df.loc[:,'returns'].describe()
        self.buy_strat_summary['count'] = np.sum(crosses>0)
        self.buy_strat_summary['IR'] = self.buy_strat_summary['mean']/self.buy_strat_summary['std']
        POSITIVE_RETURNS = len(self.buy_strategy_df[self.buy_strategy_df.loc[:,'returns'].values > 0])
        self.buy_strat_summary['batting_avg'] = POSITIVE_RETURNS/self.buy_strat_summary['count'] 
            
        # Summary for the Sell
        self.sell_strat_summary = self.sell_strategy_df.loc[:,'returns'].describe()
        self.buy_strat_summary['count'] = np.sum(crosses<0)
        self.sell_strat_summary['IR'] = self.sell_strat_summary['mean']/self.sell_strat_summary['std']
        POSITIVE_RETURNS = len(self.sell_strategy_df[self.sell_strategy_df.loc[:,'returns'].values > 0])
        self.sell_strat_summary['batting_avg'] = POSITIVE_RETURNS/self.sell_strat_summary['count']
        
        self.output = {'buy_summary':self.buy_strat_summary, 'sell_summary':self.sell_strat_summary,
                       'buy_strategy':self.buy_strategy_df, 'sell_strategy':self.sell_strategy_df,
                       'general_df':self.ma_df}
        return self.output

    
    
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
        
        
        

