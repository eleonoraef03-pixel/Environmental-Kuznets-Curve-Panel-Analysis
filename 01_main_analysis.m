% Environmental Kuznets Curve - Main Panel Data Analysis
% Academic project | Econometric Theory
% Main specification, diagnostics, IV analysis and EKC estimation

clc;
clear;
clear all;

%%
data = readtable('DATI MATLAB.xlsx');


%%
id = grp2idx(data.Country); %Transform countries (text) into numbers
time = data.Year;

y = log(data.co2_pc);

X = [ ...
    log(data.gdp_pc), ...
    data.elec_coal_pct, ...
    data.ren_en_pct, ...
    data.trade_gdp_pct, ...
    data.top10_inc_pct ...
];

ynames = {'co2_pc'};
xnames = {'gdp_pc','elec_coal_pct','ren_en_pct','trade_gdp_pct',['' ...
    'top10_inc_pct']};


%% DATA ANALYSIS

% Multicollinearity diagnosis
Xvif = X;
k = size(Xvif,2);
VIF = zeros(k,1);

for j = 1:k
    y_j = Xvif(:,j);
    X_j = Xvif(:,setdiff(1:k,j));
    
    mdl = fitlm(X_j,y_j);
    R2 = mdl.Rsquared.Ordinary;
    
    VIF(j) = 1/(1-R2);
end

disp(table(VIF,'RowNames',xnames))



%%


% GRAPHS to analyze the series

%Mean of CO2 and GDP per capita over time
mean_years = groupsummary(data, 'Year', 'mean', {'co2_pc','gdp_pc', 'elec_coal_pct','ren_en_pct','trade_gdp_pct', 'top10_inc_pct'}); 
%groupsummary is a function that group the countries every year and compute the mean of GDP and CO2 every year

figure;
plot(mean_years.Year, mean_years.mean_co2_pc, 'LineWidth', 1.5);
xlabel('Year');
ylabel('Average CO2 per capita');
title('Average CO2 per capita across countries over time');
grid on;

figure;
plot(mean_years.Year, mean_years.mean_gdp_pc, 'LineWidth', 1.5);
xlabel('Year');
ylabel('Average GDP per capita');
title('Average GDP per capita across countries over time');
grid on;

figure;
plot(mean_years.Year, mean_years.mean_elec_coal_pct, 'LineWidth', 1.5);
xlabel('Year');
ylabel('Average electricity production from coal sources (% of total)');
title('Average electricity production from coal sources across countries over time');
grid on;

figure;
plot(mean_years.Year, mean_years.mean_ren_en_pct, 'LineWidth', 1.5);
xlabel('Year');
ylabel('Average renewable energy consumption (% of total)');
title('Average renewable energy consumption across countries over time');
grid on;

figure;
plot(mean_years.Year, mean_years.mean_trade_gdp_pct, 'LineWidth', 1.5);
xlabel('Year');
ylabel('Average merchandise trade (% of GDP)');
title('Average merchandise trade (% of GDP) across countries over time');
grid on;

figure;
plot(mean_years.Year, mean_years.mean_top10_inc_pct, 'LineWidth', 1.5);
xlabel('Year');
ylabel('Average income share held by highest 10%');
title('Average  income share held by highest 10% over time');
grid on;

%graphical evidence of the presense of a trend in 'co2_pc','gdp_pc',
%'elec_coal_pct','ren_en_pct',top10_inc_pct for 'trade_gdp_pct'
% is less clear

% CO2 per country
countries = unique(data.Country, 'stable');
figure;
hold on;

for i = 1:length(countries)
    idx = strcmp(data.Country, countries{i});
    plot(data.Year(idx), data.co2_pc(idx), 'LineWidth', 1);

end

xlabel('Year');
ylabel('CO2 per capita');
title('CO2 per capita by country over time');
grid on;
legend(countries, 'Location', 'eastoutside');

%GDP per country

figure;
hold on;

for i = 1:length(countries)
    idx = strcmp(data.Country, countries{i});
    plot(data.Year(idx), data.gdp_pc(idx), 'LineWidth', 1);
end

xlabel('Year');
ylabel('GDP per capita');
title('GDP per capita by country over time');
grid on;
legend(countries, 'Location', 'eastoutside');


% Scatter plot for GDP and CO2

