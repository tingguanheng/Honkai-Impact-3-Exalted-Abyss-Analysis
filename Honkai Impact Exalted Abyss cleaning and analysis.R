library(tidyverse)
library(lubridate)
library(skimr)

###########################Cleaning from scratch##############################
### Extract excel data from all sheets
read_excel<- function(filename, tibble = FALSE){
  sheets<- readxl::excel_sheets(filename)
  x<- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
  x<- lapply(x, as.data.frame)
  names(x)<-sheets
  x
}

df<- read_excel("Exalted Abyss data.xlsx")
df1<- df$Data
df2<- df$`Major Milestone`
df3<- df$`Major Events`

## Import boss names from 'Exalted Abyss Dataset Variables' notepad
df4<- read.delim("Exalted Abyss Dataset Variables.txt")

### Extract boss names
boss_names<- as.data.frame(c(
  df4[(which(df4[,1] == "Last_Boss - Furthest Boss reached:")+1):
        (which(df4[,1] == "Final_Boss - Actual final Boss")-1),],
  df4[(which(df4[,1] == "Final_Boss - Actual final Boss")+1):
  (which(df4[,1] == "Rank:")-1),],
  df4[(which(df4[,1] == "Sub_boss:")+1):
  (which(df4[,1] == "Sub_dps:")-1),]))

colnames(boss_names)<- "names"
boss_names<- boss_names %>%
  separate(names,c("short_forms", "full_name"),sep = "-", extra = "merge")

boss_names$short_forms<- ifelse(boss_names$short_forms == "NMG",
                               "NMG-2",
                               boss_names$short_forms)
boss_names$full_name<- ifelse(boss_names$full_name == "2 - Nightmare Module G-2",
       "Nightmare Module G-2",
       boss_names$full_name)

boss_names<- as.data.frame(apply(boss_names,2,trimws))

### Extract character names
character_names<- as.data.frame(c(
  df4[(which(df4[,1] == "Main_dps - Main dps used:")+1):
        (which(df4[,1] == "Sub_weather:")-1),]))

colnames(character_names) <- "character_name"
character_names<- character_names %>% 
  separate(character_name,c("short_forms", "full_name"),sep = "-")

character_names<- as.data.frame(apply(character_names,2,trimws))

## replace acronyms with full names
df1<- df1 %>%
           left_join(boss_names, by= c("Last_Boss" = "short_forms")) %>%
           left_join(boss_names, by= c("Final_Boss" = "short_forms")) %>%
           left_join(character_names, by= c("Main_dps" = "short_forms")) %>%
           left_join(boss_names, by= c("Sub_boss" = "short_forms")) %>%
           left_join(character_names, by= c("Sub_dps" = "short_forms"))

df1<- df1 %>%
  transform(Last_Boss = coalesce(full_name.x,Last_Boss),
            Final_Boss = coalesce(full_name.y,Final_Boss),
            Main_dps = coalesce(full_name.x.x,Main_dps),
            Sub_boss = coalesce(full_name.y.y,Sub_boss),
            Sub_dps = coalesce(full_name,Sub_dps)) %>%
  select(-c(full_name.x:full_name)) %>%
  unique()

## Extract MSSQL cleaned data
df5<- read_csv("cleaned_data_files.csv")

## Check whether R and MSSQL cleaned data is correct
df1 == df5
### All of them are correct

###########################Further cleaning with R data (df1)#################
## As data were self-collected, I made sure no blanks were left. So no null
## values exists in this dataset.

## calculation check
df1<- df1 %>%
  mutate(calc_check = ifelse(lag(Final.Trophy) + as.numeric(Change) == 
                               Final.Trophy, 
                             TRUE,
                             Points + Change)) %>%
# No issues
 select(-calc_check)

## Placement of rank check
df1<- df1 %>%
  mutate(correct_rank = ifelse(Final.Trophy > 1500, "RL", "AG3")) %>%
  mutate(rank_check = ifelse(correct_rank == lead(Rank), TRUE, correct_rank)) %>%
##No issues  
  select(-correct_rank,-rank_check)

################################Analysis of dataset###########################
### Main objective: Maximise the probability of good outcomes in 
### Red Lotus (RL) rank

df1<- df1 %>%
  mutate(outcome = case_when(Rank == "AG3" & Change >0 ~ "Good",
                             Rank == "RL" & Change >= 0 ~ "Good",
                             Rank == "AG3" & Change <=0 ~ "Bad",
                             Rank == "RL" & Change < 0 ~ "Bad"))

skim_without_charts(df1)

