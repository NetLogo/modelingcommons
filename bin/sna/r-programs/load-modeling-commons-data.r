# R program to load Modeling Commons data into Statnet

# R < /Users/reuven/Desktop/load-modeling-commons-data.r --save

library('statnet')

print("Authored models")
authoring.links <- read.csv('authoring-network.data', header=FALSE, sep='\t')[1:2]
names(authoring.links) <- c('person', 'node');
network.authoring.links <- network(authoring.links, bipartite=length(authoring.links$person));

print("Downloaded models")
download.user.models.links <- 
    read.csv('download_user_models-network.data', header=FALSE, sep='\t')[1:2]
names(download.user.models.links) <- c('person', 'node')
download.user.models.network <-
     network(download.user.models.links, bipartite=length(download.user.models.links$person))

print("Forked models")
forking.links <- read.csv('forking-network.data', header=FALSE, sep='\t')[1:2]
names(forking.links) <- c('person', 'node')
forking.network <- network(forking.links, bipartite=length(forking.links$person))

print("Tagged models")
tagging.links <- read.csv('tagging-network.data', header=FALSE, sep='\t')[1:2]
names(tagging.links) <- c('person', 'node')
tagging.network <- network(tagging.links, bipartite=length(tagging.links$person))

print("Viewed models")
viewing.links <- read.csv('viewing-network.data', header=FALSE, sep='\t')[1:2]
names(viewing.links) <- c('person', 'node')
viewing.network <- network(viewing.links, bipartite=length(viewing.links$person))
 
# Load information about people
people.information <- read.csv('person.data', header=TRUE, sep='\t')