figure;
scatter(data.gdp_pc, data.co2_pc, 25, 'filled');
xlabel('GDP per capita');
ylabel('CO2 per capita');
title('Scatter plot of GDP per capita and CO2 per capita');
grid on;


% within country scatter plot --> we remove the mean
gdp_within = zeros(size(data.gdp_pc));
co2_within = zeros(size(data.co2_pc));

for i = 1:length(countries)
    idx = strcmp(data.Country, countries{i});
    
    gdp_mean_i = mean(data.gdp_pc(idx));
    co2_mean_i = mean(data.co2_pc(idx));
    
    gdp_within(idx) = data.gdp_pc(idx) - gdp_mean_i;
    co2_within(idx) = data.co2_pc(idx) - co2_mean_i;
end

figure;
scatter(gdp_within, co2_within, 20, 'filled');
hold on;


xlabel('GDP per capita demeaned');
ylabel('CO2 per capita demeaned');
title('Within-country relationship between GDP and CO2');
grid on;
hold off;





%% MAIN MODEL

% OLS with Panel Robust Standard Errors
regols_Panel_Robust = ols(y,X,'vartype','cluster','clusterid',id);
regols_Panel_Robust.ynames = ynames;
regols_Panel_Robust.xnames = xnames;
estdisp(regols_Panel_Robust);


% Panel FE
regfe = panel(id,time,y, X, 'fe');
regfe.ynames = ynames;
regfe.xnames = xnames;
estdisp(regfe);

% F test of inividual effects
effF = effectsftest(regfe);
testdisp(effF);

% Panel FE Robust
regfer = panel(id,time,y, X, 'fe', 'vartype','robust');
regfer.ynames = ynames;
regfer.xnames = xnames;
estdisp(regfer);





%% FIRST ALTERNATIVE TREATMENT OF THE TREND
%  Time and inidividual FE
% Panel Joint Time and Individual FE (Columns time fixed effects (7-8) Table 11.5)
years_categorical = categorical(time);
D_year = dummyvar(years_categorical);

regfe_ind_time = panel(id,time,y,[X, D_year(:,1:end-1)],'fe');
regfe_ind_time.ynames = ynames;
regfe_ind_time.xnames = [xnames, ...
    {'2000','2001','2002','2003','2004','2005','2006','2007','2008', ...
     '2009','2010','2011','2012','2013','2014','2015','2016','2017', ...
     '2018','2019','2020'}];

estdisp(regfe_ind_time);

ieff_ind_time = ieffects(regfe_ind_time);
ieffectsdisp(regfe_ind_time);







%% AUTOCORRELATION DIAGNOSIS

% Correlogram model with fixed effect
for i = unique(id)'
    idx = (id == i);
    res_i = regfer.res(idx);
    
    figure
    autocorr(res_i)
    title(['Residual correlogram - country - Fixed effect model ', num2str(i)])
end


% Correlogram model with fixed effect and time fixed effect
for i = unique(id)'
    idx = (id == i);
    res_i = regfe_ind_time.res(idx);
    
    figure
    autocorr(res_i)
    title(['Residual correlogram - country- FE + Time Fixed Effect ', num2str(i)])
end

%%

% LJUNG-BOX TEST FOR AUTOCORRELATION

res_fe = regfer.res;

lags = [1];   % We only analyze the first lag

for i = unique(id)'

    idx = (id == i);

    res_i = res_fe(idx);
    time_i = time(idx);

    % sort residuals by year
    [time_i, ord] = sort(time_i);
    res_i = res_i(ord);

    % Ljung-Box test
    [h,p,Qstat,crit] = lbqtest(res_i,'Lags',lags);

    disp(' ')
    disp(['Country ID: ', num2str(i)])
    disp(table(lags', h', p', Qstat', crit', ...
        'VariableNames', {'Lag','Reject_H0','p_value','Qstat','Critical_Value'}))

end


%% MODEL WITH A GDP LAG

% Computing the lag
lGDP = log(data.gdp_pc);
lag_lGDP = NaN(size(lGDP));

for i = unique(id)'
    
    idx = (id == i);
    
    gdp_i = lGDP(idx);
    time_i = time(idx);
    
    [time_i, ord] = sort(time_i);
    gdp_i = gdp_i(ord);
    
    lag_i = [NaN; gdp_i(1:end-1)];
    
    pos = find(idx);
    pos = pos(ord);
    
    lag_lGDP(pos) = lag_i;
