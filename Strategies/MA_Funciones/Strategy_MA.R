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
 iter <- min(length(ind_up), length(ind_down))
 Buy_Date <- vector(length = iter)
 Buy_Price <- vector(length = iter)
 Sell_Date <- vector(length = iter)
 Sell_Price <- vector(length = iter)
 Strat_return <- vector(length = iter)
 
 for(i in 1:iter){
  Buy_Date[i] <- MA_prices$Date[ind_up[i]]
  Buy_Price[i] <- MA_prices$Close[ind_up[i]]
  Sell_Date[i] <- MA_prices$Date[ind_down[i]]
  Sell_Price[i] <- MA_prices$Close[ind_down[i]]
  Strat_return[i] <- (Sell_Price[i]/Buy_Price[i] - 1) * 100 
 }
 
 Strat_summary <- data.frame(Buy_Date, Sell_Date, Buy_Price, 
                             Sell_Price, Strat_return)
 colnames(Strat_summary) <- c("Buy Date", "Sell Date", "Buy Price", 
                              "Sell Price", "Returns in %")
 
 # Batting average
 batt_avg <- round(length(which(Strat_summary$`Returns in %` >= 0))
                   /length(ind_up) * 100, 2)
 
 # Output
 list(MA_prices, Strat_summary, batt_avg)
}
