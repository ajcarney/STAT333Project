weather <- read.csv("data/avg_temp.csv")
weather <- weather %>% select(-X)  # extra comma occurred at end of every line leading to extra column

write.csv(weather, "clean_data/weather.csv")