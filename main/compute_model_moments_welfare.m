function model_moments_welfare=compute_model_moments_welfare(params,parameters,asset_dist_simul)
% measure based on the precise welfare note
% distribution
numb = params.numb;
load S_all S     % both afterlife channel and community support are on
S_b = S;
load S_nocs S    % community support turned off
S_nocs = S;
load S_noafter S % afterlife turned off
S_noaft = S;
load S_nothing S % both afterlife channel and community support are off
S_nothing = S;
model_moments_welfare=[];

pwd
load ./external_parameters/Emp_Age_new.mat
load ./external_parameters/DEmp_new
load ./external_parameters/Emp_Dcrime_new
load ./external_parameters/Emp_Educ_new
load ./external_parameters/UN_Educ_new
load ./external_parameters/UN_Dcrime_new
load ./external_parameters/UN_Age_new
load ./external_parameters/rel_UE_new %this is the one only for the religious groups. Ordered as: catholic pentecostal protestant other
load ./external_parameters/rel_UE_all_new % this includes non religious: ordering as: catholic pentecostal protestant other no religion
load ./external_parameters/Emp_Age_new.mat
%load ./external_parameters/DAsset_new 

q_bar   =1; %utility shock in case of an expense shock
theta1  =parameters(1);  
psi     =parameters(2);  
Vheaven =parameters(3);
zetta   =parameters(4); %weight on donations
zetta_h =parameters(5); %weight on pray

params.p_exp   =0; % shut off for now
q_e=1;
params.sigma = 2 ; params.eta =2;
phi_0=[parameters(6),parameters(8),parameters(10),parameters(12),parameters(14)];
%phi_exp=[parameters(9),parameters(13),parameters(17),parameters(21)];
phi_2=[parameters(7),parameters(9),parameters(11),parameters(13),parameters(15)];
%phi_4=[parameters(11),parameters(15),parameters(19),parameters(23)];

[ca cb cc cd]=ndgrid(asset_dist_simul,Emp_Age_new,Emp_Educ_new,Emp_Dcrime_new);
combs1 = [ca(:), cb(:), cc(:), cd(:)];

Dist_emp=prod(combs1,2);
%Dist_emp=Dist_emp*DEmp(2); %(this does not sum up to 1)

[ca cb cc cd]=ndgrid(asset_dist_simul,UN_Age_new,UN_Educ_new,UN_Dcrime_new);
combs2 = [ca(:), cb(:), cc(:), cd(:)];

Dist_un=prod(combs2,2);

%====================%
%Distribution
%====================%
% Order: religion - Emloyment- Crime- Education - Age - Assets
% for example (1,1) and (2,1) we move along the asset grid while all other
% properties are the same
Distr=[];
for rel=1:5 %including nonreligious too 
    Distr=[Distr; rel_UE_all_new(rel,1)*Dist_un; rel_UE_all_new(rel,2)*Dist_emp]; %creating the distribution after religion. rel_UE has distribution by religion for Employed and Unemployed
end

%====================%
% value baseline
%====================%
%vector value:
Vec_value_b=[];
for rel=1:5
Vec_value_un=[]; Vec_value_e=[];
% The entire value
for az=1:2*3
    Vec_value_un=[Vec_value_un; S_b{rel,az}. v_old(1:2:numb,1); S_b{rel,az}. v_mid(1:2:numb,1); S_b{rel,az}. v_young(1:2:numb,1)];
    Vec_value_e =[Vec_value_e ; S_b{rel,az}. v_old(2:2:numb,1); S_b{rel,az}. v_mid(2:2:numb,1); S_b{rel,az}. v_young(2:2:numb,1)];
end
Vec_value_b=[Vec_value_b;Vec_value_un;Vec_value_e];
end

% The after life value
Vec_val_after_b=[];
for rel=1:5
Vec_val_after_un=[]; Vec_val_after_e=[];

for az=1:2*3
    Vec_val_after_un=[Vec_val_after_un; S_b{rel,az}. pol_o(1:2:numb,10); S_b{rel,az}. pol_m(1:2:numb,10); S_b{rel,az}. pol_y(1:2:numb,10)];
    Vec_val_after_e =[Vec_val_after_e ; S_b{rel,az}. pol_o(2:2:numb,10); S_b{rel,az}. pol_m(2:2:numb,10); S_b{rel,az}. pol_y(2:2:numb,10)];
