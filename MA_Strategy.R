
###### Moving Average Strategy for the Project Algorithmic Trading ######
##### ------------------------------------------------------------ #####

# Libraries to use  -------

library(dplyr)
library(dygraphs)
library(xts)      
library(tidyverse)
library(lubridate)
library(ggplot2)
library(plotly)
library(tseries)

# -------------------------

path_dir = "C:/Users/camil/Documents/GitHub/Algorithmic_Traiding" 
setwd(path_dir)



## -------------------------------------------------------------------------
## -------------------------------- Functions ------------------------------
## -------------------------------------------------------------------------

# This function creates the MA for a period p
MA <- function(Prices, p){
  # Handle NA values
  for(i in 2:nrow(Prices)){
    if(is.na(Prices$Close[i]) == TRUE){
      Prices$Open[i] = Prices$Open[i - 1]
      Prices$High[i] = Prices$High[i - 1]
      Prices$Low[i] = Prices$Low[i - 1]
      Prices$Close[i] = Prices$Close[i - 1]
    }
  }
  
  # Calculate the Moving average
  MA_prices <- c()
  for(i in length(Prices$Close):p){
    MA_prices[i] = sum(Prices$Close[(i - p + 1):i])/p 
  }
  
  #MA_prices = MA_prices[-c(1:(p - 1))]
  #New_Dates = Dates[(length(Dates) - length(MA_prices) + 1):length(Dates)]
  MA_prices = data.frame(Prices, MA_prices)
  colnames(MA_prices) <- c("Date", "Open", "High", "Low", "Close", paste("MA", p))
  MA_prices
}


# This function implements the MA strategy
Strategy_MA <- function(MA_prices, p){

  # To Store the crossings Up = 1, Down = -1, Flat = 0
  Cross_ts <- c()
  Cross_ts[1:(p-1)] <- rep(NA, p-1)
  # Initialize the first point
  Cross_ts[p] = 0
   
  # Fill the other points
  for(i in (p+1):nrow(MA_prices)){
    if(MA_prices$Close[i - 1] < MA_prices[i - 1, 6] && 
       MA_prices$Close[i] > MA_prices[i, 6]){
      Cross_ts[i] = 1
    }else if(MA_prices$Close[i - 1] > MA_prices[i - 1, 6] && 
             MA_prices$Close[i] < MA_prices[i, 6]){
      Cross_ts[i] = -1
    }else{
      Cross_ts[i] = 0
    }
  }
  MA_prices$Crosses <- Cross_ts
  

  # Calculate the returns at each -1 point (Sell Point)
  # 1) Get the indices for 1 and -1
  ind_up <- which(MA_prices$Crosses == 1)
  ind_down <- which(MA_prices$Crosses == -1)
  
  # 2) Define the variables to store the Data
  Buy_Date <- c()
  Buy_Price <- c()
  Sell_Date <- c()
  Sell_Price <- c()
  Strat_return <- c()
  
  for(i in 1:(min(length(ind_up), length(ind_down)))){
    Buy_Date[i] = MA_prices$Date[ind_up[i]]
    Buy_Price[i] = MA_prices$Close[ind_up[i]]
    Sell_Date[i] = MA_prices$Date[ind_down[i]]
    Sell_Price[i] = MA_prices$Close[ind_down[i]]
    Strat_return[i] = (Sell_Price[i]/Buy_Price[i] - 1) * 100 
  }
  
  Strat_summary = data.frame(Buy_Date, Sell_Date, Buy_Price, 
                             Sell_Price, Strat_return)
  colnames(Strat_summary) <- c("Buy Date", "Sell Date", "Buy Price", 
                               "Sell Price", "Returns in %")
  
  # Batting average
  batt_avg = round(length(which(Strat_summary$`Returns in %` >= 0))
                   /length(ind_up) * 100, 2)
  
  # Output
  list(MA_prices, Strat_summary, batt_avg)
}

## -------------------------------------------------------------------------
## ---------------------------- END Functions ------------------------------
## -------------------------------------------------------------------------




## -------------------------------------------------------------------------
## ------------------------------- MAIN ------------------------------------
## -------------------------------------------------------------------------

## Import data:
  path_data = paste(path_dir, "/data/activos", sep = "")
  Files_names = list.files(path_data)

## Select an Asset:
  Asset = floor(runif(1, 1, length(Files_names)))
  Prices = read.csv(paste(path_data, "/", Files_names[Asset], sep = ""))[,-c(6,7)]
  Ticker = strsplit(colnames(Prices)[2], "[.]")[[1]][1]
  colnames(Prices) <- c("Date", "Open", "High", "Low", "Close")

## Select the periods for the MA Strategy
  p = 20

## Implement the Strategy and get the results
  Strategy_Results = Strategy_MA(MA(Prices, p), p)

  MA_prices = Strategy_Results[[1]]
  Strat_summary = Strategy_Results[[2]]
  batt_avg = Strategy_Results[[3]]

  
## ------------------------------------------------------------------------
## ------------------------------ END MAIN --------------------------------
## ------------------------------------------------------------------------
  
  
  
  
# -----------------------------------------------------------------------
# ---------------------------- Results Analysis ---------------------------
# -------------------------------------------------------------------------

Stats_strategy = data.frame(c(as.array(summary(Strat_summary$`Returns in %`, 
                                               digits = 4)), batt_avg))
colnames(Stats_strategy) <- ""
row.names(Stats_strategy)[7] <- "Batting avg %"
hist(Strat_summary$`Returns in %`, main = Ticker, xlab = "Returns in %")


# Interactive graph Price vs MA ------------------------------------------

MA_prices$Date <- as.POSIXct(MA_prices$Date, format = "%Y-%m-%d", tz = "GMT")
data_plot <- irts(MA_prices$Date, value = as.matrix(MA_prices[, 2:6]))

dygraph(data_plot, main = Ticker) %>%
  dyOptions(labelsUTC = TRUE, fillGraph = FALSE, colors = c("red", "black")) %>%
  dyRangeSelector() %>%
  dyCrosshair(direction = "vertical") %>%
  dyHighlight(highlightCircleSize = 5, highlightSeriesBackgroundAlpha = 1, hideOnMouseOut = FALSE)  %>%
  dyCandlestick() %>%
  dyRoller(showRoller = T, rollPeriod = 1)


# -------------------------------------------------------------------------
# --------------------------- End Results Analysis ------------------------
# -------------------------------------------------------------------------