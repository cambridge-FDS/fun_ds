% This file plots results and calculates counterfactuals

clear;
re_calculate = false;

% set parameters (09.02.)
load params_opt_oct22
parameters = params_opt_oct22;
%parameters = [3.61671064220012,0.754103701618642,3.53128743671852,0.865660611197004,0.390267054537713,0.0320279611792786,0.00470436237611633,0.0224024203431750,0.00719206391079619,0.0230848814525315,0.00493610470630902,0.0236416485949909,0.00194485654465254,0.0599256118677681,0.0838632354907831];
counterfactual = [1 1]; % [community support, afterlife]; 1: on, 0: off;

%%
% calculate inner main and moments
if re_calculate == true
    [model_moments_baseline, S, params] = inner_main_analysis(parameters, counterfactual);
    save S_baseline S
    save model_moments_baseline
else
    load S_baseline S
    load model_moments_baseline
    S_baseline = S;
end
%% Plot results

T = S{1,1};

figure('Renderer', 'painters', 'Position', [10 10 900 800])
color_old = '#e41a1c';
color_mid = '#377eb8';
color_young = '#4daf4a';
color_old = '#86162a';
color_mid = '#172f5f';
color_young = '#EB811B';
subplot(3,2,1);
plot(params.amat, T.pol_o(1:2:end,1),'Color',color_old, 'LineWidth',1)
hold on
plot(params.amat, T.pol_o(2:2:end,1), 'Color',color_old, 'LineStyle','--','LineWidth',1)
hold on
plot(params.amat, T.pol_m(1:2:end,1),'Color',color_mid, 'LineStyle','-','LineWidth',1)
hold on
plot(params.amat, T.pol_m(2:2:end,1), 'Color',color_mid, 'LineStyle','--','LineWidth',1)
hold on
plot(params.amat, T.pol_y(1:2:end,1), 'Color',color_young, 'LineStyle','-','LineWidth',1)
hold on
plot(params.amat, T.pol_y(2:2:end,1),'Color',color_young, 'LineStyle','--','LineWidth',1)
title('Savings')
set(gca,'FontSize',12,'fontname','times')

subplot(3,2,2);
plot(params.amat, T.pol_o(1:2:end,2),'Color',color_old,'LineWidth',1)
hold on
plot(params.amat, T.pol_o(2:2:end,2), 'Color',color_old, 'LineStyle','--','LineWidth',1)
hold on
plot(params.amat, T.pol_m(1:2:end,2),'Color',color_mid, 'LineStyle','-','LineWidth',1)
hold on
plot(params.amat, T.pol_m(2:2:end,2), 'Color',color_mid, 'LineStyle','--','LineWidth',1)
hold on
plot(params.amat, T.pol_y(1:2:end,2), 'Color',color_young, 'LineStyle','-','LineWidth',1)
hold on
plot(params.amat, T.pol_y(2:2:end,2),'Color',color_young, 'LineStyle','--','LineWidth',1)
title('Donations')
set(gca,'FontSize',12,'fontname','times')
% 
subplot(3,2,3);
plot(params.amat, T.pol_o(1:2:end,3),'Color',color_old,'LineWidth',1)
hold on
plot(params.amat, T.pol_o(2:2:end,3), 'Color',color_old, 'LineStyle','--','LineWidth',1)
hold on
plot(params.amat, T.pol_m(1:2:end,3),'Color',color_mid, 'LineStyle','-','LineWidth',1)
hold on
plot(params.amat, T.pol_m(2:2:end,3), 'Color',color_mid, 'LineStyle','--','LineWidth',1)
hold on
plot(params.amat, T.pol_y(1:2:end,3), 'Color',color_young, 'LineStyle','-','LineWidth',1)
hold on
plot(params.amat, T.pol_y(2:2:end,3),'Color',color_young, 'LineStyle','--','LineWidth',1)
title('Leisure')
set(gca,'FontSize',12,'fontname','times')


