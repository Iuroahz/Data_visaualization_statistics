# Natural Language Processing in R : Text Mining
## What is Text Mining?
Text mining is the process of transforming unstructured text into structured data for easy analysis. Text mining uses natural language processing (NLP), allowing machines to understand the human language and process it automatically.
## Dataset information
This dataset consists of reviews about wine from social media—Instagram. Reviews include country, title, description text, points, price, region, variety and taster information. Due to the large amount of data collected in this database(around 130k objects) in CSV format.,therefore, the first 5000 rows of data were extracted as the data of this project. 

https://www.kaggle.com/datasets/muhammadyasirsaleem/instagram-dataset-for-text-classifcation

## Packages
We implemented the common R packages we learn from course: dplyr, ggplot2 and tidytext. Except these, the following packages are useful to conduct text mining:   
•	stringr: String toolset.  
•	reshape2: Transform data between wide and long formats.  
•	tidyr: Provides gather(), separate() and spread() functions for tidying the messy data.  
•	wordcloud: A visual representation of text data.  
•	RColorBrewer: Provides colour schemes for maps (and other graphics).  
•	hunspell : A high-level wrapper for finding spelling errors within a text document.  
•	SnowballC: Snowball stemmer based on the C 'libstemmer' UTF-8 Library.  
