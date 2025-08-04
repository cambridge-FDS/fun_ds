function [model_moments, S, p] = inner_main_analysis(parameters, counterfactual)
% This function calculates policy functions for the entire sample
% (all combinations of age, religion, education and crime level)
% input: parameters
% output: distance to empirical moments to minimize

p.rel_cs = counterfactual(1);
p.rel_afterlife = counterfactual(2);

%% Assign parameters to calibrate
p.q_bar   =1; %utility shock in case of an expense shock
p.theta1  =parameters(1);  
%theta2  =parameters(2); redundant in simplified version
p.psi     =parameters(2);  
p.Vheaven =parameters(3);
p.zetta   =parameters(4); %weight on donations
p.zetta_h =parameters(5); %weight on pray (no need in simplified version)
%p.adj = parameters(16); % adjustment parameter for old
%% Empirical, externally calibrated values

rho=[0.67 1.06 1.28]; %education level

% transition matrix (prob to keep/find job, when employed (pi1_rho),
% unemployed (p0_rho) for age and education level 
%(y_l, m_l, o_l, y_m, m_m, o_m, y_h, m_h, o_h)
pi1_rho=[0.7464976 0.7814102 0.655682 0.7992324 0.8408499 0.7422584 0.8698236 0.884513 0.8031941]; % what's the order here: I assume age(from young to old) and then  education
pi0_rho=[0.2497036 0.2043528 0.0898425 0.3254864 0.2609325 0.1019059 0.4298983 0.2738364 0.0902798];
pi0_rho=1-pi0_rho;
p.cs_effect = 0.083369; 

delta_high = 0.97; %survival prob in high crime
delta_low = 0.99;  % survival prob in low crime
crime_levels = [delta_high delta_low];

p.a_min=0; p.a_max=0.2; p.agrid=11; % a grid (mimics monthly income bins)
grid=(p.a_max-p.a_min)/p.agrid;
p.amat=p.a_min:grid:p.a_max; p.amat=p.amat';
p.intr    = 0.025; %yearly int rate from one year bonds 2018
p.deltaD_o = 0.875; p.deltaD_m=0.973; p.deltaD_y=0.99; %prob of survival for diff grups
p.gama_o  =  0.0396; %prob of becoming old
p.gama_m  =  0.0504; %prob of becoming middle-aged
%p.p_exp   = 0.32;%prob of a large expenditure shock
p.p_exp   =0; % shut off for now
p.w=1; p.beta=0.975; p.sigma=2;  p.eta=2; 
p.eps0o=1.07; p.eps0m=0.96; p.eps0y=1.01; %permanent compent of productivity
z1=0.84; z2=1.08; %labour productivity (z1: unemployed, z2: employed)

p.states=[];
%states matrix
for i=1:size(p.amat,1)
    p.states=[p.states; p.amat(i,1) z1; p.amat(i,1) z2];
end
p.numb=(p.agrid+1)*2;
%% Value function iteration over different religions, education levels & crime
% initialize structure
S=cell(5,2*size(rho,2)); %5 again is the number of religons

% Assign religion specific parameters
%now assign the parameters for each religion and solve separately: each for
%is a for a different religion catholic pentecostal protestant other no religion

% Catholic
p.phi_0  =parameters(6);  %scale for community helping with the job find
p.phi_exp=0; %scale for help with expenditure shock (in paper its phi1)
p.phi_2  =parameters(7); %scale for prob afterlife
p.phi_4  =0; %scale for prob of death (safety of the area)
tic
parfor j = 1:2*size(rho,2) % combine crime and education states for prallelization
    if j<4
        delta = crime_levels(1);
        educ_rho = rho(j);
        educ_pi1 = pi1_rho((j-1)*3+1:3*j);
        educ_pi0 = pi0_rho((j-1)*3+1:3*j);
    else
        delta = crime_levels(2);
        educ_rho = rho(j-3);
        educ_pi1 = pi1_rho(((j-3)-1)*3+1:3*(j-3));
        educ_pi0 = pi0_rho(((j-3)-1)*3+1:3*(j-3));
    end
            
    S{1,j} = vfi(p, educ_rho, educ_pi0, educ_pi1, delta);
end
toc

% Pentecostal
p.phi_0  =parameters(8);  %scale for community helping with the job find
p.phi_exp=0; %scale for help with expenditure shock (in paper its phi1)
p.phi_2  =parameters(9); %scale for prob afterlife
p.phi_4  =0; %scale for prob of death (safety of the area)
parfor j = 1:2*size(rho,2) % combine crime and education states for prallelization
    if j<4
        delta = crime_levels(1);
        educ_rho = rho(j);
        educ_pi1 = pi1_rho((j-1)*3+1:3*j);
        educ_pi0 = pi0_rho((j-1)*3+1:3*j);
    else
        delta = crime_levels(2);
        educ_rho = rho(j-3);
        educ_pi1 = pi1_rho(((j-3)-1)*3+1:3*(j-3));
        educ_pi0 = pi0_rho(((j-3)-1)*3+1:3*(j-3));
    end
            
    S{2,j} = vfi(p, educ_rho, educ_pi0, educ_pi1, delta);
end

% Protestant
p.phi_0  =parameters(10);  %scale for community helping with the job find
p.phi_exp=0; %scale for help with expenditure shock (in paper its phi1)
p.phi_2  =parameters(11); %scale for prob afterlife
p.phi_4  =0; %scale for prob of death (safety of the area)
parfor j = 1:2*size(rho,2) % combine crime and education states for prallelization
    if j<4
        delta = crime_levels(1);
        educ_rho = rho(j);
        educ_pi1 = pi1_rho((j-1)*3+1:3*j);
        educ_pi0 = pi0_rho((j-1)*3+1:3*j);
    else
        delta = crime_levels(2);
        educ_rho = rho(j-3);
        educ_pi1 = pi1_rho(((j-3)-1)*3+1:3*(j-3));
        educ_pi0 = pi0_rho(((j-3)-1)*3+1:3*(j-3));
    end
            
    S{3,j} = vfi(p, educ_rho, educ_pi0, educ_pi1, delta);
end

% Other
p.phi_0  =parameters(12);  %scale for community helping with the job find
p.phi_exp=0; %scale for help with expenditure shock (in paper its phi1)
p.phi_2  =parameters(13); %scale for prob afterlife
p.phi_4  =0; %scale for prob of death (safety of the area)
parfor j = 1:2*size(rho,2) % combine crime and education states for prallelization
    if j<4
        delta = crime_levels(1);
        educ_rho = rho(j);
        educ_pi1 = pi1_rho((j-1)*3+1:3*j);
        educ_pi0 = pi0_rho((j-1)*3+1:3*j);
    else
        delta = crime_levels(2);
        educ_rho = rho(j-3);
        educ_pi1 = pi1_rho(((j-3)-1)*3+1:3*(j-3));
        educ_pi0 = pi0_rho(((j-3)-1)*3+1:3*(j-3));
    end
            
    S{4,j} = vfi(p, educ_rho, educ_pi0, educ_pi1, delta);
end
% Non-religious
p.phi_0  =parameters(14);  %scale for community helping with the job find
p.phi_exp=0; %scale for help with expenditure shock (in paper its phi1)
p.phi_2  =parameters(15); %scale for prob afterlife
p.phi_4  =0; %scale for prob of death (safety of the area)
%rel_indic=0; %religion indication=0
parfor j = 1:2*size(rho,2) % combine crime and education states for prallelization
    if j<4
        delta = crime_levels(1);
        educ_rho = rho(j);
        educ_pi1 = pi1_rho((j-1)*3+1:3*j);
        educ_pi0 = pi0_rho((j-1)*3+1:3*j);
    else
        delta = crime_levels(2);
        educ_rho = rho(j-3);
        educ_pi1 = pi1_rho(((j-3)-1)*3+1:3*(j-3));
        educ_pi0 = pi0_rho(((j-3)-1)*3+1:3*(j-3));
    end
            
    S{5,j} = vfi(p, educ_rho, educ_pi0, educ_pi1, delta);
end

model_moments=compute_model_moments(S,p.numb,p.amat,parameters,p.agrid);

end