% Environmental Kuznets Curve - HP Filter Robustness Analysis
% Academic project | Econometric Theory
% Alternative treatment of trends using country-level HP filtering

clc;
clear;
close all;

%%
data = readtable("DATI MATLAB.xlsx");


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

%% SECOND ALTERNATIVE TREATMENT OF THE TREND



%% COMPUTING THE CYCLE OF THE VARIABLE WITH TREND EVIDENCES

lambda = 1600;  %generally used for annual data


%lco2
cycle_y = NaN(size(y));
trend_y = NaN(size(y));

for i = unique(id)'

    idx = (id == i);

    y_i = y(idx);
    time_i = time(idx);

    [time_i, ord] = sort(time_i);
    y_i = y_i(ord);

    trend_i = hpfilter(y_i, lambda);
    cycle_i = y_i - trend_i;

    pos = find(idx);
    pos = pos(ord);

    trend_y(pos) = trend_i;
    cycle_y(pos) = cycle_i;
end

%lgdp

log_gdp_pc= log(data.gdp_pc);

cycle_gdp = NaN(size(y));
trend_gdp = NaN(size(y));

for i = unique(id)'

    idx = (id == i);

    gdp_i = log_gdp_pc(idx);
    time_i = time(idx);

    [time_i, ord] = sort(time_i);
    gdp_i = gdp_i(ord);

    trend_i = hpfilter(gdp_i, lambda);
    cycle_i = gdp_i - trend_i;

    pos = find(idx);
    pos = pos(ord);

    trend_gdp(pos) = trend_i;
    cycle_gdp(pos) = cycle_i;
end

% elec_coal

cycle_elec_coal = NaN(size(y));
trend_elec_coal = NaN(size(y));

for i = unique(id)'

    idx = (id == i);

    elec_coal_i = data.elec_coal_pct(idx);
    time_i = time(idx);

    [time_i, ord] = sort(time_i);
    elec_coal_i = elec_coal_i(ord);

    trend_i = hpfilter(elec_coal_i, lambda);
    cycle_i = elec_coal_i - trend_i;

    pos = find(idx);
    pos = pos(ord);

    trend_elec_coal(pos) = trend_i;
    cycle_elec_coal(pos) = cycle_i;
end

%ren_en

cycle_ren_en = NaN(size(y));
trend_ren_en = NaN(size(y));

for i = unique(id)'

    idx = (id == i);

    ren_en_i = data.ren_en_pct(idx);
    time_i = time(idx);

    [time_i, ord] = sort(time_i);
    ren_en_i = ren_en_i(ord);

    trend_i = hpfilter(ren_en_i, lambda);
    cycle_i = ren_en_i - trend_i;

    pos = find(idx);
    pos = pos(ord);

    trend_ren_en(pos) = trend_i;
    cycle_ren_en(pos) = cycle_i;
end




% top_10_inc

cycle_top10_inc = NaN(size(y));
trend_top10_inc = NaN(size(y));

for i = unique(id)'

    idx = (id == i);

    top10_inc_i = data.top10_inc_pct(idx);
    time_i = time(idx);

    [time_i, ord] = sort(time_i);
    top10_inc_i = top10_inc_i(ord);

    trend_i = hpfilter(top10_inc_i, lambda);
    cycle_i = top10_inc_i - trend_i;

    pos = find(idx);
    pos = pos(ord);

    trend_top10_inc(pos) = trend_i;
    cycle_top10_inc(pos) = cycle_i;
end






%% CREATING THE DATASET, Y AND X
data_cycle = table(id, time, cycle_y, cycle_gdp, cycle_elec_coal, ...
    cycle_ren_en, cycle_top10_inc, ...
    'VariableNames', {'id','time','co2_pc_cycle','gdp_pc_cycle', ...
    'elec_coal_cycle','ren_en_cycle','top10_inc_cycle'});

y = data_cycle.co2_pc_cycle;
X = [ ...
    data_cycle.gdp_pc_cycle, ...
   data_cycle.elec_coal_cycle, ...
    data_cycle.ren_en_cycle, ...
    data.trade_gdp_pct, ...
    data_cycle.top10_inc_cycle ...
];
ynames_cycle = {'co2_pc_cycle'};
xnames_cycle = {'gdp_pc_cycle','elec_coal_cycle','ren_en_cycle','trade_gdp_pct',...
    'top10_inc_cycle'};



%% HP MODEL


% OLS with panel-clustered standard errors
regols_Panel_Robust = ols(y, X, 'vartype', 'cluster', 'clusterid', data_cycle.id);
regols_Panel_Robust.ynames = ynames_cycle;
regols_Panel_Robust.xnames = xnames_cycle;
estdisp(regols_Panel_Robust);



% Panel FE robust
regfer = panel(data_cycle.id, data_cycle.time, y, X, 'fe', 'vartype', 'robust');
regfer.ynames = ynames_cycle;
regfer.xnames = xnames_cycle;
estdisp(regfer);

ieff = ieffects(regfer);
ieffectsdisp(regfer);
