df = read.csv ("D:/Data Portfolio Projects/Project Dataset/insurance.csv" , header =TRUE) # Loading dataset
num_cols <- unlist(lapply(df, is.numeric)) # Identify numeric columns
plot(df[,num_cols]) # Plotting numeric columns against each other
round(cor(df[,num_cols]),2) # Correlation between variables
smoker = as.factor(df$smoker) 
sex = as.factor(df$sex)
region = as.factor(df$region)
# Boxplots for charges based on categorical variables
boxplot(df$charges ~ smoker, main = 'smoker') 
boxplot(df$charges ~ sex, main = 'sex')
boxplot (df$charges ~ region, main = 'region')
# Linear regression model
model1 = lm(charges ~. , data =df)
summary(model1)