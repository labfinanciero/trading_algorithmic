
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


##### Functions -------------------------------------------------------------------
## --------------------------------------------------------------------------------

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

# -------------------------------------------------------------------------------





## Import Data ------------------------------------------------------------
## ------------------------------------------------------------------------

path_data = paste(path_dir, "/data/activos", sep = "")
Files_names = list.files(path_data)


Asset = floor(runif(1, 1, length(Files_names)))
Prices = read.csv(paste(path_data, "/", Files_names[Asset], sep = ""))[,-c(6,7)]
Ticker = strsplit(colnames(Prices)[2], "[.]")[[1]][1]
colnames(Prices) <- c("Date", "Open", "High", "Low", "Close")

p = 20
MA_prices = MA(Prices, p)

# -------------------------------------------------------------------------



# Add the crossings of the Price on the MA: Up = 1, Down = -1, Flat = 0 -----
# ---------------------------------------------------------------------------

# To Store the crossings
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


# ----------------------------------------------------------------------------






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
