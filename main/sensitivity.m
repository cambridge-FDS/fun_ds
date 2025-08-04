% This file plots results and calculates counterfactuals

clear;
re_calculate = false;


load params_opt_oct22
parameters = params_opt_oct22;
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


%% Sensitivity analysis

% Sensitivity in terms of V_heaven
V_heaven = linspace(0,30,6);
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
xline(20,'--','Calibration','LabelVerticalAlignment','bottom','LineWidth',1,'fontname','times','HandleVisibility','off')
legend('Location','northwest')
xlabel("Value of heaven")
set(gca,'FontSize',12,'fontname','times')
export_fig sensitivity_v_heaven -pdf -transparent 

data = [V_heaven', d_avg, t_avg, p_avg];
table = array2table(data, 'VariableNames', {'Value of heaven', 'average donations', 'average time', 'average praying'});
writetable(table,'figure_3a.csv')
%%
% Sensitivity in terms of efefctiveness of CS
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
data = [CS_factor', d_avg, t_avg, p_avg];
table = array2table(data, 'VariableNames', {'Efficacy of CS', 'average donations', 'average time', 'average praying'});
writetable(table,'figure_3b.csv')

%% Sensitivity in terms of psi
%parameters = [3.61671064220012,0.754103701618642,3.53128743671852,0.865660611197004,0.390267054537713,0.0320279611792786,0.00470436237611633,0.0224024203431750,0.00719206391079619,0.0230848814525315,0.00493610470630902,0.0236416485949909,0.00194485654465254,0.0599256118677681,0.0838632354907831];
parameters =  params_opt_oct22;
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
