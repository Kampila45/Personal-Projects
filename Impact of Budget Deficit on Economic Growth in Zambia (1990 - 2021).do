*CHECK WHETHER THE DATASET HAS MISSING VALUES*
mdesc
*REPLACING MISSING VALUES WITH THIER RESPECTIVE MEAN VALUES*
egen BudgetDeficit_mean=mean(BudgetDeficit)
replace BudgetDeficit=BudgetDeficit_mean if missing(BudgetDeficit)
egen StockofPublicDebt_mean=mean(StockofPublicDebt)
replace StockofPublicDebt=StockofPublicDebt_mean if missing(StockofPublicDebt)
*TRANSFORMING SOME VALUES TO LOG FORM FOR BETTER UNDERSTANDING*
gen log_TotalDebtService=log(TotalDebtService)
gen log_StockofPublicDebt=log(StockofPublicDebt)
gen BudgetDeficit1=BudgetDeficit+14
gen log_BudgetDeficit=log(BudgetDeficit1)
*DESCRIPITIVE STATISTICS*
summarize EconomicGrowth InflationRates log_TotalDebtService log_StockofPublicDebt BudgetDeficit
summarize EconomicGrowth InflationRates log_TotalDebtService log_StockofPublicDebt BudgetDeficit, detail
correlate EconomicGrowth InflationRates log_TotalDebtService log_StockofPublicDebt BudgetDeficit
*STATIONARITY TEST ADF*
tsset Years
dfuller EconomicGrowth
dfuller InflationRates
dfuller log_TotalDebtService
dfuller log_StockofPublicDebt
dfuller log_BudgetDeficit
dfuller d.EconomicGrowth
dfuller d.InflationRates
dfuller d.log_TotalDebtService
dfuller d.log_StockofPublicDebt
dfuller d.BudgetDeficit
*OPTIMAL LAG SELECTION*
br
tsset Date
varsoc EconomicGrowth InflationRates log_TotalDebtService log_StockofPublicDebt BudgetDeficit
*BOUNDS TEST*
varsoc EconomicGrowth
varsoc InflationRates  
varsoc log_TotalDebtService 
varsoc log_StockofPublicDebt
varsoc BudgetDeficit
ardl EconomicGrowth InflationRates log_TotalDebtService log_StockofPublicDebt BudgetDeficit, lags(1 0 0 0 0) ec btest
*ARDL MODEL*
ssc install ardl
ardl EconomicGrowth InflationRates log_TotalDebtService log_StockofPublicDebt BudgetDeficit, maxlags(2)
matrix list e(lags)
*THE LONG RUN*
ardl EconomicGrowth InflationRates log_TotalDebtService log_StockofPublicDebt BudgetDeficit, lags(1 0 0 0 0) aic
*THE SHORT RUN
ardl EconomicGrowth InflationRates log_TotalDebtService log_StockofPublicDebt BudgetDeficit, lags(1 1 1 1 1) aic
*BG SERIAL CORRELATION LM TEST*
regress EconomicGrowth InflationRates log_TotalDebtService log_StockofPublicDebt BudgetDeficit
estat bgodfrey, lag(2)
*DIAGNOSTIC TESTS*
*SERIAL CORRELATION*
estat bgodfrey, lags (1)
*HETEROSKEDASTICITY TEST*
regress EconomicGrowth InflationRates log_TotalDebtService log_StockofPublicDebt BudgetDeficit
hettest
*NORMALITY TEST*
regress EconomicGrowth InflationRates log_TotalDebtService log_StockofPublicDebt BudgetDeficit
sktest log_EconomicGrowth log_inflationRates log_TotalDebtService log_StockofPublicDebt BudgetDeficit
predict resid, r
*STABILITY TEST*
ssc install cusum6
cusum6 EconomicGrowth InflationRates log_TotalDebtService log_StockofPublicDebt BudgetDeficit ,cs(cusum) lw(lower) uw(upper)