## Do I need to complete all stages?
## I had a suspicion that I had to finish every stages to have a chance
## of a good outcome, the following test confirms this.

completion_test<- df1 %>%
  filter(Last_Boss != Final_Boss) %>%
  group_by(outcome, Rank) %>%
## Rank included to make sure RL and AG3 are separated 
  summarise(count = n()) %>%
  ungroup() %>%
  mutate(percentage = round(count/sum(count),2))

### With 92% of incomplete stage clearance end up in bad outcome, we can
### say that a fundamental requirement for good outcome is to clear all stages

## Do I need to use proper characters?
### As the game uses a rock-paper-scissors like mechanic, bosses can be
### cleared more efficiently if proper countering characters are used.
### I attempt to see whether I actually did that.

prop_char_test<- df1 %>%
  group_by(Weather, Final_Boss, Main_dps) %>%
  summarise(most_use = ifelse(n() == max(n()), Main_dps, NA),
            use_times = n()) %>%
  ungroup() %>%
  group_by(Weather,Final_Boss) %>%
  slice(1) %>%
  select(-Main_dps)
  ungroup()
  
### There are a few times where I used a character that does not fully
### counter the boss, we look at their win rates.
  
proper_char_win_rates<- df1 %>%
  filter((Weather == "Counter" &
           Final_Boss == "Shadow Knight" &
           Main_dps == "Herscherr of Thunder")|
           (Weather == "Ignited" &
              Final_Boss == "Argent Knight: Artemis" &
              Main_dps == "Herscherr of the Void")|
           (Weather == "Ignited" &
              Final_Boss == "Parvati" &
              Main_dps == "Herscherr of Sentience")|
           (Weather == "Lightning" &
              Final_Boss == "Durandal" &
              Main_dps == "Herscherr of Reason")|
           (Weather == "Physical" &
              Final_Boss == "JizoMitama" &
              Main_dps == "Herscherr of Sentience")|
           (Weather == "Quantum" &
              Final_Boss == "Couatl: Revenant" &
              Main_dps == "Herscherr of Sentience")) %>%
  group_by(outcome, Rank) %>%
  summarise(occurence = n()) %>%
  ungroup() %>%
  mutate(win_rate = round(occurence/sum(occurence),2))

### we can see that about 66% of inefficient counters ended up in bad outcomes
### in fact, even one of the bad outcomes came from Agony 3(AG3), which is
### unacceptable considering AG3 is very easy for my account.

### Hence, using correct characters that bosses are weak to is crucial in
### obtaining good outcomes.
## we can work on improving characters that can fight:
## Boss | Actual weakness 
# Shadow knight | Physical
# Argent Knight: Artemis | Fire
# Parvati | Fire 
# Durandal | Lightning
# JizoMitama | Physical 
# Couatl: Revenant | Quantum

## Does Disturbance level actually drives outcomes?

### While the higher the disturbance level, the harder the stages become,
### I have confidence that I have the skills to outscore my opponents even
### when the stage environment is tough.
### Time to see if that is true or not.

df1_for_model<- df1 %>%
  filter(Rank == "RL")

model1<- glm(as.factor(outcome) ~ Disturbance,
             data = df1_for_model,
             family = "binomial")
summary(model1)

## According to the model, the disturbance estimate is positive,
## which means that the higher the disturbance, the higher the chances of
## a good outcome. However, we should take it with a pinch of salt since
## the p-value is very large, meaning my skill level is unfortunately
## on par with average players.

## What is my current standing?
## I attempt to summarise my outcome rates over multiple bosses and weather.

win_rates<- df1 %>%
  group_by(Weather, Final_Boss, outcome) %>%
  summarise( counts = n()) %>%
  ungroup() %>%
  group_by(Weather, Final_Boss) %>%
  mutate(win_rate = round(counts/sum(counts),2)) %>%
  arrange(desc(outcome)) %>%
  slice(1) %>%
  transform(win_rate = ifelse(outcome == "Bad", 0, win_rate)) %>%
  ungroup() %>%
  select(-outcome, -counts)

ggplot(win_rates, aes(x= Weather, y = Final_Boss, fill = win_rate))+
  geom_tile()

## Unfortunately, heatmap is not useful in visualising here.
## There is a large variance in performance among weather and each bosses only
## appeared in one weather. Hence, it is difficult to see any clear trends here.

## I attempt to separate based on Abyss ranks
win_rates_by_rank<- df1 %>%
  group_by(Weather, Final_Boss, Rank, outcome) %>%
  summarise( counts = n()) %>%
  ungroup() %>%
  group_by(Weather, Final_Boss, Rank) %>%
  mutate(win_rate = round(counts/sum(counts),2)) %>%
  arrange(desc(outcome)) %>%
  slice(1) %>%
  transform(win_rate = ifelse(outcome == "Bad", 0, win_rate)) %>%
  ungroup() %>%
  select(-outcome, -counts)

