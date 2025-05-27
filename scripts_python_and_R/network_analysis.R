library(igraph)

# load the nodes and edges CSV files
edges <- read.csv("/Users/Sara/Desktop/habib/fall 24/sna/sna_project/csv_files/final/edges.csv")  
nodes <- read.csv("/Users/Sara/Desktop/habib/fall 24/sna/sna_project/csv_files/final/nodes.csv")
nodes <- nodes["ID"]

# identify unique nodes in edges
all_nodes_in_edges <- unique(c(edges$Source, edges$Target))

# find missing nodes
missing_nodes <- setdiff(all_nodes_in_edges, nodes$ID)

# print missing nodes
cat("Missing nodes:", missing_nodes, "\n")

# create a data frame for the missing nodes
missing_nodes_df <- data.frame(ID = missing_nodes)

# add the missing nodes to the existing nodes data frame
nodes <- rbind(nodes, missing_nodes_df)

# verify that all nodes in edges are now present in the nodes file
all_nodes_in_edges <- unique(c(edges$Source, edges$Target))
missing_nodes <- setdiff(all_nodes_in_edges, nodes$ID)
cat("Missing nodes after update:", missing_nodes, "\n")

# create a graph object from the edge list
graph <- graph_from_data_frame(d = edges[, c("Source", "Target", "Weight")], vertices = nodes, directed = TRUE)
print(head(as_data_frame(graph, what = "edges")))
#i did the above since imf and world bank werent a part of the nodes list (nodes only consisted of countries)

# --- Calculate Network Metrics ---

# Betweenness Centrality
betweenness_centrality <- betweenness(graph, directed = TRUE, normalized = TRUE)

# Closeness Centrality
closeness_centrality <- closeness(graph, mode = "all", normalized = TRUE)

#Using undirected for eigen vector
undirected_graph <- as.undirected(graph, mode = "collapse")

# Calculate eigenvector centrality
eigenvector_centrality <- eigen_centrality(undirected_graph)$vector

# PageRank
pagerank_values <- page_rank(graph, directed = TRUE)$vector

# Degree (In-Degree, Out-Degree, Total Degree)
in_degree <- degree(graph, mode = "in")
out_degree <- degree(graph, mode = "out")
total_degree <- degree(graph, mode = "all")

# Local Clustering Coefficient
local_clustering <- transitivity(graph, type = "local", isolates = "zero")

# Global Clustering Coefficient
global_clustering <- transitivity(graph, type = "global")

# Total Nodes and Edges
total_nodes <- vcount(graph)
total_edges <- ecount(graph)

# --- Save Results ---
# Combine metrics into a single data frame
results <- data.frame(
  Node = V(graph)$name,
  Betweenness = betweenness_centrality,
  Closeness = closeness_centrality,
  Eigenvector = eigenvector_centrality,
  PageRank = pagerank_values,
  InDegree = in_degree,
  OutDegree = out_degree,
  TotalDegree = total_degree,
  LocalClustering = local_clustering
)

# Save the results to a CSV file
write.csv(results, "network_metrics.csv", row.names = FALSE)

# Print Global Statistics
cat("Global Clustering Coefficient:", global_clustering, "\n")
cat("Total Nodes:", total_nodes, "\n")
cat("Total Edges:", total_edges, "\n")

# Sort and display the top 5 for each metric
cat("Top 5 Nodes by Betweenness Centrality:\n")
print(head(results[order(-results$Betweenness), c("Node", "Betweenness")], 5))

cat("Top 5 Nodes by Closeness Centrality:\n")
print(head(results[order(-results$Closeness), c("Node", "Closeness")], 5))

cat("Top 5 Nodes by Eigenvector Centrality:\n")
print(head(results[order(-results$Eigenvector), c("Node", "Eigenvector")], 5))

cat("Top 5 Nodes by PageRank:\n")
print(head(results[order(-results$PageRank), c("Node", "PageRank")], 5))

cat("Top 5 Nodes by In-Degree:\n")
print(head(results[order(-results$InDegree), c("Node", "InDegree")], 5))

cat("Top 5 Nodes by Out-Degree:\n")
print(head(results[order(-results$OutDegree), c("Node", "OutDegree")], 5))

cat("Top 5 Nodes by Local Clustering Coefficient:\n")
print(head(results[order(-results$LocalClustering), c("Node", "LocalClustering")], 5))