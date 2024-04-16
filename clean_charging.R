library(dplyr)


counties <- read.csv("https://raw.githubusercontent.com/kjhealy/fips-codes/master/county_fips_master.csv")
unique_counties <- counties %>% group_by(county_name) %>% summarise(fips = first(fips), n=n()) %>%
    filter(n==1)

charging <- read.csv("data/charging_stations.csv") %>% select(-X)
charging <- charging %>% 
  filter(State != "DC") %>%  # remove DC, not wanted
  left_join(counties, by=c("county" = "county_name", "State" = "state_abbr")) %>% 
  group_by(fips) %>%
  summarise(n_charging_locations = n()) %>%
  na.omit()

write.csv(charging, "clean_data/charging_stations_clean.csv")
