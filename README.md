# LDA-topic-modeling-in-R

Configuration and settings for LDA topic modeling in R

How to make the correct step to implement lda topic modeling using stm package in r and text preprocessing before lda analysis

One problem I have is the one with the measure of semantic coherence
If you run it you will see that there are negative values like for the 5 topics it is -31.57351
But in paper which have this approach they report that they use the lda approach from gensim python library and to find the semantic coherence they use the gensim module CoherenceModel and the have number from semantic coherence fron 0 until 1

https://gist.github.com/adamlauretig/d15381b562881563e97e1e922ee37920
A general example of gensim in r