end

Xvif_2= [log(data.gdp_pc), lag_lGDP];
k_2 = size(Xvif_2,2);
VIF_2 = zeros(k_2,1);

for j = 1:k_2
    y_j_2 = Xvif_2(:,j);
    X_j_2 = Xvif_2(:,setdiff(1:k_2,j));
    
    mdl_2 = fitlm(X_j_2,y_j_2);
    R2_2 = mdl_2.Rsquared.Ordinary;
    
    VIF_2(j) = 1/(1-R2_2);
end

disp(table(VIF_2))


% MODEL LAG
X2 = [ ...
    lag_lGDP, ...
    data.elec_coal_pct, ...
    data.ren_en_pct, ...
    data.trade_gdp_pct, ...
    data.top10_inc_pct ...
];

ynames_lag = {'co2_pc'};
xnames_lag = {'gdp_pc','elec_coal_pct','ren_en_pct','trade_gdp_pct',['' ...
    'top10_inc_pct']};

% We keep only complete observations
valid_lag = ~isnan(y) & all(~isnan(X2),2);

y_lag = y(valid_lag);
X2_lag = X2(valid_lag,:);
id_lag = id(valid_lag);
time_lag = time(valid_lag);

% Panel FE
regfe_lag = panel(id_lag, time_lag, y_lag, X2_lag, 'fe');
regfe_lag.ynames = ynames_lag;
regfe_lag.xnames = xnames_lag;
estdisp(regfe_lag);

ieff_lag = ieffects(regfe_lag);
ieffectsdisp(regfe_lag);

% F test of individual effects
effF_lag = effectsftest(regfe_lag);
testdisp(effF_lag);

% Panel FE Robust
regfer_lag = panel(id_lag, time_lag, y_lag, X2_lag, 'fe', 'vartype','robust');
regfer_lag.ynames = ynames_lag;
regfer_lag.xnames = xnames_lag;
estdisp(regfer_lag);

ieff_lag_r = ieffects(regfer_lag);
ieffectsdisp(regfer_lag);




%% ENDOGENEITY 

%EXTERNAL VARIABLES IV

%first trial
Z3 = [
    data.av_y_schooling,...
    data.g_capital_form_pc, ...
    data.crude_oil_prices
];

ivfe3 = ivpanel(id,time,y,X,Z3,'fe','endog',[1 2]);

estdisp(ivfe3);

%test
sargan3 = sarganoitest(ivfe3);
testdisp(sargan3);
%WE Cant' REJECT H0 --> INSTRUMENTS AREN'T CORRELATED WITH THE ERROR SO THE
%FUNDAMENTAL ASSUMPTION OF IV IS NOT VIOLATED

%second trial
Z4 = [
    data.av_y_schooling,...
    data.r_gdp_growth, ...
    data.crude_oil_prices
];

ivfe4 = ivpanel(id,time,y,X,Z4,'fe','endog',[1 2]);

estdisp(ivfe4);

%test
sargan4 = sarganoitest(ivfe4);
testdisp(sargan4);
%%

% DWH test 

X1 = X(:,3:end);          % exogenous variables
Zfull = [X1, Z3];         % full instruments: exogenous variables + instruments

% first stage regressions
fs_1 = panel(id,time,X(:,1),Zfull,'fe','vartype','robust');   % for log(gdp_pc)
fs_2 = panel(id,time,X(:,2),Zfull,'fe','vartype','robust');   % for elec_coal_pct

% first stage residuals
res_1 = fs_1.res;
res_2 = fs_2.res;

% structural equation + residuals
reg_DWH = panel(id,time,y,[X res_1 res_2],'fe','vartype','robust');

% joint test H0: coeff(r1)=coeff(r2)=0
beta_DWH = reg_DWH.coef;
V = reg_DWH.varcoef;

R = [0 0 0 0 0 1 0;
     0 0 0 0 0 0 1];

W = (R*beta_DWH)' * inv(R*V*R') * (R*beta_DWH);
p_value = 1 - chi2cdf(W,2);

disp(['DWH p-value = ', num2str(p_value)])



% FIRST STAGE TEST FOR IV ON THE FIRST ATTEMPT


