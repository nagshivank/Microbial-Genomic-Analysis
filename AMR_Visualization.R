library(ggplot2)
library(reshape2)

gene_data <- data.frame(
  ID = c("B017151", "B017160", "B053323", "B053623", "B054110", "B054302", "B054392", "B054821", "B054954", "B055059", "B055142", "B055147", "B056268", "B059291", "B059468", "B059547", "B059673", "B060383", "B062556", "B065746", "B065770", "B066302", "B069073", "B069083", "B069085", "B277662", "B376070", "B376297", "B468166", "B916249"),
  blaCDD_1 = c(0, 0, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 0),
  vanG_Cd = c(100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100),
  blaCDD_2= c(100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100),
  vanR_Cd = c(100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100),
  vanS_Cd = c(100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100),
  vanT_Cd = c(100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100),
  vanZ1 = c(100, 100, 100, 0, 100, 100, 100, 100, 100, 100, 100, 0, 100, 100, 100, 100, 0, 100, 0, 100, 100, 100, 100, 100, 100, 100, 100, 100, 0, 0)
)

# replace 100 with 1
gene_data[gene_data == 100] <- 1

# melt the dataframe for easier plotting
melted_gene_data <- melt(gene_data, id.vars = "ID")

# plot
ggplot(melted_gene_data, aes(x = variable, y = value, fill = variable)) +
  geom_bar(stat = "identity") +
  facet_wrap(~ ID, scales = "free") +
  labs(title = "Visualization of Gene Profiles", x = "Genes", y = "Presence") +
  scale_y_continuous(labels = c("Absent", "Present"), breaks = c(0, 1)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Calculate cumulative presence/absence of each gene
cumulative_presence <- colSums(gene_data[, -1])

# Convert to data frame
cumulative_data <- data.frame(Gene = names(cumulative_presence), Presence = cumulative_presence)

# plot pie chart of all labels
pie(cumulative_data$Presence, labels = cumulative_data$Gene, main = "Cumulative Presence of AMR genes")



# calculate cumulative presence/absence of each gene
cumulative_presence <- colSums(gene_data[, -1])

# calculate percentages
percentages <- cumulative_presence / sum(cumulative_presence) * 100

# convert to dataframe
cumulative_data <- data.frame(Gene = names(cumulative_presence), Presence = cumulative_presence, Percentage = percentages)

colors <- ifelse(grepl("^van", cumulative_data$Gene), "lightblue", "yellow")

# plot pie chart-grouped genes
pie(cumulative_data$Percentage, labels = paste(cumulative_data$Gene, "\n", round(cumulative_data$Percentage, 1), "%"), col = colors, main = "Cumulative Presence of AMR genes")