subplot(3,2,4);
plot(params.amat, T.pol_o(1:2:end,4),'Color',color_old,'LineWidth',1)
hold on
plot(params.amat, T.pol_o(2:2:end,4), 'Color',color_old, 'LineStyle','--','LineWidth',1)
hold on
plot(params.amat, T.pol_m(1:2:end,4),'Color',color_mid, 'LineStyle','-','LineWidth',1)
hold on
plot(params.amat, T.pol_m(2:2:end,4), 'Color',color_mid, 'LineStyle','--','LineWidth',1)
hold on
plot(params.amat, T.pol_y(1:2:end,4), 'Color',color_young, 'LineStyle','-','LineWidth',1)
hold on
plot(params.amat, T.pol_y(2:2:end,4),'Color',color_young, 'LineStyle','--','LineWidth',1)
title('Pray time')
set(gca,'FontSize',12,'fontname','times')
%
subplot(3,2,5);
plot(params.amat, T.pol_o(1:2:end,5),'Color',color_old,'LineWidth',1)
hold on
plot(params.amat, T.pol_o(2:2:end,5), 'Color',color_old, 'LineStyle','--','LineWidth',1)
hold on
plot(params.amat, T.pol_m(1:2:end,5),'Color',color_mid, 'LineStyle','-','LineWidth',1)
hold on
plot(params.amat, T.pol_m(2:2:end,5), 'Color',color_mid, 'LineStyle','--','LineWidth',1)
hold on
plot(params.amat, T.pol_y(1:2:end,5), 'Color',color_young, 'LineStyle','-','LineWidth',1)
hold on
plot(params.amat, T.pol_y(2:2:end,5),'Color',color_young, 'LineStyle','--','LineWidth',1)
title('Time community')
xlabel('Assets')
set(gca,'FontSize',12,'fontname','times')

subplot(3,2,6);
plot(params.amat, T.pol_o(1:2:end,6),'Color',color_old,'LineWidth',1)
hold on
plot(params.amat, T.pol_o(2:2:end,6), 'Color',color_old, 'LineStyle','--','LineWidth',1)
hold on
plot(params.amat, T.pol_m(1:2:end,6),'Color',color_mid, 'LineStyle','-','LineWidth',1)
hold on
plot(params.amat, T.pol_m(2:2:end,6), 'Color',color_mid, 'LineStyle','--','LineWidth',1)
hold on
plot(params.amat, T.pol_y(1:2:end,6), 'Color',color_young, 'LineStyle','-','LineWidth',1)
hold on
plot(params.amat, T.pol_y(2:2:end,6),'Color',color_young, 'LineStyle','--','LineWidth',1)
title('Consumption')
xlabel('Assets')
set(gca,'FontSize',12,'fontname','times')

legend('old, unemployed', 'old, employed', 'mid, unemployed', 'mid, employed', 'young, unemployed', 'young, employed','Location','SouthEast')
            
export_fig policy_functions -pdf -transparent 

% averages of policies
pol_o_bar = mean(T.pol_o,1);
pol_m_bar = mean(T.pol_m,1);
pol_y_bar = mean(T.pol_y,1);
policies = zeros(3,length(pol_o_bar));
policies(1,:) = pol_y_bar;
policies(2,:) = pol_m_bar;
policies(3,:) = pol_o_bar;
T = array2table(policies,'VariableNames',{'Savings','Donations','Leisure','Pray','Time','Consumption'})


%% Counter-factual 1: no community support
counterfactual = [0 1]; % [community support, afterlife]; 1: on, 0: off;

if re_calculate == true
% calculate inner main and moments
    [model_moments_nosupport, S, params] = inner_main_analysis(parameters, counterfactual);
    save S_no_cs S
    save model_moments_nosupport
else
    load S_no_cs S
    load model_moments_nosupport
    S_no_cs = S;
end
%% Counter-factual 2: no after-life
counterfactual = [1 0]; % [community support, afterlife]; 1: on, 0: off;

if re_calculate == true
% calculate inner main and moments
[model_moments_noafterlife, S, params] = inner_main_analysis(parameters, counterfactual);
    save S_no_afterlife S
    save model_moments_noafterlife
