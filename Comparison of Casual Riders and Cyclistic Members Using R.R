## Case Study: How Does a Bike-Share Navigate Speedy Success
## The first step in this analysis is to gather all data for the past 12 months.
## The readr function in the tidyverse package is required. Hence , we install the package.
install.packages('tidyverse')
library('tidyverse')

## The trip data can then be inputed. In this case December 2020 to November 2021
trips_Dec2020 <- read_csv('202012-divvy-tripdata.csv')
trips_Jan2021 <- read_csv('202101-divvy-tripdata.csv')
trips_Feb2021 <- read_csv('202102-divvy-tripdata.csv')
trips_Mar2021 <- read_csv('202103-divvy-tripdata.csv')
trips_Apr2021 <- read_csv('202104-divvy-tripdata.csv')
trips_May2021 <- read_csv('202105-divvy-tripdata.csv')
trips_Jun2021 <- read_csv('202106-divvy-tripdata.csv')
trips_Jul2021 <- read_csv('202107-divvy-tripdata.csv')
trips_Aug2021 <- read_csv('202108-divvy-tripdata.csv')
trips_Sep2021 <- read_csv('202109-divvy-tripdata.csv')
trips_Oct2021 <- read_csv('202110-divvy-tripdata.csv')
trips_Nov2021 <- read_csv('202111-divvy-tripdata.csv')

## The data is then inspected to ensure uniformity before the data is binded into a single file.
## Data cleaning packages are installed and loaded.
install.packages('janitor')
library(janitor)

install.packages('skimr')
library(skimr)

## An inspection of the columns across the various monthly data is carried out.
compare_df_cols(trips_Dec2020,trips_Jan2021,trips_Feb2021,trips_Mar2021,trips_Apr2021,trips_May2021,trips_Jun2021, trips_Jul2021,trips_Aug2021,trips_Sep2021,trips_Oct2021,trips_Nov2021,return="mismatch")

## The compare columns functions confirms that the various columns contain the same datatypes hence they can be merged.
all_trips <- bind_rows(trips_Dec2020,trips_Jan2021,trips_Feb2021,trips_Mar2021,trips_Apr2021,trips_May2021,trips_Jun2021, trips_Jul2021,trips_Aug2021,trips_Sep2021,trips_Oct2021,trips_Nov2021)

all_trips <- rename(all_trips,usertype = member_casual, ride_type = rideable_type)

## A summary of the data can be viewed.
skim(all_trips)

## The skim summary indicates there are over 600,000 missing station names. The na.omit function is applied to display only complete rows.

library(tidyr)

all_trips_no_null <- na.omit(all_trips)

## We can calculate the length of each trip using the difftime function. This can be used for later anlysis. It can be observed that in some entries, the start time is greater than the end time. For this reason we add an abs() to display absolute values for trip length.

all_trips_no_null$trip_length <- abs(difftime(all_trips_no_null$ended_at, all_trips_no_null$started_at, unit="hours"))

head(all_trips_no_null)

## We can compare the total duration for trips by casual riders and members using a bar chart. This provides a basis for comparison.

library(ggplot2)

mytotal_summary <- aggregate(all_trips_no_null$trip_length, list(all_trips_no_null$usertype), FUN=sum)

view(mytotal_summary)

ggplot(mytotal_summary, aes(Group.1,x))+
	geom_bar(stat="identity",color="green",fill="green")

mycount_summary <- all_trips_no_null %>%
  count(usertype, sort = TRUE)

view(mycount_summary)

ggplot(mycount_summary, aes(usertype, n)) +
  geom_bar(stat = "identity",colour="blue",fill="blue")