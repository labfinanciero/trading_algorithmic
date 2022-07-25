# This function implements the Adri EMA strategy
Strategy_AEMA <- function(EMA, periods){
  
  p1 = periods[1]
  p2 = periods[2]
  p3 = periods[3]
  
  #Rearrange the dataframe
  df_Strat <- data.frame(EMA[,c(1, 5, 6, 7, 8)])
  colnames(df_Strat) <- c('Date', "Close", paste("EMA", p1), 
                          paste("EMA", p2), paste("EMA", p3))
  
  
 # To Store the crossings Up = 1, Down = -1, Flat = 0 of the MA
 Cross_ts <- array(NA, c(length = nrow(df_Strat), 2))

 
 # Initialize the first point
 Cross_ts[max(p1, p2), 1] <- 0
 
 if(length(df_Strat$Date) > p3){
   Cross_ts[max(p2, p3), 2] <- 0
 }
 
 
 # Fill the other points in column 1: p1 vs p2.   
 
 for(i in (max(p1, p2) + 1):nrow(df_Strat)){
  if(df_Strat[i - 1, 3] < df_Strat[i - 1, 4] & 
     df_Strat[i, 3] > df_Strat[i, 4]){
    Cross_ts[i, 1] <- 1
    }else if(df_Strat[i - 1, 3] > df_Strat[i - 1, 4] &
           df_Strat[i, 3] < df_Strat[i, 4]){
      Cross_ts[i, 1] <- -1
    }else{
      Cross_ts[i, 1] <- 0
    }
 }
 
 
 # Fill the other points in column 2: p2 vs p3.
 if(length(df_Strat$Date) < p3){
   Cross_ts[, 2] <- 0
 }else{
   for(i in (max(p2, p3) + 1):nrow(df_Strat)){
     if(df_Strat[i - 1, 4] < df_Strat[i - 1, 5] & 
        df_Strat[i, 4] > df_Strat[i, 5]){
       
       Cross_ts[i, 2] <- 1
       
     }else if(df_Strat[i - 1, 4] > df_Strat[i - 1, 5] &
              df_Strat[i, 4] < df_Strat[i, 5]){
       
       Cross_ts[i, 2] <- -1
       
    }else{
      
       Cross_ts[i, 2] <- 0
    }
     
   }
 }
 
 df_Strat$Crosses_p1p2 <- Cross_ts[, 1]
 df_Strat$Crosses_p2p3 <- Cross_ts[, 2]
 
 # Calculate the returns at each -1 point (Sell Point)
 # 1) Get the indices for 1 and -1
 ind_up_p1p2 <- which(df_Strat$Crosses_p1p2 == 1)
 ind_down_p1p2 <- which(df_Strat$Crosses_p1p2 == -1)
 
 ind_up_p2p3 <- which(df_Strat$Crosses_p2p3 == 1)
 ind_down_p2p3 <- which(df_Strat$Crosses_p2p3 == -1)
 
 # 2) Store data p1 vs p2
 
 ## Buy Strategy
 iter <- min(length(ind_up_p1p2), length(ind_down_p1p2))
 Buy_Date_p1p2 <- vector(length = iter)
 Buy_Price_p1p2 <- vector(length = iter)
 Close_Date_p1p2 <- vector(length = iter)
 Close_Price_p1p2 <- vector(length = iter)
 Strat_return_Buy_p1p2 <- vector(length = iter)
 
 for(i in 1:iter){
  Buy_Date_p1p2[i] <- format(df_Strat[ind_up_p1p2[i], 1], "%Y-%m-%d")
  Buy_Price_p1p2[i] <- df_Strat[ind_up_p1p2[i], 2]
  Close_Date_p1p2[i] <- format(df_Strat[ind_down_p1p2[i], 1], "%Y-%m-%d")
  Close_Price_p1p2[i] <- df_Strat[ind_down_p1p2[i], 2]
  Strat_return_Buy_p1p2[i] <- (Close_Price_p1p2[i]/Buy_Price_p1p2[i] - 1) * 100 
 }
 
 # Store data p2 vs p3
 
 iter <- min(length(ind_up_p2p3), length(ind_down_p2p3))
 Buy_Date_p2p3 <- vector(length = iter)
 Buy_Price_p2p3 <- vector(length = iter)
 Close_Date_p2p3 <- vector(length = iter)
 Close_Price_p2p3 <- vector(length = iter)
 Strat_return_Buy_p2p3 <- vector(length = iter)
 
 for(i in 1:iter){
   Buy_Date_p2p3[i] <- format(df_Strat[ind_up_p2p3[i], 1], "%Y-%m-%d")
   Buy_Price_p2p3[i] <- df_Strat[ind_up_p2p3[i], 2]
   Close_Date_p2p3[i] <- format(df_Strat[ind_down_p2p3[i], 1], "%Y-%m-%d")
   Close_Price_p2p3[i] <- df_Strat[ind_down_p2p3[i], 2]
   Strat_return_Buy_p2p3[i] <- (Close_Price_p2p3[i]/Buy_Price_p2p3[i] - 1) * 100 
 }
 
 
 Strat_summary_Buy1 <- list(Buy_Date_p1p2, Close_Date_p1p2, Buy_Price_p1p2, 
                                 Close_Price_p1p2, Strat_return_Buy_p1p2)
 Strat_summary_Buy2 <- list(Buy_Date_p2p3, Close_Date_p2p3, Buy_Price_p2p3, 
                                  Close_Price_p2p3, Strat_return_Buy_p2p3)
 names(Strat_summary_Buy1) <- c("Buy Date p1p2", "Closing Date p1p2", "Buy Price p1p2", 
                                  "Closing Price p1p2", "Ret % (Buy) p1p2")
 names(Strat_summary_Buy2) <- c("Buy Date p2p3", "Closing Date p2p3", "Buy Price p2p3", 
                                   "Closing Price p2p3", "Ret % (Buy) p2p3")
 
 Strat_summary_Buy <- list(Strat_summary_Buy1, Strat_summary_Buy2)
 
 
 
 ## Sell Strategy   p1 vs p2
 
 iter <- min(length(ind_up_p1p2), length(ind_down_p1p2))
 Close_Date_p1p2 <- vector(length = iter)
 Close_Price_p1p2 <- vector(length = iter)
 Sell_Date_p1p2 <- vector(length = iter)
 Sell_Price_p1p2 <- vector(length = iter)
 Strat_return_Sell_p1p2 <- vector(length = iter)
 
 for(i in 1:iter){
   Sell_Date_p1p2[i] <- format(df_Strat[ind_down_p1p2[i], 1], "%Y-%m-%d")
   Sell_Price_p1p2[i] <- df_Strat[ind_down_p1p2[i], 2]
   Close_Date_p1p2[i] <- format(df_Strat[ind_up_p1p2[i+1], 1], "%Y-%m-%d")
   Close_Price_p1p2[i] <- df_Strat[ind_up_p1p2[i+1], 2]
   Strat_return_Sell_p1p2[i] <- (Close_Price_p1p2[i]/Sell_Price_p1p2[i] - 1) * 100 * -1
 }
 
 # Sell  p2 vs p3
 iter <- min(length(ind_up_p2p3), length(ind_down_p2p3))
 Close_Date_p2p3 <- vector(length = iter)
 Close_Price_p2p3 <- vector(length = iter)
 Sell_Date_p2p3 <- vector(length = iter)
 Sell_Price_p2p3 <- vector(length = iter)
 Strat_return_Sell_p2p3 <- vector(length = iter)
 
 for(i in 1:iter){
   Sell_Date_p2p3[i] <- format(df_Strat[ind_down_p2p3[i], 1], "%Y-%m-%d")
   Sell_Price_p2p3[i] <- df_Strat[ind_down_p2p3[i], 2]
   Close_Date_p2p3[i] <- format(df_Strat[ind_up_p2p3[i+1], 1], "%Y-%m-%d")
   Close_Price_p2p3[i] <- df_Strat[ind_up_p2p3[i+1], 2]
   Strat_return_Sell_p2p3[i] <- (Close_Price_p2p3[i]/Sell_Price_p2p3[i] - 1) * 100 * -1
 }
 
 
 Strat_summary_Sell1 <- list(Sell_Date_p1p2, Close_Date_p1p2, Sell_Price_p1p2, 
                                  Close_Price_p1p2, Strat_return_Sell_p1p2)
 Strat_summary_Sell2 <- list(Sell_Date_p2p3, Close_Date_p2p3, Sell_Price_p2p3, 
                                   Close_Price_p2p3, Strat_return_Sell_p2p3)
 names(Strat_summary_Sell1) <- c("Sell Date p1p2", "Closing Date p1p2", "Sell Price p1p2", 
                                  "Closing Price p1p2", "Ret % (Sell) p1p2")
 names(Strat_summary_Sell2) <- c("Sell Date p2p3", "Closing Date p2p3", "Sell Price p2p3", 
                                   "Closing Price p2p3", "Ret % (Sell) p2p3")
 
 Strat_summary_Sell <- list(Strat_summary_Sell1, Strat_summary_Sell2)
 
 # Batting average
 batt_avg_Buy <- round(length(which(Strat_summary_Buy1[[5]] >= 0)) +
                       length(which(Strat_summary_Buy2[[5]] >= 0))
                       /(length(ind_up_p1p2) + length(ind_up_p2p3)) * 100, 2)
 batt_avg_Sell <- round(length(which(Strat_summary_Sell1[[5]] >= 0 )) +
                        length(which(Strat_summary_Sell2[[5]] >= 0))
                       /(length(ind_down_p1p2) + length(ind_down_p2p3)) * 100, 2)
 
 # Output
 list(df_Strat, Strat_summary_Buy, Strat_summary_Sell, batt_avg_Buy, batt_avg_Sell)
}