else
    load S_no_afterlife S
    load model_moments_noafterlife
    S_no_afterlife = S;
end
%% Counter-factual 3: no community support, no after-life
counterfactual = [0 0]; % [community support, afterlife]; 1: on, 0: off;

% calculate inner main and moments
[model_moments_nosupport_noafterlife, S, params] = inner_main_analysis(parameters, counterfactual);


%% Calculate extra moments given S
%S = S_baseline;
moments = moments_analysis(S,params.amat,parameters);

%% Sensitivity analysis

% Sensitivity in terms of V_heaven
V_heaven = linspace(0,4,6);
d_avg = zeros(length(V_heaven),1);
t_avg = zeros(length(V_heaven),1);
p_avg = zeros(length(V_heaven),1);

for i = 1:length(V_heaven)
    parameters(3) = V_heaven(i);
    counterfactual = [1 1];
    model_moments = inner_main_analysis(parameters,counterfactual);
    
    d_avg(i) = model_moments(1);
    t_avg(i) = model_moments(12);
    p_avg(i) = model_moments(23);
    
end

figure;
color_d = '#86162a';
color_t = '#172f5f';
color_p = '#EB811B';
%opengl software
plot(V_heaven, d_avg,'DisplayName','d_{avg}','Color',color_d,'LineWidth',1)
hold on
plot(V_heaven, t_avg,'DisplayName','t_{avg}','Color',color_t,'LineWidth',1)
hold on
plot(V_heaven, p_avg,'DisplayName','p_{avg}','Color',color_p,'LineWidth',1)
xline(3.5,'--','Calibration','LabelVerticalAlignment','bottom','LineWidth',1,'fontname','times','HandleVisibility','off')
legend('Location','northwest')
xlabel("Value of heaven")
set(gca,'FontSize',12,'fontname','times')
export_fig sensitivity_v_heaven -pdf -transparent 
%%
% Sensitivity in terms of efefctiveness of CS
%parameters = [3.61671064220012,0.754103701618642,3.53128743671852,0.865660611197004,0.390267054537713,0.0320279611792786,0.00470436237611633,0.0224024203431750,0.00719206391079619,0.0230848814525315,0.00493610470630902,0.0236416485949909,0.00194485654465254,0.0599256118677681,0.0838632354907831];
parameters(3) = 0;
CS_factor = linspace(0,6,8);
d_avg = zeros(length(CS_factor),1);
t_avg = zeros(length(CS_factor),1);
p_avg = zeros(length(CS_factor),1);

for i = 1:length(CS_factor)
    counterfactual = [CS_factor(i) 1];
    model_moments = inner_main_analysis(parameters,counterfactual);
    
    d_avg(i) = model_moments(1);
    t_avg(i) = model_moments(12);
    p_avg(i) = model_moments(23);
    
end

figure;
opengl software
color_d = '#86162a';
color_t = '#172f5f';
color_p = '#EB811B';
plot(CS_factor, d_avg,'DisplayName','d_{avg}','Color',color_d,'LineWidth',1)
hold on
plot(CS_factor, t_avg,'DisplayName','t_{avg}','Color',color_t,'LineWidth',1)
hold on
plot(CS_factor, p_avg,'DisplayName','p_{avg}','Color',color_p,'LineWidth',1)
xline(1,'--','Calibration','LabelVerticalAlignment','top','LineWidth',1,'fontname','times','HandleVisibility','off')
legend('Location','southeast')
xlabel("Scale effectiveness of community support")
set(gca,'FontSize',12,'fontname','times')
export_fig sensitivity_cs_v_heaven_0 -pdf -transparent 

%% Sensitivity in terms of psi
parameters = [3.61671064220012,0.754103701618642,3.53128743671852,0.865660611197004,0.390267054537713,0.0320279611792786,0.00470436237611633,0.0224024203431750,0.00719206391079619,0.0230848814525315,0.00493610470630902,0.0236416485949909,0.00194485654465254,0.0599256118677681,0.0838632354907831];
counterfactual = [1 1]; % [community support, afterlife]; 1: on, 0: off;