ggplot(win_rates_by_rank, aes(x= Weather, y = Final_Boss, fill = win_rate))+
  geom_tile() +
  facet_wrap(~Rank)+
  theme(axis.text.x = element_text(angle = 45,
                                   hjust = 1))
## This heatmap is alot better because we can see smaller variance in results,
## allowing us to pinpoint which bosses under which weather needs to be worked
## on.

## However, new characters are frequently introduced to outclass every
## existing characters, hence we need to adjust for recency as well.
## To do that, we look at data since version 4.6 since that was the last time
## I made improvements to my account. I can use this analysis to plan what to
## improve in future versions.

recent_win_rates_by_rank<- df1 %>%
  filter(Version >= 4.6) %>%
  group_by(Weather, Final_Boss, Rank, outcome) %>%
  summarise( counts = n()) %>%
  ungroup() %>%
  group_by(Weather, Final_Boss, Rank) %>%
  mutate(win_rate = round(counts/sum(counts),2)) %>%
  arrange(desc(outcome)) %>%
  slice(1) %>%
  transform(win_rate = ifelse(outcome == "Bad", 0, win_rate)) %>%
  ungroup() %>%
  select(-outcome, -counts)

ggplot(recent_win_rates_by_rank, aes(x= Weather, y = Final_Boss, fill = win_rate))+
  geom_tile() +
  facet_wrap(~Rank)+
  theme(axis.text.x = element_text(angle = 45,
                                   hjust = 1))


## The following combinations had 0% win rate which will be my main focus.

## Boss | Featured weather
# Herscherr of Sentience | Counter
# Benares: Fire Form | Frost
# Durandal | Lightning
# Husk- Nihilius | Lightning

## These are the stages I should work towards.

##################End of Analysis for general viewers#######################

## Specific analysis on what to improve on
### From this point onwards, my analysis will be very technical and anyone
### who doesn't play Honkai Impact will not understand them.
### On the off-chance someone does play this game,I hope to impress them with
### the level of depth in my analysis.

## Why do I have 0% win rates?
### We investigate what characters I was using for those bosses.

hos_fights<- df1 %>%
  filter(Version >= 4.6, Final_Boss == "Herscherr of Sentience")

## Herscherr of Sentience is weak towards mecha types, which is what
## Herscherr of Reason (main_dps) is. In addition, Herscherr of Reason 
## is one of the strongest mecha characters in the game.
## Checking for gears,I have the best gear on Herscherr of Reason.

benares_fights<- df1 %>%
  filter(Version >= 4.6, Final_Boss == "Benares: Fire form")

## Benares: Fire Form is weak towards elemental types and since the weather
## favours ice types, Ice type characters makes most sense, which is what
## Herscherr of Reason (main_dps) is as well. Once again, she is the strongest
## ice type character and I have the best gear on her already.

durandal_fights<- df1 %>%
  filter(Version >= 4.6, Final_Boss == "Durandal")

## Durandal is weak towards lightning types, which is what Herscherr of Thunder
## (main_dps) is. The Herscherr of Thunder is also the strongest lightning
## character in the game, I have the best gear available for her as well.

nihilius_fights<- df1 %>%
  filter(Version >= 4.6, Final_Boss == "Husk-Nihilius")

## While the weather favour lightning type characters, I am personally unsure
## which characters players generally use against it. I have seen players use
## either Herscherr of Thunder or Darkbolt Jonin against it. It does
## not matter since I have the best gear available for both characters.

#############################Final Conclusion##############################

##### Importance of support characters
## After realising that my main damaging characters cannot be improved any 
## further, I turn my sights towards other characters. Since a fielded team 
## typically has three characters. The best way to optimise the team is to 
## have 1 main damage and 2 support characters.

## That was then I realised none of my support characters have their best gear
## on them. In addition, I do not have Azure Empyrea, which is the best 
## elemental support in the game. Consistent to my realization, I noticed all
## top players in the Red Lotus Abyss Rank have Azure Empyrea in their teams.

## Summary:
# To get good outcomes in Red Lotus Abyss:
# - All stages must be completed.
# - Characters used must be strong against featured bosses and weather.
# - A strong damage character is not enough, strong supports are required 
#   in the team as well.

## Henceforth, my priority to improve favourable outcomes in my account is:
# -Obtain Azure Empyrea
# -Complete all gears for support characters

