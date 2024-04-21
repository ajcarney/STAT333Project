library(dplyr)
#library(usmap)
#library(ggplot2)

counties           <- read.csv("https://raw.githubusercontent.com/kjhealy/fips-codes/master/county_fips_master.csv", stringsAsFactors = FALSE)
electric_vehichles <- read.csv("clean_data/Electric_Vehicle_Population_Size_By_County.csv")
ev_market          <- read.csv("clean_data/ev_market_penetration.csv")
gas                <- read.csv("clean_data/gas_prices.csv")
pop                <- read.csv("clean_data/PopulationEstimates.csv")
unempl_and_income  <- read.csv("clean_data/Unemployment_cleaned.csv")
rpp                <- read.csv("clean_data/cost_of_living_rpp.csv")
living_wage        <- read.csv("clean_data/fbc_livingwage_data_2024.csv")
weather            <- read.csv("clean_data/weather_data.csv")
voting             <- read.csv("clean_data/Voting_data_2022.csv")
charging           <- read.csv("clean_data/charging_stations_clean.csv")
education          <- read.csv("clean_data/Education_2017-2021.csv")


# merge all the data by county

data <- counties %>%
  filter(fips != 11001) %>%  # remove Washington DC because it is listed twice and doesn't have data anyways
  left_join(ev_market, by=c("fips" = "fips")) %>%
  left_join(electric_vehichles, by=c("fips" = "fips")) %>%
  left_join(gas, by=c("fips" = "fips")) %>%
  left_join(pop, by=c("fips" = "FIPStxt")) %>%
  left_join(unempl_and_income, by=c("fips" = "fips_code")) %>%
  left_join(rpp, by=c("fips" = "FIPS.Code")) %>%
  left_join(living_wage, by=c("fips" = "county_fips")) %>%
  left_join(weather, by=c("fips" = "fips")) %>%
  left_join(voting, by=c("fips" = "county_fips")) %>%
  left_join(charging, by=c("fips" = "fips")) %>% 
  mutate(n_charging_locations = ifelse(is.na(n_charging_locations), 0, n_charging_locations)) %>%
  left_join(education, by=c("fips" = "FIPS")) %>% 
  select(fips, county_name.x,
    ev_market_penetration,                          # ev data
    n_charging_locations,                           # charging
    gas_regular, gas_mid, gas_premium, gas_diesel,  # gas prices
    CENSUS_2020_POP,                                # population
    unemployment_rate_2022,                         # unemployment
    Median_Household_Income_2021, RPP,              # income, etc
    Perc_Adults_Less_Than_HSD,	                    # education
      Perc_Adults_Only_HSD,	
      Perc_Adults_SmCollege, 
      Perc_Adults_Bachelor_Or_Above,  
    min_temp, max_temp, precipitation, avg_temp,    # weather
    Perc_Dem, Perc_Rep                              # voting
    
  )
  
  


# filter by rows with no NAs
#data2 <- data[complete.cases(data),]

# plot on a map to visually see where data is
#plot_usmap(data = data2, values = "gas_regular", color = "grey", size = .25) +
#  scale_fill_gradient(low = "blue", high = "red", na.value = "transparent")


write.csv(data2, "clean_data/data.csv")
