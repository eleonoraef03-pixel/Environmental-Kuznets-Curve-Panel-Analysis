# Environmental Kuznets Curve: Panel Data Analysis in MATLAB

This repository contains MATLAB code developed for an **Econometric Theory** academic project examining the relationship between **CO₂ emissions per capita and GDP per capita** across **19 countries from 2000 to 2021**.

The project applies panel-data econometric techniques to study the Environmental Kuznets Curve (EKC) and to assess the robustness of the results under alternative treatments of common trends.

# Repository structure

# `01_main_analysis.m`
Main empirical analysis. The script:
- imports and structures the panel dataset;
- transforms key variables, including logarithmic transformations;
- calculates **Variance Inflation Factors (VIFs)** to assess multicollinearity;
- produces time-series and cross-sectional visualisations;
- estimates pooled OLS and **fixed-effects panel models** with robust/clustered standard errors;
- adds **time fixed effects** as an alternative treatment of common trends;
- investigates residual autocorrelation using correlograms and the **Ljung–Box test**;
- constructs a one-period lag of GDP and estimates a lagged specification;
- explores potential endogeneity using **instrumental-variable panel models**, the **Sargan overidentification test**, a **Durbin–Wu–Hausman-style control-function test**, and first-stage relevance tests;
- estimates both a standard and an adjusted **Environmental Kuznets Curve**, including calculation of the implied turning point.

# `02_hp_filter_analysis.m`
Alternative trend treatment using the **Hodrick–Prescott filter**. The script:
- separates selected variables into trend and cyclical components on a country-by-country basis;
- constructs a dataset using the cyclical components;
- estimates OLS and fixed-effects panel specifications on the detrended data.

# `03_first_differences_analysis.m`
Alternative trend treatment based on **first differences**. The script:
- computes within-country first differences for the dependent and explanatory variables;
- creates yearly summary statistics and visualisations of the differenced series;
- estimates OLS and fixed-effects panel models using first-differenced data.

## Data

The scripts expect an Excel file named:

```text
DATI MATLAB.xlsx
```

The dataset itself is **not included in this repository**. It contains annual country-level observations for the variables used in the project, including CO₂ emissions per capita, GDP per capita, electricity production from coal, renewable-energy consumption, trade, income concentration and selected variables used as candidate instruments.

# Main methods used

- Panel-data manipulation
- Data transformation and aggregation
- Data visualisation
- Multicollinearity diagnostics (VIF)
- Pooled OLS
- Individual fixed effects
- Time fixed effects
- Robust and clustered standard errors
- Residual autocorrelation diagnostics
- Lagged-variable construction
- Hodrick–Prescott filtering
- First-difference transformations
- Instrumental variables
- Sargan test
- Durbin–Wu–Hausman-style endogeneity testing
- First-stage relevance testing
- Environmental Kuznets Curve estimation

# Software

The analysis was written in **MATLAB**. In addition to standard MATLAB functionality, the scripts use panel-data/econometric functions such as `panel`, `ols`, `ivpanel`, `effectsftest`, `ieffects`, `sarganoitest` and related display functions. These functions must be available in the MATLAB environment for the scripts to run.

# Purpose

This repository is intended to document an academic application of MATLAB to **data management, visualisation and econometric analysis**. The code reflects the methodology implemented for the project and is provided primarily as a portfolio example of quantitative programming experience.
