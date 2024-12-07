#install.packages('ggplot2')
#install.packages('igraph') 
library(igraph)
library(ggplot2)
library(ggraph)
library(dplyr)
library(ggrepel)

#Edge and Vertices count 
vcount(graph)
ecount(graph)
node_counts <- table(V(graph)$type)
print(node_counts)

#connected network and density
is.connected(graph)
edge_density(graph)

# Filter data for the first 5 fields
fields_subset <- aggregated_data %>%
  filter(aggregated_data[[CS.Field]] %in% unique(CS.Field)[1:5])

# Faceted barplots for the all fields
ggplot(fields_subset, aes(x = Language, y = Count, fill = Language)) +
  geom_bar(stat = "identity", show.legend = FALSE) +  # No legend for fill
  facet_wrap(~ CS.Field, scales = "free_y") +            # One subplot per field
  theme_minimal() +
  labs(
    title = "Programming Language Counts for First 5 Fields",
    x = "Programming Language",
    y = "Count"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),  # Rotate x-axis labels
    strip.text = element_text(face = "bold", size = 10) # Style facet labels
  )



# Normalized Degree Centrality --------------------------------------------------

# Calculate degree centrality 
degree_centrality <- degree(graph)
normalized_degree_centrality <- degree_centrality / (vcount(graph)-1)
V(graph)$normalized_degree_centrality <- normalized_degree_centrality
library(ggraph)

# Create the plot 
ggraph(graph, layout = 'graphopt') + 
  geom_edge_arc(strength=0.2, width=0.6, alpha=0.2)+  
  geom_node_point(aes(size = normalized_degree_centrality, color = normalized_degree_centrality)) +  # Nodes sized by centrality
  scale_size_continuous(range = c(3, 8)) +  # Scale the node size
  scale_color_gradient(low = "lightblue", high = "darkblue") +  # Color nodes by centrality
  geom_text_repel(
    aes(x = x, y = y, label = name), 
    size = 3.75,
    max.overlaps = Inf,        
    box.padding = 0.3,         
    point.padding = 0.5,       
    segment.color = "black",   
    segment.size = 0.3,) +
  theme_graph() + 
  labs(title = "Network Visualization Based on Normalized Degree Centrality") +
  theme(legend.position = "bottom") +
  theme(plot.margin = unit(c(1, 1, 1, 1), "cm"))

node_data <- data.frame(
  name = V(graph)$name,                 
  type = V(graph)$type,                 
  normalized_degree_centrality = normalized_degree_centrality
)

top_language_nodes = node_data %>%
  filter(type == TRUE) %>%        
  arrange(desc(normalized_degree_centrality))      
head(top_language_nodes, 10) 



# Betweenness centrality --------------------------------------------------------

betweenness_centrality <- betweenness(graph, directed = FALSE, normalized = TRUE)

V(graph)$betweenness <- betweenness_centrality

node_data <- node_data %>%
  mutate(betweenness = betweenness_centrality)

top_betweenness <- node_data %>%
  filter(type == TRUE) %>%
  arrange(desc(betweenness))
head(top_betweenness, 10)

ggraph(graph, layout = 'graphopt') + 
  geom_edge_arc(strength=0.2, width=0.6, alpha=0.2) +  # Edges
  geom_node_point(aes(size = betweenness, color = betweenness)) +  # Nodes
  scale_size_continuous(range = c(3, 8)) +  # Scale node size
  scale_color_gradient(low = "lightblue", high = "darkblue") +  # Color nodes by centrality
  geom_text_repel(
    aes(x = x, y = y, label = name), 
    size = 5,
    max.overlaps = Inf,        
    box.padding = 0.2,         
    point.padding = 0.0,       
    segment.color = "black",   
    segment.size = 0.2,) +  theme_graph() +
  labs(
    title = "Network Visualization Based on Betweenness Centrality",
    color = "Betweenness Centrality",
    size = "Betweenness Centrality"
  ) +
  theme(legend.position = "bottom")+
  theme(plot.margin = unit(c(1, 1, 1, 1), "cm"))



# Leiden Algorithm --------------------------------------------------------------
#install.packages('ggforce')
library(ggforce) #for geom_mark_hull() which adds a color outline to each commmunity

#Optimal Resilution Parameter 
gamma <- seq(0.25,3,0.025)
nc <- vector("numeric",length(gamma))
for (i in 1:length(gamma)){
  gc <- cluster_leiden(graph, objective_function = "modularity",
                       n_iterations = 3, resolution_parameter = gamma[i])
  nc[i] <- length(gc)
}
plot(gamma,nc,xlab=" Resolution Parameter",ylab="# Communities",main="graph")

rate_of_change <- diff(nc) / diff(gamma)
min_rate_index <- which.min(rate_of_change)
optimal_gamma <- gamma[min_rate_index]
optimal_gamma

#communities
leiden_communities <- cluster_leiden(graph, objective_function ="modularity", n_iterations= 3, resolution_parameter = optimal_gamma)
V(graph)$community <- membership(leiden_communities)

#visualization
ggraph(graph, layout = 'graphopt') + 
  geom_mark_hull(aes(x = x, y = y, group = factor(community), fill = factor(community)),
                 color = "black", alpha = 0.2) +  
  geom_edge_arc(strength=0.2, width=0.6, alpha=0.2) +  # Edges
  geom_node_point(aes(color = factor(community)), size = 3) + 
  geom_node_text(aes(label = name, color = ifelse(type == TRUE, "Programming Language", "CS Field") ), repel = TRUE, size = 3.75) + 
  scale_fill_manual(values = rainbow(length(unique(V(graph)$community)))) +
  scale_color_manual(values = c("Programming Language" = "red", "CS Field" = "blue", "Community" = rainbow(unique(V(graph)$community)))) +
  theme_graph() +
  labs(title = "Leiden Community Detection", color = "Community") +
  theme(legend.position = "bottom")




#table 3 info
for (i in 1:length(unique(V(graph)$community))){
  density = edge_density(induced_subgraph(graph, V(graph)[community == i]))
  cat("Density of community " ,i, ":",density, "\n")
}


for (i in 1:length(unique(V(graph)$community))) {
  nodes_in_community <- V(graph)[community == i]
  language_nodes <- nodes_in_community[V(graph)$type[nodes_in_community] == TRUE]
  most_central_node <- names(language_nodes[which.max(degree(graph, v = language_nodes))])
  cat("Most Central Language Node of community", i, ":", most_central_node, "\n")
}

for (i in 1:length(unique(V(graph)$community))) {
  nodes_in_community <- V(graph)[community == i]
  field_nodes <- names(nodes_in_community[V(graph)$type[nodes_in_community] == FALSE])
  cat(" Field Nodes in community", i, ":", field_nodes, "\n")
}

for (i in 1:length(unique(V(graph)$community))) {
  nodes_in_community <- V(graph)[community == i]
  field_nodes <- nodes_in_community[V(graph)$type[nodes_in_community] == FALSE]
  most_central_node <- names(field_nodes[which.max(degree(graph, v = field_nodes))])
  cat("Most Central Field Node of community", i, ":", most_central_node, "\n")
}
