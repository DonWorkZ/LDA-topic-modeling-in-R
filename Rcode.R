
library("dplyr", warn.conflicts = FALSE)

library(tidyr)
library(ggplot2)

library(textmineR)
library(text2vec)


View(data.frame1)
data.frame1<-read.csv("C:/Users/glane/Downloads/similarity2.csv", header=TRUE, sep=";")


#create DTM
dtm <- CreateDtm(doc_vec = data.frame1$description, # character vector of documents
                 doc_names = data.frame1$repository_id, # document names
                 ngram_window = c(1, 2), # minimum and maximum n-gram length
                 stopword_vec = c(stopwords::stopwords("en"), # stopwords from tm
                                  stopwords::stopwords(source = "smart")), # this is the default value
                 lower = TRUE, # lowercase - this is the default value
                 remove_punctuation = TRUE, # punctuation - this is the default
                 remove_numbers = TRUE, # numbers - this is the default
                 verbose = FALSE, # Turn off status bar for this demo
                 cpus = 2) # default is all available cpus on the system

dtm <- dtm[,colSums(dtm) > 2]

model <- FitLdaModel(dtm = dtm, 
                     k = 20,
                     iterations = 200, 
                     burnin = 180,
                     alpha = 0.1,
                     beta = 0.05,
                     optimize_alpha = TRUE,
                     calc_likelihood = TRUE,
                     calc_coherence = TRUE,
                     calc_r2 = TRUE,
                     cpus = 2) 
str(model)
summary(model$coherence)
hist(model$coherence, 
     col= "blue", 
     main = "Histogram of probabilistic coherence")
# Get the top terms of each topic
model$top_terms <- GetTopTerms(phi = model$phi, M = 5)
head(t(model$top_terms))
# Get the prevalence of each topic
# You can make this discrete by applying a threshold, say 0.05, for
# topics in/out of docuemnts. 
model$prevalence <- colSums(model$theta) / sum(model$theta) * 100

# prevalence should be proportional to alpha
plot(model$prevalence, model$alpha, xlab = "prevalence", ylab = "alpha")
# textmineR has a naive topic labeling tool based on probable bigrams
model$labels <- LabelTopics(assignments = model$theta > 0.05, 
                            dtm = dtm,
                            M = 1)

head(model$labels)
#>     label_1                      
#> t_1 "imaging_data"         
#> t_2 "big_data"               
#> t_3 "data_science"     
#> t_4 "data_science"                  
#> t_5 "data_science"         
#> t_6 "asp_net"

# put them together, with coherence into a summary table
model$summary <- data.frame(topic = rownames(model$phi),
                            label = model$labels,
                            coherence = round(model$coherence, 3),
                            prevalence = round(model$prevalence,3),
                            top_terms = apply(model$top_terms, 2, function(x){
                              paste(x, collapse = ", ")
                            }),
                            stringsAsFactors = FALSE)
model$summary[ order(model$summary$prevalence, decreasing = TRUE) , ][ 1:20 , ]