psi = linspace(0.5,2.5,6);
d_avg = zeros(length(psi),1);
t_avg = zeros(length(psi),1);
p_avg = zeros(length(psi),1);

for i = 1:length(psi)
    parameters(2) = psi(i);
    counterfactual = [1 1];
    model_moments = inner_main_analysis(parameters,counterfactual);
    
    d_avg(i) = model_moments(1);
    t_avg(i) = model_moments(12);
    p_avg(i) = model_moments(23);
    
end

figure;
color_d = '#86162a';
color_t = '#172f5f';
color_p = '#EB811B';
%opengl software
plot(psi, d_avg,'DisplayName','d_{avg}','Color',color_d,'LineWidth',1)
hold on
plot(psi, t_avg,'DisplayName','t_{avg}','Color',color_t,'LineWidth',1)
hold on
plot(psi, p_avg,'DisplayName','p_{avg}','Color',color_p,'LineWidth',1)
xline(3.5,'--','Calibration','LabelVerticalAlignment','bottom','LineWidth',1,'fontname','times','HandleVisibility','off')
legend('Location','northwest')
xlabel("psi")
set(gca,'FontSize',12,'fontname','times')
export_fig sensitivity_psi -pdf -transparent 



%% Lifecycle analysis

% Lifecycle of individual: low educated Pentecostal
% Baseline

S_pent_le = S{1,2};

prob_y_m = 0.05;
prob_m_o = 0.05;


T = 50;
consumption_path = zeros(T,1);
savings_path = zeros(T,1);
income_path = zeros(T,1);
employment_path = zeros(T,1);
age_path = zeros(T,1);
transition_path = zeros(T,1);

initial_asset_level = 6;
initial_employment = 0;
initial_age = 1;

employment_path(1) = initial_employment;
age_path(1) = initial_age;
consumption_path(1) = S_pent_le.pol_y(initial_asset_level*2,6);
savings_path(1) = S_pent_le.pol_y(initial_asset_level*2,1);
transition_path(1) = S_pent_le.trans_y(initial_asset_level*2,1);

for t = 2:T
    % 1. Aging: flip age coin
    draw = rand(1);
    age_path(t) = min(3,(draw<prob_y_m)*(age_path(t-1)+1)+(1-(draw<prob_y_m))*age_path(t-1));
    
    % 2. Employment draw: flip employment coin
    employment_path(t) = rand(1)>transition_path(t-1); %transition_path = prob of getting unemployed
    
    % Interpolate policies (depending on age and employment)
    if age_path(t) == 1
    policies = S_pent_le.pol_y;
    elseif age_path(t) == 2
        policies = S_pent_le.pol_m;
    else 
        policies = S_pent_le.pol_o;
    end
    
    % Interpolate savings
    if employment_path(t) == 0
        savings_path(t) = max(0,interp1(params.amat,policies(1:2:size(policies,1),1),savings_path(t-1),'linear','extrap'));         
    else
        savings_path(t) = max(0,interp1(params.amat,policies(2:2:size(policies,1),1),savings_path(t-1),'linear','extrap'));
    end
    
    % Interpolate transition probs
    if age_path(t) == 1
        trans = S_pent_le.trans_y;
    elseif age_path(t) == 2
        trans = S_pent_le.trans_m;
    else 
        trans = S_pent_le.trans_o;
    end
    
    
    if employment_path(t) == 0
        transition_path(t) = max(0,interp1(params.amat,trans(1:2:size(policies,1),1),savings_path(t-1),'linear','extrap'));         
    else
        transition_path(t) = max(0,interp1(params.amat,trans(2:2:size(policies,1),1),savings_path(t-1),'linear','extrap'));
    end
    
    
end


% Plots
figure;
subplot(3,1,1)
plot(savings_path)
title("Savings")

subplot(3,1,2)
plot(employment_path)
title("Employment")

subplot(3,1,3)
plot(age_path)
title("Age")
