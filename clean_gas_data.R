# determine date range to average over
START_DATE <- "2023-01-08"  # must be in yyyy-mm-dd format
NAVG       <- 365


dates <- seq(as.Date(START_DATE), by = "day", length.out = NAVG)


# Retrieve City gas data
# add everything to this first dataframe and then divide at the end to perform an average
city_gas <- read.csv(paste("https://raw.githubusercontent.com/gueyenono/ScrapeUSGasPrices/master/data/city/", START_DATE , "-usa_gas_price-city.csv", sep=""))
navg <- 1
for(i in 2:length(dates)) {
  date <- format(dates[i], "%Y-%m-%d")
  url <- paste("https://raw.githubusercontent.com/gueyenono/ScrapeUSGasPrices/master/data/city/", date, "-usa_gas_price-city.csv", sep="")

  tryCatch (
    {
      g <- read.csv(url)
      city_gas$regular <- city_gas$regular + g$regular
      city_gas$mid     <- city_gas$mid     + g$mid
      city_gas$premium <- city_gas$premium + g$premium
      city_gas$diesel  <- city_gas$diesel  + g$diesel
      
      navg <- navg + 1
    },
    error = function(cond) {
      cat("Caught error:\n")
      message(conditionMessage(cond))
      cat("\n")
    }
  )
}
city_gas$regular <- city_gas$regular / navg
city_gas$mid     <- city_gas$mid / navg
city_gas$premium <- city_gas$premium / navg
city_gas$diesel  <- city_gas$diesel / navg


# Retrieve State gas data for imputation
state_gas <- read.csv(paste("https://raw.githubusercontent.com/gueyenono/ScrapeUSGasPrices/master/data/state/", START_DATE , "-usa_gas_price-state.csv", sep=""))
navg <- 1
for(i in 2:length(dates)) {
  date <- format(dates[i], "%Y-%m-%d")
  url <- paste("https://raw.githubusercontent.com/gueyenono/ScrapeUSGasPrices/master/data/state/", date, "-usa_gas_price-state.csv", sep="")
  
  tryCatch (
    {
      g <- read.csv(url)
      state_gas$regular <- state_gas$regular + g$regular
      state_gas$mid     <- state_gas$mid     + g$mid
      state_gas$premium <- state_gas$premium + g$premium
      state_gas$diesel  <- state_gas$diesel  + g$diesel
      
      navg <- navg + 1
    },
    error = function(cond) {
      cat("Caught error:\n")
      message(conditionMessage(cond))
      cat("\n")
    }
  )
}
state_gas$regular <- state_gas$regular / navg
state_gas$mid     <- state_gas$mid / navg
state_gas$premium <- state_gas$premium / navg
state_gas$diesel  <- state_gas$diesel / navg


counties <- read.csv("https://raw.githubusercontent.com/kjhealy/fips-codes/master/county_fips_master.csv", stringsAsFactors = FALSE)
msa <- read.csv("data/msa.csv", stringsAsFactors = FALSE)

# function to add " County" to string if not already present
appendCounty <- function(s) {
  s <- unlist(strsplit(s, ", "))
  if (!endsWith(s[1], " County")) {
    s[1] <- paste(s[1], "County")
  }
  
  return (paste(s[1], ", ", s[2], sep=""))
}

#msa$county <- as.character(msa$county)
msa$county <- lapply(msa$county, appendCounty)

nFound <- 0
for(i in 1:nrow(counties)) {
  row <- counties[i,]
  
  county <- paste(row$county_name, ", ", row$state_abbr, sep="")
  
  # try to get the msa_name
  msa_names <- msa[msa$county == county,]
  if (nrow(msa_names) == 1) {
    msa_name <- msa_names$msa_name
    msa_name <- unlist(strsplit(msa_name, " (Metropolitan Statistical Area)"))[1]
    msa_name <- unlist(strsplit(msa_name, ", "))[1]
    
    # try to get the gas price
    pattern <- gsub("-", "|", msa_name)  # replace with | for regex "or"
    gas_rows <- city_gas[grep(pattern, city_gas$city), ]
    if (nrow(gas_rows) > 0) {  # try to get down to one row (unique match) and make sure state matches
      gas_rows <- gas_rows[gas_rows$state == row$state_abbr,]
    } 
    
    # unique match found
    if (nrow(gas_rows) == 1) {
      counties[i, "regular"] <- gas_rows$regular[1]
      counties[i, "mid"] <- gas_rows$mid[1]
      counties[i, "premium"] <- gas_rows$premium[1]
      counties[i, "diesel"] <- gas_rows$diesel[1]
      nFound <- nFound + 1
    }
  }
}

#library(maps)
#map("county", fill=TRUE, col=counties$regular)

# attempt to impute the missing data using the state average
nImpute <- 0
for(i in 1:nrow(counties)) {
  row <- counties[i,]
  g <- state_gas[state_gas$state == row$state_abbr,]
  
  if (anyNA(row) && nrow(g) == 1) {
    counties[i, "regular"] <- g$regular[1]
    counties[i, "mid"] <- g$mid[1]
    counties[i, "premium"] <- g$premium[1]
    counties[i, "diesel"] <- g$diesel[1]
    nImpute <- nImpute + 1
  }
}

cat("found", nFound, "gas prices\n")
cat("imputed", nImpute, "gas prices\n")

write.csv(counties, "data/gas_prices.csv", row.names = F, na="", quote=F)
