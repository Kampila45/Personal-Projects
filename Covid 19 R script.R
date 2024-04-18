rm(list=ls()) # removes all variables stored previously
library(Hmisc) # import
data <- read.csv("D:/Data Portfolio Projects/Project Dataset/COVID19_line_list_data.csv")

describe(data) #Hmisc command
data$death_dummy <- as.integer(data$death != 0) # cleaned up death column
sum(data$death_dummy) / nrow(data) # death rate
dead = subset(data, death_dummy == 1) # age # claim: people who die are older
alive = subset (data, death_dummy ==0 )
mean(dead$age, na.rm = TRUE)
mean(alive$age, na.rm = TRUE)
t.test(alive$age, dead$age, alternative= "two.sided" , conf.level = 0.95 ) # Test for Significance
# It is statistically significant, we reject the null hypothesis
men = subset(data, gender == "male") # gender # claim: gender has no effect
women = subset(data, gender == "female")
mean(men$death_dummy, na.rm = TRUE)
mean(women$death_dummy, na.rm = TRUE)
t.test(men$death_dummy, women$death_dummy, alternative= "two.sided" , conf.level = 0.99) # Test for significance
# It is statistically significant, we reject the null hypothesis