q = size(Z3,2);
k_fs = size(Zfull,2);

% Test only the excluded instruments
R_fs = [ ...
    0 0 0 1 0 0;
    0 0 0 0 1 0;
    0 0 0 0 0 1
];


% First stage test for log(gdp_pc)

b_fs1 = fs_1.coef;
V_fs1 = fs_1.varcoef;

W_fs1 = (R_fs*b_fs1)' * inv(R_fs*V_fs1*R_fs') * (R_fs*b_fs1);
p_fs1 = 1 - chi2cdf(W_fs1,q);
F_fs1 = W_fs1/q;

disp(' ')
disp('FIRST STAGE TEST FOR log(gdp_pc)')
disp(['Wald chi2 = ', num2str(W_fs1)])
disp(['Approx. first-stage F = ', num2str(F_fs1)])
disp(['p-value = ', num2str(p_fs1)])

% First stage test for elec_coal_pct

b_fs2 = fs_2.coef;
V_fs2 = fs_2.varcoef;

W_fs2 = (R_fs*b_fs2)' * pinv(R_fs*V_fs2*R_fs') * (R_fs*b_fs2);
p_fs2 = 1 - chi2cdf(W_fs2,q);
F_fs2 = W_fs2/q;

disp(' ')
disp('FIRST STAGE TEST FOR elec_coal_pct')
disp(['Wald chi2 = ', num2str(W_fs2)])
disp(['Approx. first-stage F = ', num2str(F_fs2)])
disp(['p-value = ', num2str(p_fs2)])


%% EMPIRICAL TEST OF THE EKC

%Standard form of the EKC
co2_pc = data.co2_pc;
gdp_pc = data.gdp_pc;

valid = co2_pc > 0 & gdp_pc > 0 & ~isnan(co2_pc) & ~isnan(gdp_pc);

id = id(valid);
time = time(valid);
co2_pc = co2_pc(valid);
gdp_pc = gdp_pc(valid);


lco2 = log(co2_pc);
lgdp = log(gdp_pc);
lgdp2 = lgdp.^2;

y_EKC = lco2;
X_EKC = [lgdp, lgdp2];

regfe_EKC = panel(id, time, y_EKC, X_EKC, 'fe', 'vartype', 'robust');

regfe_EKC.ynames = {'ln_co2_pc'};
regfe_EKC.xnames = {'ln_gdp_pc', 'ln_gdp_pc_sq'};

estdisp(regfe_EKC);

%turning point 
b = regfe_EKC.coef;
b1 = b(1);
b2 = b(2);

tp_log = -b1/(2*b2);
tp_gdp = exp(tp_log);

disp('Turning point in log:')
disp(tp_log)

disp('Turning point in GDP pro capite:')
disp(tp_gdp)

disp('Min GDP per capita:')
disp(min(gdp_pc))

disp('Max GDP per capita:')
disp(max(gdp_pc))

%%
% OUR adjusted EKC
coal = data.elec_coal_pct;
ren = data.ren_en_pct;
trade = data.trade_gdp_pct;
top10 = data.top10_inc_pct;


coal = coal(valid);
ren = ren(valid);
trade = trade(valid);
top10 = top10(valid);


y_EKC = lco2;
X_EKC = [lgdp, lgdp2, coal, ren, trade, top10];

regfe_EKC_adj = panel(id, time, y_EKC, X_EKC, 'fe', 'vartype', 'robust');

regfe_EKC_adj.ynames = {'ln_co2_pc'};
regfe_EKC_adj.xnames = {'ln_gdp_pc', 'ln_gdp_pc_sq', ...
                    'elec_coal_pct', 'ren_en_pct', ...
                    'trade_gdp_pct', 'top10_inc_pct'};

estdisp(regfe_EKC_adj);

%turning point
b_adj = regfe_EKC_adj.coef;
b1_adj = b_adj(1);
b2_adj = b_adj(2);

tp_log_adj = -b1_adj/(2*b2_adj);
tp_gdp_adj = exp(tp_log_adj);

disp('Turning point in log:')
disp(tp_log_adj)

disp('Turning point in GDP pro capite:')
disp(tp_gdp_adj)

disp('Min GDP per capita:')
disp(min(gdp_pc))

disp('Max GDP per capita:')
disp(max(gdp_pc))