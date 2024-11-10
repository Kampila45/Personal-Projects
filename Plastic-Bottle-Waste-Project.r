# Load Libraries
library(tidyverse)
library(lubridate)
library(janitor)
library(data.table)
library(factoextra)
library(cluster)
library(caret)

# Import and Combine Data
data_files <- list.files("C:\\Users\\HP\\Downloads\\Plastic-Bottle-Waste-Data", pattern = "wastebase_scan_summary_.*\\.csv", full.names = TRUE)
print(data_files)  # Check if files are found

# Function to read and combine files with error handling
read_and_combine <- function(files) {
  do.call(rbind, lapply(files, function(file) {
    tryCatch(read.csv(file), error = function(e) {
      message("Error in reading file: ", file)
      NULL
    })
  }))
}

# Combine all data into one dataframe with year as a separate column
all_data <- map_dfr(data_files, ~ mutate(read_and_combine(.x), year = str_extract(.x, "\\d{4}")))

# Print column names to verify
print(colnames(all_data))

# Data Cleaning
all_data <- all_data %>%
  clean_names() %>%
  filter(complete.cases(.)) %>%
  distinct()

# Check for necessary columns
required_columns <- c("collection_date", "bottle_count", "bottle_weight")
missing_columns <- setdiff(required_columns, colnames(all_data))
if (length(missing_columns) > 0) {
  stop(paste("Missing required columns:", paste(missing_columns, collapse = ", ")))
}

# Ensure numeric conversion where necessary
all_data$bottle_count <- as.numeric(all_data$bottle_count)
all_data$bottle_weight <- as.numeric(all_data$bottle_weight)

# Detect and handle outliers by filtering out top 1% extreme values
threshold_bottle_weight <- quantile(all_data$bottle_weight, 0.99, na.rm = TRUE)
threshold_bottle_count <- quantile(all_data$bottle_count, 0.99, na.rm = TRUE)
all_data <- all_data %>%
  filter(bottle_weight <= threshold_bottle_weight, bottle_count <= threshold_bottle_count)

# Add new features
all_data <- all_data %>%
  mutate(bottle_density = bottle_weight / bottle_count,
         bottle_size_category = cut(bottle_weight, breaks = c(0, 0.5, 1, Inf), labels = c("Small", "Medium", "Large")))

# Exploratory Data Analysis (EDA)
# Visualizing the distribution of bottle counts
ggplot(all_data, aes(x = bottle_count)) +
  geom_histogram(binwidth = 10, fill = "blue", color = "black", alpha = 0.7) +
  labs(title = "Distribution of Bottle Counts", x = "Bottle Count", y = "Frequency")

# K-Means Clustering
set.seed(123)
all_data <- all_data %>% filter(!is.na(bottle_count) & !is.na(bottle_weight))

# Determine optimal number of clusters
fviz_nbclust(all_data[, c("bottle_weight", "bottle_count")], kmeans, method = "wss")

# Replace `optimal_num_clusters` with the determined number, e.g., 3
optimal_num_clusters <- 3
kmeans_all <- kmeans(all_data[, c("bottle_weight", "bottle_count")], centers = optimal_num_clusters)
all_data$cluster <- as.factor(kmeans_all$cluster)

# Visualization of Clusters
ggplot(all_data, aes(x = bottle_weight, y = bottle_count, color = cluster)) +
  geom_point() +
  facet_wrap(~ year) +
  labs(title = "K-Means Clustering of Products by Year", x = "Bottle Weight", y = "Bottle Count")

# Regression Analysis
all_data$collection_date <- ymd(all_data$collection_date)  # Ensure the date column is in date format
all_data <- all_data %>%
  mutate(month = month(collection_date), 
         year_factor = as.factor(year))  # Convert year to factor for regression

# Build a linear regression model
lm_model <- tryCatch({
  lm(bottle_count ~ bottle_weight + month + year_factor, data = all_data)
}, error = function(e) {
  message("Error in fitting linear model: ", e$message)
  NULL
})

# Summarize the model
if (!is.null(lm_model)) {
  summary(lm_model)
} else {
  message("Linear model could not be created.")
}

# Export Cleaned Data
write.csv(all_data, "combined_cleaned_plastic_bottle_data.csv", row.names = FALSE)

# Final Message
message("Analysis completed successfully.")


