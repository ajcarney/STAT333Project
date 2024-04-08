library(dplyr)
library(maps)

counties <- read.csv("https://raw.githubusercontent.com/kjhealy/fips-codes/master/county_fips_master.csv")
ev <- read.csv("/home/aiden/Documents/School/STAT333/Project/data/Electric_Vehicle_Population_Size_History_By_County.csv")

ev2 <- ev %>% mutate(county_name = paste(County, "County")) %>%
  left_join(counties, by=c("county_name" = "county_name", "State" = "state_abbr")) %>%
  filter(!is.na(fips))

#map("county", fill=TRUE, col=ev2$Percent.Electric.Vehicles)