end
Vec_val_after_b=[Vec_val_after_b;Vec_val_after_un;Vec_val_after_e];
end

%====================%
% value no cs
%====================%
%vector value:
Vec_value_nocs=[];
for rel=1:5
Vec_value_un=[]; Vec_value_e=[];
% The entire value
for az=1:2*3
    Vec_value_un=[Vec_value_un; S_nocs{rel,az}. v_old(1:2:numb,1); S_nocs{rel,az}. v_mid(1:2:numb,1); S_nocs{rel,az}. v_young(1:2:numb,1)];
    Vec_value_e =[Vec_value_e ; S_nocs{rel,az}. v_old(2:2:numb,1); S_nocs{rel,az}. v_mid(2:2:numb,1); S_nocs{rel,az}. v_young(2:2:numb,1)];
end
Vec_value_nocs=[Vec_value_nocs;Vec_value_un;Vec_value_e];
end

% The after life value
Vec_val_after_nocs=[];
for rel=1:5
Vec_val_after_un=[]; Vec_val_after_e=[];

for az=1:2*3
    Vec_val_after_un=[Vec_val_after_un; S_nocs{rel,az}. pol_o(1:2:numb,10); S_nocs{rel,az}. pol_m(1:2:numb,10); S_nocs{rel,az}. pol_y(1:2:numb,10)];
    Vec_val_after_e =[Vec_val_after_e ; S_nocs{rel,az}. pol_o(2:2:numb,10); S_nocs{rel,az}. pol_m(2:2:numb,10); S_nocs{rel,az}. pol_y(2:2:numb,10)];
end
Vec_val_after_nocs=[Vec_val_after_nocs;Vec_val_after_un;Vec_val_after_e];
end
%====================%
% value no after
%====================%
%vector value:
Vec_value_noaft=[];
for rel=1:5
Vec_value_un=[]; Vec_value_e=[];
% The entire value
for az=1:2*3
    Vec_value_un=[Vec_value_un; S_noaft{rel,az}. v_old(1:2:numb,1); S_noaft{rel,az}. v_mid(1:2:numb,1); S_noaft{rel,az}. v_young(1:2:numb,1)];
    Vec_value_e =[Vec_value_e ; S_noaft{rel,az}. v_old(2:2:numb,1); S_noaft{rel,az}. v_mid(2:2:numb,1); S_noaft{rel,az}. v_young(2:2:numb,1)];
end
Vec_value_noaft=[Vec_value_noaft;Vec_value_un;Vec_value_e];
end

% The after life value
Vec_val_after_noaft=[];
for rel=1:5
Vec_val_after_un=[]; Vec_val_after_e=[];

for az=1:2*3
    Vec_val_after_un=[Vec_val_after_un; S_noaft{rel,az}. pol_o(1:2:numb,10); S_noaft{rel,az}. pol_m(1:2:numb,10)+S_noaft{rel,az}. pol_m(1:2:numb,11).* S_noaft{rel,az}. pol_o(1:2:numb,10);... 
        S_noaft{rel,az}. pol_y(1:2:numb,10) + S_noaft{rel,az}. pol_y(1:2:numb,11) .*(S_noaft{rel,az}. pol_m(1:2:numb,10)+S_noaft{rel,az}. pol_m(1:2:numb,11).* S_noaft{rel,az}. pol_o(1:2:numb,10))];
    Vec_val_after_e =[Vec_val_after_e ; S_noaft{rel,az}. pol_o(2:2:numb,10); S_noaft{rel,az}. pol_m(2:2:numb,10)+S_noaft{rel,az}. pol_m(2:2:numb,11).* S_noaft{rel,az}. pol_o(2:2:numb,10);...
        S_noaft{rel,az}. pol_y(2:2:numb,10) + S_noaft{rel,az}. pol_y(2:2:numb,11) .*(S_noaft{rel,az}. pol_m(2:2:numb,10)+S_noaft{rel,az}. pol_m(2:2:numb,11).* S_noaft{rel,az}. pol_o(2:2:numb,10))] ;
end
Vec_val_after_noaft=[Vec_val_after_noaft;Vec_val_after_un;Vec_val_after_e];
end

