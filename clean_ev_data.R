library(dplyr)
library(usmap)
library(ggplot2)

# counties for getting fips
counties <- read.csv("https://raw.githubusercontent.com/kjhealy/fips-codes/master/county_fips_master.csv")

# first ev dataset
ev <- read.csv("data/Electric_Vehicle_Population_Size_History_By_County.csv")

ev_clean <- ev %>% mutate(county_name = paste(County, "County")) %>%
  left_join(counties, by=c("county_name" = "county_name", "State" = "state_abbr")) %>%
  filter(!is.na(fips)) %>%
  mutate(Date=as.Date(Date, format="%B %d %Y")) %>% 
  group_by(fips) %>%  # convert time series to latest data only
  mutate(max_date=max(Date)) %>%
  ungroup() %>%
  filter(Date==max_date) %>%
  filter(vehicle_primary_use=="Passenger") %>%
  select(Date, fips, vehicle_primary_use, battery_electric_vehicles, plug_in_hybrid_electric_vehicles, ev_total,
         non_ev_total, total_vehicles, percent_ev) 
  
# plot_usmap(data = ev_clean, values = "percent_ev", color = "grey", size = .25) +
#   scale_fill_gradient(low = "blue", high = "red", na.value = "transparent")

#write.csv(ev_clean, "clean_data/Electric_Vehicle_Population_Size_By_County.csv")



# second ev dataset
ev2 <- read.csv("data/ev_market_penetration.csv")

# function to add " County" to string if not already present
# function to add " County" to string if not already present
appendCounty <- function(s) {
  s <- unlist(strsplit(s, ", "))
  if (s[2] == "LA") {
    if (!endsWith(s[1], " Parish")) {
      s[1] <- paste(s[1], "Parish")
    }
  } else if (s[2] != "AK") {
    if (!endsWith(s[1], " County")) {
      s[1] <- paste(s[1], "County")
    }
  }

  return (as.character(s[1]))
}

ev2 <- ev2 %>% mutate(county_state = paste(county, ", ", state, sep=""))
ev2$county <- lapply(ev2$county_state, appendCounty)

ev2_clean <- ev2 %>% mutate(county=as.character(county)) %>%
  left_join(counties, by=c("county" = "county_name", "state" = "state_abbr")) %>%
  filter(!is.na(fips)) %>%
  select(fips, ev_market_penetration)

plot_usmap(data = ev2_clean, values = "ev_market_penetration", color = "grey", size = .25) +
  scale_fill_gradient(low = "blue", high = "red", na.value = "transparent")+
  theme(legend.position = "right")

write.csv(ev2_clean, "clean_data/ev_market_penetration.csv", row.names=FALSE)

