library(dplyr)
library(maps)

counties <- read.csv("https://raw.githubusercontent.com/kjhealy/fips-codes/master/county_fips_master.csv")
ev <- read.csv("data/Electric_Vehicle_Population_Size_History_By_County.csv")

ev2 <- ev %>% mutate(county_name = paste(County, "County")) %>%
  left_join(counties, by=c("county_name" = "county_name", "State" = "state_abbr")) %>%
  filter(!is.na(fips)) %>%
  mutate(Date=as.Date(Date, format="%B %d %Y")) %>% 
  group_by(fips) %>%  # convert time series to latest data only
  mutate(max_date=max(Date)) %>%
  ungroup() %>%
  filter(Date==max_date) %>%
  filter(Vehicle.Primary.Use=="Passenger") %>%
  select(-max_date)  # remove max_date temporary column
  

library(usmap)


plot_usmap(data = ev2, values = "Percent.Electric.Vehicles", color = "grey", size = .25) +
  scale_fill_gradient(low = "blue", high = "red", na.value = "transparent")

# write.csv(ev2, "clean_data/Electric_Vehicle_Population_Size_By_County.csv")  
