library(dplyr)
data(diamonds)

diamonds %>%
  filter(clarity %in% c("SI1", "SI2")) %>%
  group_by(color) %>%
  summarise(m_price = mean(price), sd_price = sd(price))

diamonds %>%
  filter(cut >= "Very Good") %>%
  group_by(color) %>%
  summarise(m_price = mean(price), sd_price = sd(price))


# note that dupree can't tell that the following code is logically
# the same as the preceding code
summarise(
  group_by(
    filter(diamonds, cut >= "Very Good"),
    color
  ),
  sd_price = sd(price),
  m_price = mean(price)
)
