# Bayesian-NBA-Player-Peak-Analysis

How much does a players Draft Position and College have an effect on their productivity in the league? For my project I'll fit an Bayesian Regression model on a players top 3 peak BPM years on different factors including: 

- Age entering League
- League they played before NBA
- League difficulty 
- Draft position

Due to some data sparsity in some leagues in my dataset I grouped the leagues into the following:

| Group | Leagues |
| :--------- | :------: |
| Top D1 | Top D1 US confrences (ACC, SEC, Big 10, Big 12, Big East) |
| Other D1 | remaining D1 US confrences |
| Developmental League | G League, International Prep, Overtime Elite |
| Europe Elite | Any team with in Euroleague (top European tournament)|
| Spain Top | Liga ACB |
| France Top | LNB Pro A |
| Eastern Europe Top | ABA |
| Other Europe Top | Serie A, Bundesliga, Super Ligi |
| Other Europe Lower | Primera FEB, Serie B, Nationale Masculine 1, LNB Pro B |
| Australian Top | NBL |
| High School | All HS US |
| South America | NBB, LUB |
| Other | CBA, Premier League, JUCO, Super League 1, VTB |

League difficulty was an artibray measure that I set but these were the final rankings I set:

| League | Rank |
| :--------- | :------: |
| Europe Elite | 1 |
| Spain | 2 |
| Top D1 | 3 |
| Australia Top | 4 |
| Other D1 | 5 |
| Other Top Europe | 6 |
| France Top | 7 |
| Eastern Europe Top | 8 |
| South America | 9 |
| Developmental League | 10 |
| Other | 11 |
| Other Europe Lower | 12 |
| High School | 13 |

These BPMs where then grouped into 8 Tiers with the following cut offs:

- All Time Great: 10 >
- MVP: 7.5 - 10
- All-NBA: 5 - 7.5
- All-Star: 3.7 - 5
- Good Starter: 2 - 3.7
- Role Player: 0 - 2
- Replacement Level: -2 - 0
- Benchwarmer: -2 <

These cut offs were inspired by the Basketball Reference resource page but were fine tuned to my data to make sense.

These posterior distrubtions will allow us to see which leagues are best at developing productive NBA players. In addition, we can see how much draft position affects your potential productivity as well as how much they are able to match those draft day expectations.

For my dataset I analysed players who played more than 250 minutes in a season over the last 10 years. This did lead to a heavy bias in high school players which you'll be able to see in our data analysis. This is due to high school players non longer being able to be draft eligible in the early 2000's making any high schooler that lasted till my 2015 cut off to be an elite/highly productive NBA player. 