"""
    Main file for the execution of the strategy.

    1) Main function

    An instance of the class "Asset" is instantiated as: Asset(ticker, asset_class, sector, country) 

"""

# ---------------------------------- Path management -------------------------------- #
import os
import pathlib
import sys

parent_folder = str(pathlib.PurePath(os.getcwd()))
strategy_folder = parent_folder
sys.path.append(strategy_folder)
# ----------------------------------------------------------------------------------- #

# Import needed packages

from Asset import *
import matplotlib.pyplot as plt


# ------------------------------------- Main ---------------------------------------- #

# Test one asset ----------------------------------------------------------------------:
## instanciate an object
asset = Asset('IR', 'Stock', 'Technology', 'US')
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

df_test2 = pd.concat([asset.exp_moving_average(8),
                     asset.exp_moving_average(21).iloc[:,2],
                     asset.exp_moving_average(200).iloc[:,2]], axis = 1, ignore_index=False)
asset.plot_data(df_test2)

# Get the results for each asset on both Buy and Sell
results_2MA = asset.strategy_MMA('EMA', [8, 21])


results_3MA = asset.strategy_MMA('EMA', [8, 21, 200])
#-----------------------------------------------------------------------------------------


# Test all assets ----------------------------------------------------------------------:
data_folder = parent_folder + '\\data\\assets'
assets_names = [x.replace(".csv","")  for x in os.listdir(data_folder)]

info_list = ['buy_summary', 'sell_summary', 'buy_strategy', 'sell_strategy', 'general_df']
batt_avg_buy =  np.zeros(len(assets_names))
batt_avg_sell =  np.zeros(len(assets_names))
mean_returns_buy =  np.zeros(len(assets_names))
mean_returns_sell =  np.zeros(len(assets_names))

for a in enumerate(assets_names):
    asset = Asset(a[1])
    results_asset = asset.strategy_MMA('EMA', [8, 21, 200])
    batt_avg_buy[a[0]] = results_asset['buy_summary']['batting_avg']
    batt_avg_sell[a[0]] = results_asset['sell_summary']['batting_avg']
    mean_returns_buy[a[0]] = results_asset['buy_summary']['mean']
    mean_returns_sell[a[0]] = results_asset['sell_summary']['mean']
    
# Plot the 4 df
df1 = pd.DataFrame({'assets':assets_names, 'batt_avg_buy':batt_avg_buy})
df2 = pd.DataFrame({'assets':assets_names, 'batt_avg_sell':batt_avg_sell})
df3 = pd.DataFrame({'assets':assets_names, 'mean_ret_buy':mean_returns_buy})
df4 = pd.DataFrame({'assets':assets_names, 'mean_ret_sell':mean_returns_sell})


fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2)
ax1.scatter(df1['assets'], df1['batt_avg_buy'], color='blue')
ax1.axhline(y=0.5, color='r', linestyle='--')
ax2.scatter(df2['assets'], df2['batt_avg_sell'], color='green')
ax2.axhline(y=0.5, color='r', linestyle='--')
ax3.hist(df3['mean_ret_buy'], color='blue')
ax3.axvline(x=0.0, color='r', linestyle='--')
ax4.hist(df4['mean_ret_sell'], color='green')
ax4.axvline(x=0.0, color='r', linestyle='--')

ax1.title.set_text('Buy strategy: Mean Batt_avg = ' + str(round(np.mean(df1['batt_avg_buy']),2)))
ax2.title.set_text('Sell Strategy: Mean Batt_avg = ' + str(round(np.mean(df2['batt_avg_sell']),2)))
ax3.title.set_text('Buy strategy: Mean Return = ' + str(round(np.mean(df3['mean_ret_buy']),2)))
ax4.title.set_text('Sell Strategy: Mean Return = ' + str(round(np.mean(df4['mean_ret_sell']),2)))

fig.suptitle('Strategy EMA(8, 21, 200)')
plt.show()
