%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Simulation of model
%   
%   Input: - Policy functions (run on wide asset grid)
%          - Empirical characteristics
%
%   Output: Panel of simulated individuals
%
%   Assumptions: - Initial asset distribution
%                - Stable demographics 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function asset_dist= simul_func(params, S)

load ./external_parameters/Emp_Age_new.mat
load ./external_parameters/DEmp_new
%load ./external_parameters/Emp_Dcrime_new
load ./external_parameters/Emp_Dchurch_new
load ./external_parameters/Emp_Educ_new
load ./external_parameters/UN_Educ_new
%load ./external_parameters/UN_Dcrime_new
load ./external_parameters/UN_Dchurch_new
load ./external_parameters/UN_Age_new
load ./external_parameters/rel_UE_new %this is the one only for the religious groups. Ordered as: catholic pentecostal protestant other
load ./external_parameters/rel_UE_all_new % this includes non religious: ordering as: catholic pentecostal protestant other no religion
load ./external_parameters/DAsset_new
%% Simulation settings

N = 1000; % Panel dimension N
T = 10; % Panel dimension T
B = 20; % Burn in period

% define probs. of permanent characteristics (ToDo: use cross-section evidence)
rel_frac = sum(rel_UE_all_new,2);  % what's the second dimension?
age_frac = Emp_Age_new;     % initial
educ_frac = Emp_Educ_new;    % adjust
%crime_frac = Emp_Dcrime_new;       % adjust
church_frac = Emp_Dchurch_new;       % adjust
% define transition probabilities
age_trans = [1-0.9496; 1-0.9604]; % y->m (1-0.0504), m->o (1-0.0396)
survival_prob = [0.99,0.973,0.875]; % y,m,o

% define initial employment probability (burn in)
prob_unemp = 0.3;
%prob_asset = repmat(1/12,12,1); % ToDo: from histogram of wages in survey (proxy)
prob_asset =DAsset_new;
%% Start simulation
characteristics = 3; % rel, educ, church
panel = zeros(N, characteristics,T+B);

% transition states
age = zeros(N, T+B);
emp = zeros(N, T+B);
wealth_initial = zeros(N, 1); % just to initialise 
transition = zeros(N, T+B);

% objects for policy choices
savings = zeros(N, T+B);

