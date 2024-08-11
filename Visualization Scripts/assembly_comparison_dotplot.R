library(ggplot2)
library(dplyr)

# Load in data
quast_data <- read.csv("transposed_report.csv", header = TRUE)

# Divide Total length by 1 million
quast_data <- quast_data %>% mutate(Total_length_million = Total_length / 1e6)

# Create a scatter plot
scatter_plot <- ggplot(quast_data, aes(x = contigs_, y = Total_length_million, label = Assembly)) +
  geom_point(size = 3) +
  geom_text(vjust = -0.5) +  # Adjust the vertical position of labels
  labs(title = "QUAST: # Contigs / Total length (Mbp)",
       x = "# Contigs",
       y = "Total assembly length (Mbp)") +
  theme_minimal() +
  scale_x_continuous(limits = c(0, 300))

# Display the scatter plot
print(scatter_plot)