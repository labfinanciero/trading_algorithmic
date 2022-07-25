# This function computes the EMA (Exponential Moving Average) of an Asset

EMA <- function(Prices, periods){
  # Handle NA values
  for(i in 2:nrow(Prices)){
    if(is.na(Prices$Close[i]) == TRUE){
      Prices$Open[i] <- Prices$Open[i - 1]
      Prices$High[i] <- Prices$High[i - 1]
      Prices$Low[i] <- Prices$Low[i - 1]
      Prices$Close[i] <- Prices$Close[i - 1]
    }
  }
  
  p1 <- periods[1]
  p2 <- periods[2]
  p3 <- periods[3]
  
  nb_ps <- length(periods)
  EMA_prices <- array(NA, dim = c(length(Prices$Close), nb_ps))
  
  # Calculate the first EMA, which is a SMA over the periods p
  EMA_prices[p1,1] = mean(Prices$Close[1:p1])
  EMA_prices[p2,2] = mean(Prices$Close[1:p2])
  
  if(length(Prices$Close) > p3){
    EMA_prices[p3,3] = mean(Prices$Close[1:p3])
  }
  
  # Calculate the weighting value k = 2/(p + 1)
  k1 = 2/(p1 + 1)
  k2 = 2/(p2 + 1)
  
  if(length(Prices$Close) > p3){
    k3 = 2/(p3 + 1)
  }else{
    k3 = 0
  }
  
  
  # Fill the other points
  for(i in 1:length(Prices$Close)){
    if(is.na(EMA_prices[length(Prices$Close), 1]) == T){
      EMA_prices[p1 + i, 1] = Prices$Close[p1 + i]*k1 + EMA_prices[p1 + i - 1, 1]*(1 - k1)
    }
    
    if(is.na(EMA_prices[length(Prices$Close), 2]) == T){
      EMA_prices[p2 + i, 2] = Prices$Close[p2 + i]*k2 + EMA_prices[p2 + i - 1, 2]*(1 - k2)
    }
    
    if(is.na(EMA_prices[length(Prices$Close), 3]) == T & k3 != 0){
      EMA_prices[p3 + i, 3] = Prices$Close[p3 + i]*k3 + EMA_prices[p3 + i - 1, 3]*(1 - k3)
    }
  } 
  
  EMA_prices <- data.frame(Prices, EMA_prices)
  colnames(EMA_prices) <- c("Date", "Open", "High", "Low", "Close", 
                            paste("EMA", p1), paste("EMA", p2), paste("EMA", p3))
  
  return(EMA_prices)
  
}
