function [distance, S] = inner_main(parameters, timestamp)
% This function calculates policy functions for the entire sample
% (all combinations of age, religion, education and crime level)
% input: parameters
% output: distance to empirical moments to minimize

p.rel_cs=1;         % indicator for community support (1:on, 0:off)
p.rel_afterlife=1;  % indicator for afterlife

%% Assign parameters to calibrate
p.q_bar   =  1;               % utility shock in case of an expense shock- extension to the main analysis
p.theta1  =  parameters(1);   % elasticity
p.psi     =  parameters(2);   % labour disutility
p.Vheaven =  parameters(3);   % value of heaven
p.zetta   =  parameters(4);   % weight on donations
p.zetta_h =  parameters(5);   % weight on pray
p.alpha   =  parameters(16);  % elasticity
%% Empirical, externally calibrated values

rho=[0.67 1.06 1.28]; % productivity related  to education level

% transition matrix (prob to keep/find job, when employed (pi1_rho),
% unemployed (p0_rho). defined for age and education level
%(y_l, m_l, o_l, y_m, m_m, o_m, y_h, m_h, o_h)
% y: young, m: middle-aged, o: old
pi1_rho=[0.7464976 0.7814102 0.655682 0.7992324 0.8408499 0.7422584 0.8698236 0.884513 0.8031941];
pi0_rho=[0.2497036 0.2043528 0.0898425 0.3254864 0.2609325 0.1019059 0.4298983 0.2738364 0.0902798];
pi0_rho=1-pi0_rho;
p.cs_effect = 0.083369;

%delta_high = 0.97; % survival prob in high crime
%delta_low = 0.99;  % survival prob in low crime
%crime_levels = [delta_high delta_low];

p.A_high = parameters(17);  % productivity of high density church area
p.A_low = 1 ; % normalise productivity of low density church area
church_prod = [p.A_high p.A_low];

p.a_min=0; p.a_max=0.2; p.agrid=11; % a grid (mimics monthly income bins)
grid=(p.a_max-p.a_min)/p.agrid;
p.amat=p.a_min:grid:p.a_max; p.amat=p.amat'; % asset vector

p.intr     = 0.025; % yearly int rate from one year bonds 2018
p.deltaD_o = 0.875; p.deltaD_m=0.973; p.deltaD_y=0.99; % prob of survival for diff grups
p.gama_o   =  0.0396; % prob of becoming old (mid to old)
p.gama_m   =  0.0504; % prob of becoming middle-aged (young to mid)
p.p_exp    =  0;      % shut off for now - extension
p.w=1; p.beta=0.975; p.sigma=2;  p.eta=2; % wage, discount factor and elasticities
p.eps0o=1.07; p.eps0m=0.96; p.eps0y=1.01; % permanent compent of productivity
z1=0.84; z2=1.08; % labour productivity (z1: unemployed, z2: employed)

p.states=[];  % states matrix

for i=1:size(p.amat,1)
    p.states=[p.states; p.amat(i,1) z1; p.amat(i,1) z2];
end
p.numb=(p.agrid+1)*2;
%% Value function iteration over different religions, education levels & crime
% initialize structure
S=cell(5,2*size(rho,2)); % 5 again is the number of religons

% Assign religion specific parameters
% now assign the parameters for each religion and solve separately: each for
% is a for a different religion catholic pentecostal protestant other no religion

% Catholic
p.phi_0  = parameters(6);  % scale for community helping with the job find
p.phi_exp= 0;              % scale for help with expenditure shock (in paper its phi1)
p.phi_2  = parameters(7);  % scale for prob afterlife
p.phi_4  = 0;              % scale for prob of death (safety of the area)
p.s_bar =  (p.zetta*0.012^p.theta1+(1-p.zetta)*0.017^p.theta1)^(1/p.theta1); % d and t from the average of the data
tic
parfor j = 1:2*size(rho,2) % combine church and education states for prallelization
    if j<4
        Ach = church_prod(1);
        educ_rho = rho(j);
        educ_pi1 = pi1_rho((j-1)*3+1:3*j);
        educ_pi0 = pi0_rho((j-1)*3+1:3*j);
    else
        Ach = church_prod(2);
        educ_rho = rho(j-3);
        educ_pi1 = pi1_rho(((j-3)-1)*3+1:3*(j-3));
        educ_pi0 = pi0_rho(((j-3)-1)*3+1:3*(j-3));
    end

    S{1,j} = vfi(p, educ_rho, educ_pi0, educ_pi1, Ach);
end
toc

% Pentecostal
p.phi_0   = parameters(8);  % scale for community helping with the job find
p.phi_exp = 0;              % scale for help with expenditure shock (in paper its phi1)
p.phi_2   = parameters(9);  % scale for prob afterlife
p.phi_4   = 0;              % scale for prob of death (safety of the area)
p.s_bar =  (p.zetta*0.023^p.theta1+(1-p.zetta)*0.030^p.theta1)^(1/p.theta1);

parfor j = 1:2*size(rho,2)  % combine crime and education states for prallelization
    if j<4
        Ach = church_prod(1);
        educ_rho = rho(j);
        educ_pi1 = pi1_rho((j-1)*3+1:3*j);
        educ_pi0 = pi0_rho((j-1)*3+1:3*j);
    else
        Ach = church_prod(2);
        educ_rho = rho(j-3);
        educ_pi1 = pi1_rho(((j-3)-1)*3+1:3*(j-3));
        educ_pi0 = pi0_rho(((j-3)-1)*3+1:3*(j-3));
    end

    S{2,j} = vfi(p, educ_rho, educ_pi0, educ_pi1, Ach);
end

% Protestant
p.phi_0   = parameters(10);  % scale for community helping with the job find
p.phi_exp = 0;             % scale for help with expenditure shock (in paper its phi1)
p.phi_2   = parameters(11); % scale for prob afterlife
p.phi_4   = 0;              % scale for prob of death (safety of the area)
p.s_bar =  (p.zetta*0.022^p.theta1+(1-p.zetta)*0.029^p.theta1)^(1/p.theta1);

parfor j = 1:2*size(rho,2) % combine crime and education states for prallelization
    if j<4
        Ach = church_prod(1);
        educ_rho = rho(j);
        educ_pi1 = pi1_rho((j-1)*3+1:3*j);
        educ_pi0 = pi0_rho((j-1)*3+1:3*j);
    else
        Ach = church_prod(2);
        educ_rho = rho(j-3);
        educ_pi1 = pi1_rho(((j-3)-1)*3+1:3*(j-3));
        educ_pi0 = pi0_rho(((j-3)-1)*3+1:3*(j-3));
    end

    S{3,j} = vfi(p, educ_rho, educ_pi0, educ_pi1, Ach);
end

% Other
p.phi_0   = parameters(12);  % scale for community helping with the job find
p.phi_exp = 0;               % scale for help with expenditure shock (in paper its phi1)
p.phi_2   = parameters(13);  % scale for prob afterlife
p.phi_4   = 0;               % scale for prob of death (safety of the area)
p.s_bar =  (p.zetta*0.022^p.theta1+(1-p.zetta)*0.032^p.theta1)^(1/p.theta1);

parfor j = 1:2*size(rho,2) % combine crime and education states for prallelization
    if j<4
        Ach = church_prod(1);
        educ_rho = rho(j);
        educ_pi1 = pi1_rho((j-1)*3+1:3*j);
        educ_pi0 = pi0_rho((j-1)*3+1:3*j);
    else
        Ach = church_prod(2);
        educ_rho = rho(j-3);
        educ_pi1 = pi1_rho(((j-3)-1)*3+1:3*(j-3));
        educ_pi0 = pi0_rho(((j-3)-1)*3+1:3*(j-3));
    end

    S{4,j} = vfi(p, educ_rho, educ_pi0, educ_pi1, Ach);
end

% Non-religious
p.phi_0   = parameters(14);  % scale for community helping with the job find
p.phi_exp = 0;               % scale for help with expenditure shock (in paper its phi1)
p.phi_2   = parameters(15);  % scale for prob afterlife
p.phi_4   = 0;               % scale for prob of death (safety of the area)
p.s_bar =  (p.zetta*0.004^p.theta1+(1-p.zetta)*0.01^p.theta1)^(1/p.theta1);

parfor j = 1:2*size(rho,2) % combine crime and education states for prallelization
    if j<4
        Ach = church_prod(1);
        educ_rho = rho(j);
        educ_pi1 = pi1_rho((j-1)*3+1:3*j);
        educ_pi0 = pi0_rho((j-1)*3+1:3*j);
    else
        Ach = church_prod(2);
        educ_rho = rho(j-3);
        educ_pi1 = pi1_rho(((j-3)-1)*3+1:3*(j-3));
        educ_pi0 = pi0_rho(((j-3)-1)*3+1:3*(j-3));
    end

    S{5,j} = vfi(p, educ_rho, educ_pi0, educ_pi1, Ach);
end
asset_dist_simul = simul_func(p, S);
%% Save session info
load(sprintf('results/parameters_all_%s.mat', timestamp))
parameters_all = [parameters_all; parameters];
save(sprintf('results/parameters_all_%s.mat', timestamp), 'parameters_all')

parameters
load(sprintf('results/estimate_moments_all_%s.mat', timestamp))
estimate_moment=compute_model_moments(S,p.numb,asset_dist_simul,parameters,p.agrid);

estimate_moment'
estimate_moments_all = [estimate_moments_all; estimate_moment'];
save(sprintf('results/estimate_moments_all_%s.mat', timestamp), 'estimate_moments_all')

load('data_moments/sdinv.mat', 'sdinv')
load('data_moments/target.mat', 'target')

sdinv(28) = sdinv(28) *100;
distance = (sdinv'.*(estimate_moment-target)')* (sdinv.*(estimate_moment-target)) % should be inverse of variance covariance and not inverse of inverse

load(sprintf('results/estimate_distance_%s.mat', timestamp))
estimate_distance=[estimate_distance;distance];
save(sprintf('results/estimate_distance_%s.mat', timestamp), 'estimate_distance')

disp(['Donation distance: ',num2str((sdinv(1:11)'.*(estimate_moment(1:11)-target(1:11))')* (sdinv(1:11).*(estimate_moment(1:11)-target(1:11))))]);
disp(['Time distance: ',num2str((sdinv(12:22)'.*(estimate_moment(12:22)-target(12:22))')* (sdinv(12:22).*(estimate_moment(12:22)-target(12:22))))]);
disp(['Pray distance: ',num2str((sdinv(23:33)'.*(estimate_moment(23:33)-target(23:33))')* (sdinv(23:33).*(estimate_moment(23:33)-target(23:33))))]);
disp(['Community help distance: ',num2str((sdinv(34:43)'.*(estimate_moment(34:43)-target(34:43))')* (sdinv(34:43).*(estimate_moment(34:43)-target(34:43))))]);
disp('-----------------------------------------');
end