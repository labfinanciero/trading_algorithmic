files_source <- list.files(path = "Strategies/MA_Funciones/", full.names = TRUE)
files_source <- files_source[!grepl("main", files_source)]
sapply(files_source, source, .GlobalEnv)

files_names <- list.files(path = "data/activos/", full.names = TRUE)

result <- data.frame(
 ticker = vector(length = length(files_names)),
 batt_avg_Buy = vector(length = length(files_names)),
 batt_avg_Sell = vector(length = length(files_names))
)

## Select the periods for the MA Strategy
p <- 20
cont <- 1
#system.time(
for (i in files_names){
 Prices <- read_csv(file = i, col_types = list("D", "d", "d", "d", "d", "d", "d"))[-c(6, 7)]
 Ticker <- gsub(pattern = "\\.Open", replacement = "", colnames(Prices)[2])
 colnames(Prices) <- c("Date", "Open", "High", "Low", "Close")
 result$ticker[cont] <- Ticker
 result$batt_avg_Buy[cont] <- Strategy_MA(MA(Prices, p), p)[[4]]
 result$batt_avg_Sell[cont] <- Strategy_MA(MA(Prices, p), p)[[5]]
 cont <- cont + 1
}
#)

ggplot(data = result, aes(ticker, batt_avg_Buy)) + 
 geom_point(shape = 21, col = "navy", fill = "royalblue") +
 geom_hline(yintercept = 50, lwd = 0.8, lty = 2,  col = "salmon")
# +
#  scale_x_discrete(guide = guide_axis(n.dodge=5)) 

ggplot(data = result, aes(ticker, batt_avg_Sell)) + 
  geom_point(shape = 21, col = "green4", fill = "green3") +
  geom_hline(yintercept = 50, lwd = 0.8, lty = 2,  col = "salmon")
# +
#  scale_x_discrete(guide = guide_axis(n.dodge=5)) 