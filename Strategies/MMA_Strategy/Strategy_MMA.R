# This function implements the MA strategy
Strategy_MMA <- function(MA1, p1, MA2, p2){
  
  #Rearrange the dataframe
  df_Strat <- data.frame(MA1[, c(1, 5, 6)], MA2[, 6])
  colnames(df_Strat) <- c('Date', 'Close', paste('MA ', p1), paste("MA ", p2))
  
  df_Strat[1:(p1-1), 3] <- NA
  df_Strat[1:(p2-1), 4] <- NA
  
 # To Store the crossings Up = 1, Down = -1, Flat = 0 of the MA
 Cross_ts <- vector(length = nrow(df_Strat))
 Cross_ts[1:(max(p1, p2) - 1)] <- rep(NA, max(p1, p2) - 1)
 # Initialize the first point
 Cross_ts[max(p1, p2)] <- 0
 
 # Fill the other points
 # In this strategy we will add the momentum which will be defined as the angle over the periods
 # of the MA of the price if the angle is < 45° then the crossing is 0 and not 1 since it is
 # not g enough
 
 for(i in (max(p1, p2) + 1):nrow(df_Strat)){
  if(df_Strat[i - 1, 3] < df_Strat[i - 1, 4] & 
     df_Strat[i, 3] > df_Strat[i, 4]){
    
    #Calculate the angle of the shorter P
    theta = atan((df_Strat[i, 2] - df_Strat[i - min(p1, p2), 2])/ min(p1, p2))
    if(theta < pi/4 & theta > -pi/4){
      Cross_ts[i] <- 1
    }else{
      Cross_ts[i] <- 0
    }
    
  }else if(df_Strat[i - 1, 3] > df_Strat[i - 1, 4] &
           df_Strat[i, 3] < df_Strat[i, 4]){
    
    #Calculate the angle of the shorter P
    theta = atan((df_Strat[i, 2] - df_Strat[i - min(p1, p2), 2])/ min(p1, p2))
    if(theta < 0){
      Cross_ts[i] <- -1
    }else{
      Cross_ts[i] <- 0
    }
    
  }else{
   Cross_ts[i] <- 0
  }
 }
 df_Strat$Crosses <- Cross_ts
 
 
 # Calculate the returns at each -1 point (Sell Point)
 # 1) Get the indices for 1 and -1
 ind_up <- which(df_Strat$Crosses == 1)
 ind_down <- which(df_Strat$Crosses == -1)
 
 # 2) Define the variables to store the Data
 
 ## Buy Strategy
 iter <- min(length(ind_up), length(ind_down))
 Buy_Date <- vector(length = iter)
 Buy_Price <- vector(length = iter)
 Close_Date <- vector(length = iter)
 Close_Price <- vector(length = iter)
 Strat_return_Buy <- vector(length = iter)
 
 for(i in 1:iter){
  Buy_Date[i] <- format(df_Strat[ind_up[i], 1], "%Y-%m-%d")
  Buy_Price[i] <- df_Strat[ind_up[i], 2]
  Close_Date[i] <- format(df_Strat[ind_down[i], 1], "%Y-%m-%d")
  Close_Price[i] <- df_Strat[ind_down[i], 2]
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
   Sell_Date[i] <- format(df_Strat[ind_down[i], 1], "%Y-%m-%d")
   Sell_Price[i] <- df_Strat[ind_down[i], 2]
   Close_Date[i] <- format(df_Strat[ind_up[i+1], 1], "%Y-%m-%d")
   Close_Price[i] <- df_Strat[ind_up[i+1], 2]
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
 list(df_Strat, Strat_summary_Buy, Strat_summary_Sell, batt_avg_Buy, batt_avg_Sell)
}
