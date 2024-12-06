#install.packages('dplyr') 
library(dplyr)
#Data Read 
data = read.csv("~/Desktop/COSC421_Project/Job-Description-Parser-master/Resume_JD_parser/output/Datav2.csv", header = T)
head(data,5)

# Data formatting thru aggregate counts by field and Sub.field
aggregated_data <- data %>%
  group_by(CS.Field, Language) %>%
  summarise(Count = sum(Count), .groups = "drop")

#All plot versions using igraph
#install.packages('igraph') 
library(igraph)


# Create the bipartite graph using igraph package
graph <- graph_from_data_frame(aggregated_data, directed = FALSE)

# Add the 'type' attribute to distinguish between field and Sub.field nodes
V(graph)$type = V(graph)$name %in% aggregated_data$Language

E(graph)$weight = aggregated_data$Count
scaled_weight = (E(graph)$weight - min(E(graph)$weight)) / (max(E(graph)$weight) - min(E(graph)$weight))

# Bipartite layout
layout = layout_as_bipartite(graph)

# graph plot unweighted
plot(
  graph,
  layout = layout,
  vertex.size = 3,
  vertex.label.cex = 0.4,
  vertex.label.dist = 1,
  vertex.label.degree = pi/2,
  vertex.label.color = "black",
  edge.color = 'blue',
  main = "Bipartite Field-Language Network"
)
# graph plot edge weighted
plot(
  graph,
  layout = layout,
  vertex.size = 3,
  vertex.label.cex = 0.4,
  vertex.label.dist = 1,
  vertex.label.degree = pi/2,
  vertex.label.color = "black",
  edge.width = scaled_weight*10, 
  edge.color = 'blue',
  main = "Bipartite Field-Language Network"
)



#plot weighted graph to PDF 
pdf("plot.pdf",10,10)
igraph_options(graph, plot.layout= layout, vertex.size = 3,
               vertex.label.cex = 0.4,
               vertex.label.dist = 1,
               vertex.label.degree = pi/2,
               vertex.label.color = "black",
               edge.width = scaled_weight*5, # Use Count as edge width (weight)
               main = "Bipartite Field-Language Network")
plot(graph)
dev.off()


# Bipartite projection
# Separate the nodes into the two types
field_nodes <- V(graph)[V(graph)$type == FALSE]
language_nodes <- V(graph)[
  V(graph)$type == TRUE]

# Project onto the fields
field_projection <- bipartite_projection(graph)$proj1

# Add edge weights based on shared sub-fields
E(field_projection)$weight <- count_multiple(field_projection)

# Simplify the graph to combine edges (if needed)
field_projection <- simplify(field_projection, edge.attr.comb = list(weight = "sum"))

# Plot the one-mode projection of fields
plot(
  field_projection,
  vertex.size = 5,
  vertex.label.cex = 0.8,
  vertex.label.color = "blue",
  edge.width = E(field_projection)$weight / max(E(field_projection)$weight) * 5,  # Scale edge width
  main = "One-Mode Projection of Programming Languages"
)

#All plot versions using networkD3

#plot to interactive widget 
library(networkD3)
library(htmlwidgets)
p <- simpleNetwork(aggregated_data, height="200px", width="200px",        
                   Source = 1,                 # column number of source
                   Target = 2,                 # column number of target
                   linkDistance = 10,          # distance between node. Increase this value to have more space between nodes
                   charge = -700,                # numeric value indicating either the strength of the node repulsion (negative value) or attraction (positive value)
                   fontSize = 10,               # size of the node names
                   fontFamily = "serif",       # font og node names
                   linkColour = "#666",        # colour of edges, MUST be a common colour for the whole graph
                   nodeColour = "#69b3a2",     # colour of nodes, MUST be a common colour for the whole graph
                   opacity = 0.7,              # opacity of nodes. 0=transparent. 1=no transparency
                   zoom = TRUE                    # Zoom
)
p

# save the widget
saveWidget(p, file=paste0( getwd(), "/networkInteractive2.html"))




#All plot versions using ggraph and tidygraph  
  #install.packages('ggraph')
  #install.packages('tidygraph')

library(ggraph)
library(tidygraph)
library(ggrepel) #For text (node labels) formatting 
tbl_graph = as_tbl_graph(graph)


tbl_graph <- as_tbl_graph(graph) %>%
    mutate(
      node_type = ifelse(name %in% aggregated_data$Language, "language", "field"),
      node_size = ifelse(node_type == "language", aggregated_data$Count, c(1,2) )
    )
  

ggraph(tbl_graph, layout = "bipartite") +
    geom_edge_link(alpha = 0.7, color = "grey") +
    geom_node_point(aes(size = node_size, color = node_type), alpha = 0.9) +
    geom_text_repel(
      aes(x = x, y = y, label = name), 
      size = 3.75,
      max.overlaps = Inf,        
      box.padding = 0.3,         
      point.padding = 0.5,       
      segment.color = "black",   
      segment.size = 0.3) +
    scale_size_continuous(name = "Frequency", range = c(2, 5)) + 
    scale_color_manual(values = c("field" = "blue", "language" = "orange")) +
    theme_void() +
    labs(
      title = "Bipartite Network of Programming Languages and CS Fields",
      color = "Node Type"
    )
  