for t = 2:(T+B)
    for i = 1:N
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % initialise fixed characteristics
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % draw religion
    draw_temp = rand(1);
    cdf_temp = cumsum(rel_frac);
    panel(i,1,1) = (draw_temp <= cdf_temp(1))*1 + (cdf_temp(1) < draw_temp && draw_temp <= cdf_temp(2))*2 + (cdf_temp(2) < draw_temp && draw_temp <= cdf_temp(3))*3 + (cdf_temp(3) < draw_temp && draw_temp <= cdf_temp(4))*4 + (cdf_temp(4) < draw_temp && draw_temp <= cdf_temp(5))*5;
    % draw education
    draw_temp = rand(1);
    cdf_temp = cumsum(educ_frac);
    panel(i,2,1) = (draw_temp <= cdf_temp(1))*1 + (cdf_temp(1) < draw_temp && draw_temp <= cdf_temp(2))*2 + (cdf_temp(2) < draw_temp && draw_temp <= cdf_temp(3))*3;
    % draw church level
    draw_temp = rand(1);
    cdf_temp = cumsum(church_frac);
    panel(i,3,1) = (draw_temp <= cdf_temp(1))*1 + (cdf_temp(1) < draw_temp && draw_temp <= cdf_temp(2))*2;

    % initialise transitory characteristics
    draw_temp = rand(1);
    cdf_temp = prob_unemp;
    emp(i,1) = (draw_temp <= cdf_temp(1))*0 + (cdf_temp(1) < draw_temp)*1;
    
    draw_temp = rand(1);
    cdf_temp = cumsum(age_frac);
    age(i,1) = (draw_temp <= cdf_temp(1))*1 + (cdf_temp(1) < draw_temp && draw_temp <= cdf_temp(2))*2 + (cdf_temp(2) < draw_temp && draw_temp <= cdf_temp(3))*3 ;
    
    % initialize wealth distribution (burn in!) -> next period we consider
    % the savings from the initial period as the new wealth distr.
    wealth_initial(i,1) = randsample(linspace(1,12,12),1,true, DAsset_new');
    
    % initial choices based on characteristics and states
    % get relevant part of the policy function structure
    helper = [1,2;3,4;5,6];
    %panel(panel==0)=1 ;
    S_i = S{panel(i,1,1),helper(panel(i,2,1),panel(i,3,1))}; % rel, educ*church
    
    % get age relevant policy functions and transitions
    if age(i,1) == 1
        policies = S_i.pol_y;
        trans = S_i.trans_y;
    elseif age(i,1) == 2
        policies = S_i.pol_m;
        trans = S_i.trans_m;
    else 
        policies = S_i.pol_o;
        trans = S_i.trans_o;
    end
    
    % get endogenous transition prob
    transition(i,1) = trans(wealth_initial(i,1),1);
    
    % get choices dep. on wealth and employment
    savings(i,1) = policies(wealth_initial(i,1),1);
  
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % simulate life-cylce
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % death shock (new interviewee with same characteristics and random wealth)
        if(rand(1) > survival_prob(age(i,t-1)))
            % initialize (draw wealth from simulated savings distr.)
            wealth_initial(i,t) = randsample(linspace(1,12,12),1,true, DAsset_new');

            % sample age
            draw_temp = rand(1);
            cdf_temp = cumsum(age_frac);
            age(i,t) = (draw_temp <= cdf_temp(1))*1 + (cdf_temp(1) < draw_temp && draw_temp <= cdf_temp(2))*2 + (cdf_temp(2) < draw_temp && draw_temp <= cdf_temp(3))*3 ;

            % draw employment
            emp(i,t) = rand(1) > prob_unemp;
            
            % continue characteristics
            panel(i,:,t) = panel(i,:,t-1);
            
        else
            wealth_initial(i,t) = savings(i,t-1);
            % aging
            draw_temp = rand(1);
            age(i,t) = min(3,(draw_temp<age_trans(1))*(age(i,t-1)+1)+(1-(draw_temp<age_trans(1)))*age(i,t-1));
        
            % employment coin
            emp(i,t) = rand(1)>transition(i,t-1);
            
             % continue characteristics
            panel(i,:,t) = panel(i,:,t-1);

        end
        
        S_i = S{panel(i,1,1),helper(panel(i,2,1),panel(i,3,1))}; % rel, educ*church
    
        % update policies if age changed
        if(age(i,t) ~= age(i,t-1))
            if age(i,t) == 1
                policies = S_i.pol_y;
                trans = S_i.trans_y;
            elseif age(i,t) == 2
                policies = S_i.pol_m;
                trans = S_i.trans_m;
            else 
                policies = S_i.pol_o;
                trans = S_i.trans_o;
            end 
        end
        
        % interpolate polices/transitions dep. on assets
        
        % Interpolate choices
        if emp(i,t) == 0
            savings(i,t) = max(0,interp1(params.amat,policies(1:2:size(policies,1),1),wealth_initial(i,t),'linear','extrap'));         
                    
            transition(i,t) = max(0,interp1(params.amat,trans(1:2:size(policies,1),1),wealth_initial(i,t),'linear','extrap'));         

        else
            savings(i,t) = max(0,interp1(params.amat,policies(2:2:size(policies,1),1),wealth_initial(i,t),'linear','extrap'));
            
            transition(i,t) = max(0,interp1(params.amat,trans(2:2:size(policies,1),1),wealth_initial(i,t),'linear','extrap'));         
        end
               
    end
    
          
end
%% Get the asset distribution

% 1) drop the first observations
savings2= savings(:,(B+1):end);

% 2) Find where on the asset grid each saving decision lies
grid=(params.a_max-params.a_min)/params.agrid;
loc_init= params.a_min+ grid/2;
mat= savings2<=loc_init ;   % first grid 
size_mat= size(savings2,1)* size(savings2,2);
asset_dist = sum(mat,'all')/ size_mat;    
cntr= 1; 
while cntr<params.agrid
    mat1 = savings2<=loc_init + cntr* grid ;
    mat2 = savings2> loc_init + (cntr-1)* grid ;
    mat=mat1.*mat2 ; % so that both conditions are satisfied
    asset_dist1 = sum(mat,'all')/ size_mat;  
    asset_dist= [asset_dist ; asset_dist1]; 
    mat1=[]; mat2=[]; mat=[];
    cntr=cntr+1;
end

% final grid 
mat = savings2> loc_init + (cntr-1)* grid ;
asset_dist1 = sum(mat,'all')/ size_mat;  
asset_dist= [asset_dist ; asset_dist1]; 
end
