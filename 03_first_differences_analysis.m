% Environmental Kuznets Curve - First-Difference Robustness Analysis
% Academic project | Econometric Theory
% Alternative treatment of trends using within-country first differences

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







%% THIRD ALTERNATIVE TREATMENT OF THE TREND


%% COMPUTING FIRST DIFFERECES WITHIN COUNTRY

y_fd = [];
X_fd = [];
id_fd = [];
time_fd = [];

for i = unique(id)'
    idx = (id == i);
    
    y_i = y(idx);
    X_i = X(idx,:);
    t_i = time(idx);
    
    y_fd_i = y_i(2:end)-y_i(1:end-1); 
    X_fd_i = X_i(2:end,:) - X_i(1:end-1,:);
    time_i = t_i(2:end);   % year associated with the differenced obs
    
    y_fd = [y_fd; y_fd_i];
    X_fd = [X_fd; X_fd_i];
    id_fd = [id_fd; repmat(i, length(y_fd_i), 1)];
    time_fd = [time_fd; time_i];
end




%% GRAPHS OF FIRST DIFFERENCES

% Creating a dataset with first differences
data_fd = table(time_fd, y_fd, X_fd(:,1), ...
    'VariableNames', {'Year','d_co2_pc','d_gdp_pc'});

% Compute yearly means
mean_fd_years = groupsummary(data_fd, 'Year', 'mean', {'d_co2_pc','d_gdp_pc'});

% Plot mean first difference of CO2
figure;
plot(mean_fd_years.Year, mean_fd_years.mean_d_co2_pc, '-o', 'LineWidth', 1.5);
yline(0,'--');
xlabel('Year');
ylabel('Average \Delta CO2 per capita');
title('Average first difference of CO2 per capita across countries over time');
grid on;

% Plot mean first difference of GDP
figure;
plot(mean_fd_years.Year, mean_fd_years.mean_d_gdp_pc, '-o', 'LineWidth', 1.5);
yline(0,'--');
xlabel('Year');
ylabel('Average \Delta GDP per capita');
title('Average first difference of GDP per capita across countries over time');
grid on;




%% FD MODEL

% OLS with Panel Robust Standard Errors
regols_Panel_Robust = ols(y_fd,X_fd,'vartype','cluster','clusterid',id_fd);
regols_Panel_Robust.ynames = ynames;
regols_Panel_Robust.xnames = xnames;
estdisp(regols_Panel_Robust);
%
% Panel FE
regfe = panel(id_fd,time_fd,y_fd,X_fd, 'fe');
regfe.ynames = ynames;
regfe.xnames = xnames;
estdisp(regfe);
ieff = ieffects(regfe);
ieffectsdisp(regfe);

% F test of inividual effects
effF = effectsftest(regfe);
testdisp(effF);

% Panel FE Robust
regfer = panel(id_fd,time_fd,y_fd,X_fd, 'fe', 'vartype','robust');
regfer.ynames = ynames;
regfer.xnames = xnames;
estdisp(regfer);
ieff = ieffects(regfer);
ieffectsdisp(regfer);
