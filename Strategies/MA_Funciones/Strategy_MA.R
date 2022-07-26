# This function implements the MA strategy
Strategy_MA <- function(MA_prices, p){
 
 # To Store the crossings Up = 1, Down = -1, Flat = 0
 Cross_ts <- vector(length = nrow(MA_prices))
 Cross_ts[1:(p-1)] <- rep(NA, p - 1)
 # Initialize the first point
 Cross_ts[p] <- 0
 
 # Fill the other points
 for(i in (p + 1):nrow(MA_prices)){
  if(MA_prices$Close[i - 1] < MA_prices[i - 1, 6] & 
     MA_prices$Close[i] > MA_prices[i, 6]){
   Cross_ts[i] <- 1
  }else if(MA_prices$Close[i - 1] > MA_prices[i - 1, 6] &
           MA_prices$Close[i] < MA_prices[i, 6]){
   Cross_ts[i] <- -1
  }else{
   Cross_ts[i] <- 0
  }
 }
 MA_prices$Crosses <- Cross_ts
 
 
 # Calculate the returns at each -1 point (Sell Point)
 # 1) Get the indices for 1 and -1
 ind_up <- which(MA_prices$Crosses == 1)
 ind_down <- which(MA_prices$Crosses == -1)
 
 # 2) Define the variables to store the Data
 
 ## Buy Strategy
 iter <- min(length(ind_up), length(ind_down))
 Buy_Date <- vector(length = iter)
 Buy_Price <- vector(length = iter)
 Close_Date <- vector(length = iter)
 Close_Price <- vector(length = iter)
 Strat_return_Buy <- vector(length = iter)
 
 for(i in 1:iter){
  Buy_Date[i] <- format(MA_prices$Date[ind_up[i]], "%Y-%m-%d")
  Buy_Price[i] <- MA_prices$Close[ind_up[i]]
  Close_Date[i] <- format(MA_prices$Date[ind_down[i]], "%Y-%m-%d")
  Close_Price[i] <- MA_prices$Close[ind_down[i]]
  Strat_return_Buy[i] <- (Close_Price[i]/Buy_Price[i] - 1) * 100 
 }
 Strat_summary_Buy <- data.frame(Buy_Date, Close_Date, Buy_Price, 
                                 Close_Price, Strat_return_Buy)
 colnames(Strat_summary_Buy) <- c("Buy Date", "Closing Date", "Buy Price", 
                                  "Closing Price", "Ret % (Buy)")
 
 
 ## Sell Strategy
 iter <- min(length(ind_up), length(ind_down))
 Close_Date <- vector(length = iter)
 Close_Price <- vector(length = iter)
 Sell_Date <- vector(length = iter)
 Sell_Price <- vector(length = iter)
 Strat_return_Sell <- vector(length = iter)
 
 for(i in 1:iter){
   Sell_Date[i] <- format(MA_prices$Date[ind_down[i]], "%Y-%m-%d")
   Sell_Price[i] <- MA_prices$Close[ind_down[i]]
   Close_Date[i] <- format(MA_prices$Date[ind_up[i+1]], "%Y-%m-%d")
   Close_Price[i] <- MA_prices$Close[ind_up[i+1]]
   Strat_return_Sell[i] <- (Close_Price[i]/Sell_Price[i] - 1) * 100 * -1
 }
 Strat_summary_Sell <- data.frame(Sell_Date, Close_Date, Sell_Price, 
                                  Close_Price, Strat_return_Sell)
 colnames(Strat_summary_Sell) <- c("Sell Date", "Closing Date", "Sell Price", 
                                  "Closing Price", "Ret % (Sell)")
 
 
 # Batting average
 batt_avg_Buy <- round(length(which(Strat_summary_Buy$`Ret % (Buy)` >= 0))
                   /length(ind_up) * 100, 2)
 batt_avg_Sell <- round(length(which(Strat_summary_Sell$`Ret % (Sell)` >= 0))
                       /length(ind_down) * 100, 2)
 
 # Output
 list(MA_prices, Strat_summary_Buy, Strat_summary_Sell, batt_avg_Buy, batt_avg_Sell)
}
