# R program to deal with paper 3 data

# R < /Users/reuven/Desktop/load-modeling-commons-data.r --save

library('statnet')

print("Model authors")
people.models <- read.csv('paper-3-people-models.csv', sep='\t', header=FALSE)
names(people.models) <- c('person', 'node');
network.people.models <- network(people.models, bipartite=length(people.models$person));


print("People countries")
people.countries <- read.csv('paper-3-people-countries.csv', sep='\t', header=FALSE)
names(people.countries) <- c('person', 'country');

# Now, how do I combine these two and analyze the resulting network?
# I understand that I need to create a vertext attribute, but can't
# figure out how to assign it, such that the node for a person_id gets
# the correct country code assigned.

# And then I'm not sure how to perform the "matching term" analysis.
# I didn't see anything obvious in the statnet documentation, but it's 
# quite possible that I missed something.

# ------------------------------------------------------------
