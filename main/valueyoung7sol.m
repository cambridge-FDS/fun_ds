function [val] =valueyoung7sol(a, params, pi0, pi1, rho, delta, state, V0_guess) 
pi0=pi0(1); pi1=pi1(1);
a0 = params.states(state,1); z0=params.states(state,2);
v0_y = V0_guess.v0_y;
v0_m = V0_guess.v0_m;
r=rem(state,2); %to see whether the person is employed or unemployed

%% Interpolation of the value function
gg1y=interp1(params.amat,v0_y(1:2:length(v0_y)),a(1),'linear'); 
% if NaN set to bounds
if isnan(gg1y)==1
    if a(1)<params.amat(1)
        a(1)=params.amat(1); gg1y=v0_y(1);
    else
        a(1)=params.amat(length(params.amat)); gg1y=v0_y(length(v0_y));
    end
end

gg2y=interp1(params.amat,v0_y(2:2:length(v0_y)),a(1),'linear');
if isnan(gg2y)==1
    if a(1)<params.amat(1)
        a(1)=params.amat(1); gg2y=v0_y(1);
    else
        a(1)=params.amat(length(params.amat)); gg2y=v0_y(length(v0_y));
    end
end
ggy=[gg1y;gg2y];

%interpolation for the vlaue of the middle_aged
gg1m=interp1(params.amat,v0_m(1:2:length(v0_m)),a(1),'linear'); 
if isnan(gg1m)==1
    if a(1)<params.amat(1)
        a(1)=params.amat(1); gg1m=v0_m(1);
    else
        a(1)=params.amat(length(params.amat)); gg1m=v0_m(length(v0_m));
    end
end
gg2m=interp1(params.amat,v0_m(2:2:length(v0_m)),a(1),'linear');
if isnan(gg2m)==1
    if a(1)<params.amat(1)
        a(1)=params.amat(1); gg2m=v0_m(1);
    else
        a(1)=params.amat(length(params.amat)); gg2m=v0_m(length(v0_m));
    end
end
ggm=[gg1m;gg2m];


%% Calculate/assign choices
% Choices: a', d, l, t, p, c
% Free variables: a(1) = a', a(2) = t, a(3) = l, a(4) = p;
% Dep. variables: c (function of rest), d (direct function of t)
a_1 = a(1);
t = a(2);
l = a(3);
p = a(4);
% get d from FOC (see write-up), s_r and phi_r follow
d = ((1-params.zetta)/(params.zetta*params.eps0y*z0*rho))^(1/(params.theta1-1)) * t;
% c from budget constraint
c = (1+params.intr)*a0+params.w*rho*params.eps0y*z0*(1-l-t-p)-a_1-d;

% community support channel
s_r     = (params.zetta*d^params.theta1+(1-params.zetta)*t^params.theta1)^(1/params.theta1); % religious investment for community support
phi_r   =   s_r/(s_r+params.phi_0); %prob of community helping with the job find
phi_r   = params.rel_cs*phi_r; % turn on off using rel_indic

% crime channel (shut off for now)
%phi_delta =  s_r/(s_r+phi_4)*rel_indic;
phi_delta=0;
delta_y= 1- (1-params.deltaD_y)- params.deltaD_y*(1-delta(1))*(1-phi_delta);

% belief channel (simplified to be separable)
%p_foc = sqrt((beta*(1-delta_y)* Vheaven*(zetta_h)*phi_2)/(c^(-sigma)*eps0y*z0*rho)) - phi_2;
pi_after = (1-params.zetta_h) * phi_r + params.zetta_h*p/(p+params.phi_2);
pi_after = params.rel_afterlife*pi_after;
% size of expense shock (i.e. how much is outside help mitigating?) (shut off for now)
%q_e     =  q_bar+(1-q_bar)*s_r/(s_r+phi_exp)*rel_indic; %impact of expense shock on utility.
q_e = 1;
%% Define value and constraints (FIXME: constraints should be fullfilled)
% budget constraint
if c <=0
    val1=-999999-999*abs(c); val2=val1;
    employment_trans = [NaN,NaN];
% time constraint
elseif l+t+p>=1
    val1=-999999-999*abs(l)-999*abs(t)-999*abs(p); val2=val1;
    employment_trans = [NaN,NaN];
    
else
    if r==1 %unemployed
        val1=      (c^(1-params.sigma))/(1-params.sigma) - params.psi* ((1-l)^(1+params.eta)/(1+params.eta)) + params.beta*(1-delta_y)* pi_after* params.Vheaven + params.beta*delta_y* ((1- params.gama_m) *ggy'*[pi0-params.cs_effect*phi_r; 1-(pi0-params.cs_effect*phi_r)] + params.gama_m*ggm'*[pi0-params.cs_effect*phi_r; 1-(pi0-params.cs_effect*phi_r)]);
        val2=((q_e*c)^(1-params.sigma))/(1-params.sigma) - params.psi* ((1-l)^(1+params.eta)/(1+params.eta)) + params.beta*(1-delta_y)* pi_after* params.Vheaven + params.beta*delta_y* ((1- params.gama_m) *ggy'*[pi0-params.cs_effect*phi_r; 1-(pi0-params.cs_effect*phi_r)] + params.gama_m*ggm'*[pi0-params.cs_effect*phi_r; 1-(pi0-params.cs_effect*phi_r)]);
        uu = pi0*(1-phi_r);
        ue = 1-pi0*(1-phi_r);
        employment_trans = [uu,ue]; 
    else
        val1=      (c^(1-params.sigma))/(1-params.sigma) - params.psi* ((1-l)^(1+params.eta)/(1+params.eta)) + params.beta*(1-delta_y)* pi_after* params.Vheaven + params.beta*delta_y* ((1- params.gama_m) *ggy'*[1-pi1-params.cs_effect*phi_r; pi1+params.cs_effect*phi_r] + params.gama_m*ggm'*[1-pi1-params.cs_effect*phi_r; pi1+params.cs_effect*phi_r]);
        val2=((q_e*c)^(1-params.sigma))/(1-params.sigma) - params.psi* ((1-l)^(1+params.eta)/(1+params.eta)) + params.beta*(1-delta_y)* pi_after* params.Vheaven + params.beta*delta_y* ((1- params.gama_m) *ggy'*[1-pi1-params.cs_effect*phi_r; pi1+params.cs_effect*phi_r] + params.gama_m*ggm'*[1-pi1-params.cs_effect*phi_r; pi1+params.cs_effect*phi_r]);
        eu = 1-pi1-(1-pi1)*phi_r;
        ee = pi1+(1-pi1)*phi_r;
        employment_trans = [eu,ee];
    end
end
% a(1)=a1;a(2)=d; a(3)=l;
val(1)=-val1; val(2)=-val2;
val(3) = -employment_trans(1);
val(4) = -employment_trans(2);