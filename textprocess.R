# Data Skills R - II
# Final Project: Text Analysis

# Load libraries
req_libraries <- c("tidyverse", "dplyr", "stringr", "readxl", "sf", "ggplot2", "usmap", "tigris", "shiny", "rvest", "tidytext", "textdata", "sentimentr", "fixest", "httr")
load_libraries <- function(libraries) {
  for (i in libraries) {
    if (!requireNamespace(i, quietly = TRUE)) {
      install.packages(i)
    }
    library(i, character.only = TRUE)
  }
}
load_libraries(req_libraries)

# Retrieving press release from the web
news_url <- "https://www.edf.org/media/new-study-quantifies-health-impacts-oil-and-gas-flaring-us"

news <- read_html(news_url)

# Extracting title
title <- news %>% 
  html_nodes("h1") %>% 
  html_text2()

# Extracting date
date <- news %>% 
  html_nodes("time") %>% 
  html_text2()

# Extracting content
content <- news %>% 
  html_elements("div.page-body") %>%
  html_text2()

# Moving elements of press release into empty dataframe
df <- data.frame(title = character(), date = character(), content = character())
df <- data.frame(title = title, date = date, content = content)

# Tokenization by sentence
flaring_tokens_sent <- unnest_tokens(df, sent_tokens, content, token = "sentences")

# Sentiment analysis by sentence
sentimentr <- sentiment(flaring_tokens_sent$sent_tokens)
summary(sentimentr$sentiment)

# Merging sentiment score with sentence tokens
flaring_tokens_sent <- cbind(flaring_tokens_sent, sentimentr)

# Tokenization by word
flaring_tokens_word <- unnest_tokens(df, word_tokens, content, token = "words")

# Excluding "stop words"
flaring_tokens_word <- flaring_tokens_word %>% anti_join(stop_words, by = c("word_tokens" = "word"))

# Setting up sentiment lexicons dataframes
sentiment_afinn <- get_sentiments("afinn") %>% rename(afinn = value)
sentiment_nrc <- get_sentiments("nrc") %>% rename(nrc = sentiment)
sentiment_bing <- get_sentiments("bing") %>% rename(bing = sentiment)

# AFINN sentiment analysis
flaring_tokens_afinn <- flaring_tokens_word %>% left_join(sentiment_afinn, by = c("word_tokens" = "word"))

afinn_plot <- ggplot(data = filter(flaring_tokens_afinn, !is.na(afinn))) +
  geom_histogram(aes(afinn), stat = "count") +
  scale_x_continuous(n.breaks = 7) +
  labs(title = "Press Release Sentiment Analysis (AFINN)") + 
  labs(subtitle = "New study quantifies health impacts from oil and gas flaring in U.S.") +
  labs(x = "Sentiment Value", y = "Count")

afinn_plot

ggsave(afinn_plot, 
       filename = "afinn_plot.png",
       device = "png",
       width = 8)

# NRC sentiment analysis

flaring_tokens_nrc <- flaring_tokens_word %>% left_join(sentiment_nrc, by = c("word_tokens" = "word"))

nrc_plot <- ggplot(data = filter(flaring_tokens_nrc, !is.na(nrc))) +
  geom_histogram(aes(nrc), stat = "count") +
  scale_x_discrete(guide = guide_axis(angle = 45)) +
  labs(title = "Press Release Sentiment Analysis (NRC)") + 
  labs(subtitle = "New study quantifies health impacts from oil and gas flaring in U.S.") +
  labs(x = "Sentiment", y = "Count")

nrc_plot

ggsave(nrc_plot, 
       filename = "nrc_plot.png",
       device = "png",
       width = 8)

# Bing sentiment analysis

flaring_tokens_bing <- flaring_tokens_word %>% left_join(sentiment_bing, by = c("word_tokens" = "word"))

bing_plot <- ggplot(data = filter(flaring_tokens_bing, !is.na(bing))) +
  geom_histogram(aes(bing), stat = "count") +
  scale_x_discrete(guide = guide_axis(angle = 45)) +
  labs(title = "Press Release Sentiment Analysis (Bing)") + 
  labs(subtitle = "New study quantifies health impacts from oil and gas flaring in U.S.") +
  labs(x = "Sentiment", y = "Count")

bing_plot

ggsave(bing_plot, 
       filename = "bing_plot.png",
       device = "png",
       width = 8)
