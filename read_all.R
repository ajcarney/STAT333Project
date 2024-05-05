library(dplyr)
library(usmap)
library(ggplot2)

counties           <- read.csv("https://raw.githubusercontent.com/kjhealy/fips-codes/master/county_fips_master.csv", stringsAsFactors = FALSE)
ev_market          <- read.csv("clean_data/ev_market_penetration.csv")
gas                <- read.csv("clean_data/gas_prices.csv")
pop                <- read.csv("clean_data/PopulationEstimates.csv")
unempl_and_income  <- read.csv("clean_data/Unemployment_cleaned.csv")
rpp                <- read.csv("clean_data/cost_of_living_rpp.csv")
living_wage        <- read.csv("clean_data/fbc_livingwage_data_2024.csv")
weather            <- read.csv("clean_data/weather.csv")
voting             <- read.csv("clean_data/Voting_data_2022.csv")
charging           <- read.csv("clean_data/charging_stations_clean.csv")
education          <- read.csv("clean_data/Education_2017-2021.csv")
tax                <- read.csv("clean_data/gas_tax.csv")
state_gas          <- read.csv("clean_data/state_gas.csv")


# merge all the data by county

data <- counties %>%
  filter(fips != 11001) %>%  # remove Washington DC because it is listed twice and doesn't have data anyways
  left_join(ev_market, by=c("fips" = "fips")) %>%
  left_join(state_gas, by=c("state_abbr" = "state")) %>%
  mutate(gas_regular = regular, gas_mid = mid, gas_premium = premium, gas_diesel = diesel) %>%
  left_join(pop, by=c("fips" = "FIPStxt")) %>%
  mutate(log_population = log(CENSUS_2020_POP)) %>%
  left_join(unempl_and_income, by=c("fips" = "fips_code")) %>%
  left_join(rpp, by=c("fips" = "FIPS.Code")) %>%
  left_join(living_wage, by=c("fips" = "county_fips")) %>%
  mutate (log_income = log(Median_Household_Income_2021)) %>%
  mutate (Income_adjusted = Median_Household_Income_2021 / RPP) %>%
  mutate (log_income_adjusted = log(Income_adjusted)) %>%
  left_join(tax, by=c("fips" = "fips")) %>%
  left_join(weather, by=c("fips" = "fips")) %>%
  left_join(voting, by=c("fips" = "county_fips")) %>%
  left_join(charging, by=c("fips" = "fips")) %>% 
  mutate(n_charging_locations = ifelse(is.na(n_charging_locations), 0, n_charging_locations)) %>%
  left_join(education, by=c("fips" = "FIPS")) %>% 
  mutate(county_name = county_name.x.x, State=state_abbr.x) %>%
  select(fips, county_name, State,
    ev_market_penetration,                          # ev data
    n_charging_locations,                           # charging
    gas_regular, gas_mid, gas_premium, gas_diesel,  # gas prices
    gas_tax,
    CENSUS_2020_POP, log_population,                # population
    unemployment_rate_2022,                         # unemployment
    Median_Household_Income_2021, RPP,              # income, etc
    log_income, Income_adjusted, log_income_adjusted,
    Perc_Adults_Less_Than_HSD,	                    # education
      Perc_Adults_Only_HSD,	
      Perc_Adults_SmCollege, 
      Perc_Adults_Bachelor_Or_Above,  
    min_temp, max_temp, precipitation, avg_temp,    # weather
    Perc_Dem, Perc_Rep                              # voting
    
  ) %>%
  filter(State != "CT") 




# filter by rows with no NAs
#data2 <- data[complete.cases(data),]

# plot on a map to visually see where data is
plot_usmap(data = data, values = "avg_temp", color = "grey", size = .25, linewidth=0.1) +
  scale_fill_gradient(low = "pink", high = "darkred", na.value = "transparent") +
  theme(legend.position = "right")



write.csv(data, "clean_data/data.csv")
