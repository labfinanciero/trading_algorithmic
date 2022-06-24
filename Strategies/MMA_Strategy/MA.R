# This function creates the MA for a period p
MA <- function(Prices, p){
 # Handle NA values
 for(i in 2:nrow(Prices)){
  if(is.na(Prices$Close[i]) == TRUE){
   Prices$Open[i] <- Prices$Open[i - 1]
   Prices$High[i] <- Prices$High[i - 1]
   Prices$Low[i] <- Prices$Low[i - 1]
   Prices$Close[i] <- Prices$Close[i - 1]
  }
 }
 
 # Calculate the Moving average
 MA_prices <- vector(length = length(Prices$Close) - p + 1)
 for(i in length(Prices$Close):p){
  MA_prices[i] <- sum(Prices$Close[(i - p + 1):i])/p 
 }
 
 #MA_prices = MA_prices[-c(1:(p - 1))]
 #New_Dates = Dates[(length(Dates) - length(MA_prices) + 1):length(Dates)]
 MA_prices <- data.frame(Prices, MA_prices)
 colnames(MA_prices) <- c("Date", "Open", "High", "Low", "Close", paste("MA", p))
 return(MA_prices)
}
