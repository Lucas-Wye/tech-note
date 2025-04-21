= World-Brain Tutorial

`returns` is a data field that has the stock's returns for each company on each date.

`rank()` sorts the values within the input and represents them as evenly spaced values.

When backtesting an Alpha, profits and losses occur based on simulation results. We call the cumulative result over the backtest period `PnL` (Profit and Loss).

== Sharpe
While the amount of profit is important, how consistently you earn it is also an important evaluation factor for Alphas. Sharpe is the measure of risk adjusted returns earned by the alpha. Higher values of Sharpe are better. Sharpe is calculated as the annualized value (\*√250) of returns divided by their standard deviation: Sharpe = Avg. Annualized Returns / Annualized Std. Dev. of Returns

== Turnover

When creating an Alpha, positions change daily, and Turnover is the percentage of the capital which the alpha trades each day. More turnover may mean higher transaction costs during trading. the formula Value Traded / Value Held expresses this.

== Fitness

Fitness of an Alpha is a function of returns, turnover and Sharpe: Fitness=Sharpe \* Sqrt(Abs(Returns)) / Max(Turnover,0.125)

Good Alphas have high fitness. You can optimize the performance of your Alphas by increasing Sharpe (or returns) and reducing turnover. Improving one factor normally has an adverse impact on the other factor. As you work on optimizing your Alpha, an improvement in its fitness is a sign that your changes are having a positive impact.

== Returns

Returns indicates how much profit an Alpha can generate. Since BRAIN simulations assume a long-short portfolio (which we'll explain in the next step), The total investment amount equals half of the book size.

== Drawdown

Even with good Alpha performance, significant losses can occur during certain periods. Depending on market conditions, large losses might make it difficult to continue investing in that Alpha.

Drawdown represents the percentage of the largest loss incurred during any year in your backtesting. As a practice, you should target a return-to-drawdown ratio greater than one. The higher the ratio of returns to drawdown, the better it may be for your alpha.

== Margin

Margin represents how much PnL you obtained relative to the traded amount. It's calculated by dividing total PnL by the total traded amount. Note that Margin uses basis points (bps, ‱, or ten thousandths) as its unit of measurement, not %!

== Position

When starting a simulation, BRAIN calculates how much to invest in each stock by setting positions.

Positions consist mainly of long positions and short positions. In BRAIN, a long position means *buying stocks*, betting that the stock price will rise. Conversely, a short position means *selling stocks*, betting that the stock price will fall.

== Market Neutralization

Neutralization means removing specific influences from an Alpha. Since overall market movements often influence stock prices, having only long positions for many stocks carries a high risk of market exposure.

Therefore, BRAIN assumes the construction of a long-short portfolio where half the positions are long positions and the other half are short positions.

== Decay

Sometimes Alpha positions might change too much daily. For example, with `rank(-returns)`, if the Alpha's premise is true, all stocks' long and short positions need to change every day.

However, changing too many positions in one day can lead to issues with portfolio's stability. In such cases, we can slow down the rate of Alpha position changes through a method called `Decay`.

Decay means bringing forward a part of past positions to the present. When determining today's positions, it means applying a certain percentage of yesterday's or the day before's positions.
