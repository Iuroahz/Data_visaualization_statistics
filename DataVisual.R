
# Packages installation
install.packages("dplyr")   
install.packages("ggplot2")
install.packages("tidytext") 
install.packages("stringr")         # String toolset
install.packages("reshape2")        # Transform data between wide and long formats.  
install.packages("tidyr")           # Provides gather(), separate() and spread() functions for tidying the messy data.  
install.packages("wordcloud")       # A visual representation of text data.  
install.packages("RColorBrewer")    # Provides colour schemes for maps (and other graphics).  
install.packages("hunspell")        # A high-level wrapper for finding spelling errors within a text document.  
install.packages("SnowballC")       # Snowball stemmer based on the C 'libstemmer' UTF-8 Library.  

# read in the libraries we're going to use
library(dplyr)           
library(ggplot2)         
library(tidytext)       
library(stringr) 
library(reshape2) 
library(tidyr)          
library(RColorBrewer)
library(wordcloud) 
library(hunspell)        
library(SnowballC)   

# Set up the work dictionary
setwd("Desktop")

# Load and extract data 
library(readr)
load_data <- read_csv("~/Downloads/Instagram Data.csv")
ins_data <-load_data [1:5000,]  # Extract the first 5000 rows of data
colnames(ins_data)[1] <- 'index'  # Name the first column

# Rename columns and select attributes
names(ins_data)[names(ins_data) == "index"] <- "id_description"
names(ins_data)[names(ins_data) == "title"] <- "title_description"
names(ins_data)[names(ins_data) == "description"] <- "text_description"
ins_data <- ins_data %>% select(id_description, title_description, text_description)

# Data cleaning
cleaned_text <- ins_data %>% filter(str_detect(text_description, "[A-Za-z\\d]") | text_description !="")
cleaned_text$text_description <- gsub("<br />", "", cleaned_text$text_description)

# Tokenization
text_df <- tibble(id_description = cleaned_text$id_description, text_description = cleaned_text$text_description)
text_df <- text_df %>%  unnest_tokens(word, text_description)

# Stemming Words 
text_df$word <- wordStem(text_df$word,  language = "english")

#View(table(text_df$word))

# Remove stop words
data(stop_words)  
text_df <- text_df %>% anti_join(stop_words, "word")  # return all rows from stop_words without a match in "word".
#View(text_df %>% count(word, sort = TRUE))

# Word Frequency Statistics & Visualization
View(text_df %>% count(word, sort = TRUE))

png(filename = "plot_01_word_frequency.png",
    res = 300,  # image resolution
    width = 1600, 
    height = 1600)

text_df %>% 
  count(word, sort = TRUE) %>% 
  filter(n > 1000) %>% 
  mutate(word = reorder(word, n)) %>% 
  ggplot(aes(n, word)) + 
  geom_col() + 
  ylab(NULL) 

dev.off() 

# Sentiment Analysis
Sentiment_Analysis <- text_df %>% 
  inner_join(get_sentiments("bing"), "word") %>% 
  count(id_description, sentiment) %>% 
  spread(sentiment, n, fill = 0) %>% 
  mutate(sentiment = positive - negative)

head(View(Sentiment_Analysis))

Sentiment_Analysis_Word_Count <- text_df %>% 
  inner_join(get_sentiments("bing"), "word") %>% 
  count(word, sentiment, sort = TRUE) %>% 
  ungroup()

png(filename = "plot_02_sentiment_analysis.png",  #  Most Common Positive and Negative Words
    res = 300, 
    width = 1600, 
    height = 1600)

Sentiment_Analysis_Word_Count %>% 
  group_by(sentiment) %>% 
  top_n(12, n) %>%
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill = sentiment)) + 
  geom_col(show.legend = FALSE) + 
  facet_wrap(~sentiment, scales = "free_y") + 
  labs(y = "Contribution to Sentiment", x = NULL) + 
  coord_flip()

dev.off() 

# Selected 200 words to create Word Clouds 
png(filename = "plot_03_word_cloudd.png", 
    res = 300, 
    width = 1600, 
    height = 1600)

text_df %>% 
  anti_join(stop_words, "word") %>%
  count(word) %>% 
  with(wordcloud(word, n, max.words = 200))

dev.off()                

png(filename = "plot_04_word_cloudd.png",
    res = 300, 
    width = 1600, 
    height = 1600)

text_df %>% 
  inner_join(get_sentiments("bing"), "word") %>%
  count(word, sentiment, sort = TRUE) %>% 
  acast(word ~ sentiment, value.var = "n", fill = 0) %>% 
  comparison.cloud(colors = c("grey70", "grey20"), max.words = 200)

dev.off()              

# blend_tf_idf 
term_frequency_review <- text_df %>% count(word, id_description, sort = TRUE)
term_frequency_review$total_words <- as.numeric(term_frequency_review %>% summarize(total = sum(n)))
term_frequency_review$document <- as.character('Description')
term_frequency_review <- term_frequency_review %>% bind_tf_idf(word, id_description, n)

png(filename = "plot_05_tf_idf_update.png",
    res = 300, 
    width = 1600, 
    height = 1600)

term_frequency_review %>% 
  arrange(desc(tf)) %>% 
  mutate(word = factor(word, levels = rev(unique(word)))) %>% 
  group_by(document) %>% 
  top_n(12, tf) %>% 
  ungroup() %>% 
  ggplot(aes(word, tf, fill = document)) + 
  geom_col(show.legend = FALSE) + 
  labs(x = NULL, y = "tf-idf") + 
  facet_wrap(~document, ncol = 2, scales = "free") + 
  coord_flip()

dev.off()               