%====================%
% value nothing
%====================%
%vector value:
Vec_value_nothing=[];
for rel=1:5
Vec_value_un=[]; Vec_value_e=[];
% The entire value
for az=1:2*3
    Vec_value_un=[Vec_value_un; S_nothing{rel,az}. v_old(1:2:numb,1); S_nothing{rel,az}. v_mid(1:2:numb,1); S_nothing{rel,az}. v_young(1:2:numb,1)];
    Vec_value_e =[Vec_value_e ; S_nothing{rel,az}. v_old(2:2:numb,1); S_nothing{rel,az}. v_mid(2:2:numb,1); S_nothing{rel,az}. v_young(2:2:numb,1)];
end
Vec_value_nothing=[Vec_value_nothing;Vec_value_un;Vec_value_e];
end

% The after life value
Vec_val_after_nothing=[];
for rel=1:5
Vec_val_after_un=[]; Vec_val_after_e=[];

for az=1:2*3
    Vec_val_after_un=[Vec_val_after_un; S_nothing{rel,az}. pol_o(1:2:numb,10); S_nothing{rel,az}. pol_m(1:2:numb,10) + S_nothing{rel,az}. pol_m(1:2:numb,11) .* S_nothing{rel,az}. pol_o(1:2:numb,10);...
        S_nothing{rel,az}. pol_y(1:2:numb,10)+ S_nothing{rel,az}. pol_y(1:2:numb,11) .*(S_nothing{rel,az}. pol_m(1:2:numb,10) + S_nothing{rel,az}. pol_m(1:2:numb,11) .* S_nothing{rel,az}. pol_o(1:2:numb,10))];
    Vec_val_after_e =[Vec_val_after_e ; S_nothing{rel,az}. pol_o(2:2:numb,10); S_nothing{rel,az}. pol_m(2:2:numb,10) + S_nothing{rel,az}. pol_m(2:2:numb,11) .* S_nothing{rel,az}. pol_o(2:2:numb,10);...
        S_nothing{rel,az}. pol_y(2:2:numb,10)+ S_nothing{rel,az}. pol_y(2:2:numb,11) .*(S_nothing{rel,az}. pol_m(2:2:numb,10) + S_nothing{rel,az}. pol_m(2:2:numb,11) .* S_nothing{rel,az}. pol_o(2:2:numb,10)) ];
end
Vec_val_after_nothing=[Vec_val_after_nothing;Vec_val_after_un;Vec_val_after_e];
end


%====================%
% Ratio w - appendix document (created by Tiago)
%====================%
w_nocs = ((Vec_value_nocs - Vec_val_after_b)./(Vec_value_b - Vec_val_after_b)).^(1/(1-params.sigma))-1;
w_noaft = ((Vec_value_noaft - Vec_val_after_b)./(Vec_value_b - Vec_val_after_b)).^(1/(1-params.sigma))-1;
w_nothing = ((Vec_value_nothing - Vec_val_after_b)./(Vec_value_b - Vec_val_after_b)).^(1/(1-params.sigma))-1;

%w_tild_nocs = ((Vec_value_nocs - Vec_val_after_nocs)./(Vec_value_b - Vec_val_after_b)).^(1/(1-params.sigma))-1;
%w_tild_noaft = ((Vec_value_noaft - Vec_val_after_nocs)./(Vec_value_b - Vec_val_after_b)).^(1/(1-params.sigma))-1;
%w_tild_nothing = ((Vec_value_nothing - Vec_val_after_nocs)./(Vec_value_b - Vec_val_after_b)).^(1/(1-params.sigma))-1;


%====================%
%Moment 1:avg consumption
%====================%
Avg_w_nocs=Distr'*w_nocs; %mean
Avg_w_noaft=Distr'*w_noaft; %mean
Avg_w_nothing=Distr'*w_nothing; %mean

%Avg_w_tild_nocs=Distr'*w_tild_nocs; %measure abstracting from afterlife
%Avg_w_tild_noaft=Distr'*w_tild_noaft; %mean
%Avg_w_tild_nothing=Distr'*w_tild_nothing; %mean

%model_moments_welfare=[model_moments_welfare; Avg_w_nocs;Avg_w_nothing; Avg_w_noaft ; Avg_w_tild_nocs; Avg_w_tild_noaft;Avg_w_tild_nothing];
model_moments_welfare=[model_moments_welfare; Avg_w_nocs;Avg_w_nothing; Avg_w_noaft];

%====================%
%Moment 5-9:
%avg consumption per religion
%====================%
size_D=size(Distr,1)/5; %bcs we have 5 religions (including nonreligous too)
dist_rel=[sum(Distr(1:size_D)); sum(Distr(size_D+1:2*size_D));sum(Distr(1+2*size_D:3*size_D));sum(Distr(3*size_D+1:4*size_D));sum(Distr(4*size_D+1:5*size_D))];


for rel=1:5 
    b_wnocs(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'*w_nocs((rel-1)*size_D+1:rel*size_D);
    b_wnoaft(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'*w_noaft((rel-1)*size_D+1:rel*size_D);
    b_wnothing(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'*w_nothing((rel-1)*size_D+1:rel*size_D);

  %  b_wnocs_t(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'*w_tild_nocs((rel-1)*size_D+1:rel*size_D);
  %  b_wnoaft_t(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'*w_tild_noaft((rel-1)*size_D+1:rel*size_D);
  %  b_wnothing_t(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'*w_tild_nothing((rel-1)*size_D+1:rel*size_D);


end
%model_moments_welfare=[model_moments_welfare; b_wnocs; b_wnoaft; b_wnothing; b_wnocs_t; b_wnoaft_t;b_wnothing_t];
model_moments_welfare=[model_moments_welfare; b_wnocs; b_wnoaft; b_wnothing];


% ---
%====================%
%Moment 25-27:
%avg time per age
%====================%
ag=params.agrid+1;
Vec_wnocs_o=[];Vec_wnocs_m=[];Vec_wnocs_y=[]; dis_o=[];dis_m=[];dis_y=[];
Vec_noaft_o=[];Vec_noaft_m=[];Vec_noaft_y=[];
Vec_nothing_o=[];Vec_nothing_m=[];Vec_nothing_y=[];

for as=1:3:size(Distr,1)/(3*ag)
    Vec_wnocs_o=[Vec_wnocs_o; w_nocs((as-1)*(ag)+1: as*ag)];
    Vec_noaft_o=[Vec_noaft_o; w_noaft((as-1)*(ag)+1: as*ag)];
    Vec_nothing_o=[Vec_nothing_o; w_nothing((as-1)*(ag)+1: as*ag)];
    dis_o=[dis_o; Distr((as-1)*ag+1: as*ag)] ;
    
    Vec_wnocs_m=[Vec_wnocs_m; w_nocs((as)*(ag)+1: (as+1)*ag)];
    Vec_noaft_m=[Vec_noaft_m; w_noaft((as)*(ag)+1: (as+1)*ag)];
    Vec_nothing_m=[Vec_nothing_m; w_nothing((as)*(ag)+1: (as+1)*ag)];
    dis_m=[dis_m; Distr((as)*ag+1: (as+1)*ag)] ;
    
    Vec_wnocs_y=[Vec_wnocs_y; w_nocs((as+1)*(ag)+1: (as+2)*ag)];
    Vec_noaft_y=[Vec_noaft_y; w_noaft((as+1)*(ag)+1: (as+2)*ag)];
    Vec_nothing_y=[Vec_nothing_y; w_nothing((as+1)*(ag)+1: (as+2)*ag)];
    dis_y=[dis_y; Distr((as+1)*ag +1: (as+2)*ag )] ;
end
wnocs_o=(sum(dis_o))^(-1) * dis_o' *Vec_wnocs_o;
wnocs_m=(sum(dis_m))^(-1) * dis_m' *Vec_wnocs_m;
wnocs_y=(sum(dis_y))^(-1) * dis_y' *Vec_wnocs_y;

wnoaft_o=(sum(dis_o))^(-1) * dis_o' *Vec_noaft_o;
wnoaft_m=(sum(dis_m))^(-1) * dis_m' *Vec_noaft_m;
wnoaft_y=(sum(dis_y))^(-1) * dis_y' *Vec_noaft_y;

wnothing_o=(sum(dis_o))^(-1) * dis_o' *Vec_nothing_o;
wnothing_m=(sum(dis_m))^(-1) * dis_m' *Vec_nothing_m;
wnothing_y=(sum(dis_y))^(-1) * dis_y' *Vec_nothing_y;




% Moments by religion - income
dist_rel_asset=[];
for ot =1:5
for i = 1:12
    distra= sum(Distr((ot-1)*size_D+i:12:ot*size_D)); % distr
    dist_rel_asset=[dist_rel_asset;distra];
end
end

%catholic pentecostal protestant other no religion
 wnocs_asset_rel =[];
for rel=1:5
    perrel=[];
for i =1:12
    r_wnocs=dist_rel_asset((rel-1)*12+i)^(-1)*Distr((rel-1)*size_D+i:12:rel*size_D)'*w_nocs((rel-1)*size_D+i:12:rel*size_D);
    perrel =[perrel;r_wnocs];     
end
wnocs_asset_rel=[wnocs_asset_rel perrel];
end

 wnoaft_asset_rel =[];
for rel=1:5
    perrel=[];
for i =1:12
    r_wnoaft=dist_rel_asset((rel-1)*12+i)^(-1)*Distr((rel-1)*size_D+i:12:rel*size_D)'*w_noaft((rel-1)*size_D+i:12:rel*size_D);
    perrel =[perrel;r_wnoaft];     
end
wnoaft_asset_rel=[wnoaft_asset_rel perrel];
end


wnothing_asset_rel =[];
for rel=1:5
    perrel=[];
for i =1:12
    r_wnothing=dist_rel_asset((rel-1)*12+i)^(-1)*Distr((rel-1)*size_D+i:12:rel*size_D)'*w_nothing((rel-1)*size_D+i:12:rel*size_D);
    perrel =[perrel;r_wnothing];     
end
wnothing_asset_rel=[wnothing_asset_rel perrel];
end

% Sample data (replace this with your actual data)
data = wnocs_asset_rel;

% Create a figure
figure;

% Plot each column as a separate line with different colors
hold on;
for i = 1:5
    plot(data(:, i), 'LineWidth', 2); % Adjust LineWidth as needed
end
hold off;

% Add a grid
grid on;

% Customize line colors (you can change these colors as desired)
lineColors = lines(5); % This uses MATLAB's predefined color set
for i = 1:5
    set(gca, 'ColorOrderIndex', i); % Set the color for the next line
    plot(params.amat, data(:, i), 'LineWidth', 2);
    hold on
end

% Add labels, title, and legend as needed
xlabel('Assets');
ylabel('Change in welfare');
title('Welfare: No Community Support');
legend('Catholic', 'Pentecostal', 'Protestant', 'other', 'No religion');

% Adjust the figure appearance if needed
set(gcf, 'Color', 'w'); % Set figure background color to white

%%%%%%%%%

data = wnothing_asset_rel;

% Create a figure
figure;

% Plot each column as a separate line with different colors
hold on;
for i = 1:5
    plot(data(:, i), 'LineWidth', 2); % Adjust LineWidth as needed
end
hold off;

% Add a grid
grid on;

% Customize line colors (you can change these colors as desired)
lineColors = lines(5); % This uses MATLAB's predefined color set
for i = 1:5
    set(gca, 'ColorOrderIndex', i); % Set the color for the next line
    plot(params.amat, data(:, i), 'LineWidth', 2);
    hold on
end

% Add labels, title, and legend as needed
xlabel('Assets');
ylabel('Change in welfare');
title('Welfare: No Afterlife');
legend('Catholic', 'Pentecostal', 'Protestant', 'other', 'No religion');

% Adjust the figure appearance if needed
set(gcf, 'Color', 'w'); % Set figure background color to white

data = wnothing_asset_rel;

% Create a figure
figure;

% Plot each column as a separate line with different colors
hold on;
for i = 1:5
    plot(data(:, i), 'LineWidth', 2); % Adjust LineWidth as needed
end
hold off;

% Add a grid
grid on;

% Customize line colors (you can change these colors as desired)
lineColors = lines(5); % This uses MATLAB's predefined color set
for i = 1:5
    set(gca, 'ColorOrderIndex', i); % Set the color for the next line
    plot(params.amat, data(:, i), 'LineWidth', 2);
    hold on
end

% Add labels, title, and legend as needed
xlabel('Assets');
ylabel('Change in welfare');
title('Welfare: Shutting Down Both Channels');
legend('Catholic', 'Pentecostal', 'Protestant', 'other', 'No religion');

% Adjust the figure appearance if needed
set(gcf, 'Color', 'w'); % Set figure background color to white


end



        
        