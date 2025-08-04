function [val] = valueold7sol(a,params, pi0, pi1, rho, delta, state, V0_guess)
pi0=pi0(3); pi1=pi1(3);
a0 = params.states(state,1); z0=params.states(state,2);
v0_o = V0_guess.v0_o;
r=rem(state,2); %to see whether the person is employed or unemployed

%% Interpolation of the value function
gg1=interp1(params.amat,v0_o(1:2:length(v0_o)),a(1),'linear'); %(amat,v0,a(1),'linear')
if isnan(gg1)==1
    if a(1)<params.amat(1)
        a(1)=params.amat(1); gg1=v0_o(1);
    else
        a(1)=params.amat(length(params.amat)); gg1=v0_o(length(v0_o));
    end
end
gg2=interp1(params.amat,v0_o(2:2:length(v0_o)),a(1),'linear');
if isnan(gg2)==1
    if a(1)<params.amat(1)
        a(1)=params.amat(1); gg2=v0_o(1);
    else
        a(1)=params.amat(length(params.amat)); gg2=v0_o(length(v0_o));
    end
end
gg=[gg1;gg2];

%% Calculate/assign choices
% Choices: a', d, l, t, p, c
% Free variables: a(1) = a', a(2) = t, a(3) = l, a(4) = p;
% Dep. variables: c (function of rest), d (direct function of t)
a_1 = a(1);
t = a(2);
l = a(3);
p = a(4);
% get d from FOC (see write-up), s_r and phi_r follow
d = ((1-params.zetta)/(params.zetta*params.eps0o*z0*rho))^(1/(params.theta1-1)) * t;
% c from budget constraint
c = (1+params.intr)*a0+params.w*rho*params.eps0o*z0*(1-l-t-p)-a_1-d;

% community support channel
s_r     = (params.zetta*d^params.theta1+(1-params.zetta)*t^params.theta1)^(1/params.theta1); % religious investment for community support
phi_r   =   s_r/(s_r+params.phi_0); %prob of community helping with the job find
phi_r   = params.rel_cs*phi_r; % turn on off using rel_indic

% belief channel (simplified to just depend on p (praying, going to church)
%s_h     = (zetta_h*p^theta2 + (1-zetta_h)*s_r^theta2)^(1/theta2);
pi_after= p/(p+params.phi_2);

% crime channel (shut off for now)
%phi_delta =  s_r/(s_r+phi_4)*rel_indic;
phi_delta=0;
delta_o= 1- (1-params.deltaD_o)- params.deltaD_o*(1-delta(1))*(1-phi_delta);

% belief channel (simplified to be separable)
%p_foc = sqrt((beta*(1-delta_o)* Vheaven*(zetta_h)*phi_2)/(c^(-sigma)*eps0o*z0*rho)) - phi_2;
pi_after = (1-params.zetta_h) * phi_r + params.zetta_h*p/(p+params.phi_2);
pi_after = params.rel_afterlife*pi_after;
% size of expense shock (i.e. how much is outside help mitigating?) (shut off for now)
%q_e     =  q_bar+(1-q_bar)*s_r/(s_r+phi_exp)*rel_indic; %impact of expense shock on utility.
q_e = 1;
%% Define value and constraints
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
        val1=      (c^(1-params.sigma))/(1-params.sigma) - params.psi* ((1-l)^(1+params.eta)/(1+params.eta)) + params.beta*(1-delta_o)* pi_after*params.Vheaven + params.beta*delta_o*gg'*[pi0-params.cs_effect*phi_r; 1-(pi0-params.cs_effect*phi_r)];
        val2=((q_e*c)^(1-params.sigma))/(1-params.sigma) - params.psi* ((1-l)^(1+params.eta)/(1+params.eta)) + params.beta*(1-delta_o)* pi_after*params.Vheaven + params.beta*delta_o*gg'*[pi0-params.cs_effect*phi_r; 1-(pi0-params.cs_effect*phi_r)];
        uu = pi0*(1-phi_r);
        ue = 1-pi0*(1-phi_r);
        employment_trans = [uu,ue]; 
    else
        val1=      (c^(1-params.sigma))/(1-params.sigma) - params.psi* ((1-l)^(1+params.eta)/(1+params.eta)) + params.beta*(1-delta_o)* pi_after*params.Vheaven +params.beta*delta_o*gg'*[1-pi1-params.cs_effect*phi_r; pi1+params.cs_effect*phi_r];
        val2=((q_e*c)^(1-params.sigma))/(1-params.sigma) - params.psi* ((1-l)^(1+params.eta)/(1+params.eta)) + params.beta*(1-delta_o)* pi_after*params.Vheaven +params.beta*delta_o*gg'*[1-pi1-params.cs_effect*phi_r; pi1+params.cs_effect*phi_r];
        eu = 1-pi1-(1-pi1)*phi_r;
        ee = pi1+(1-pi1)*phi_r;
        employment_trans = [eu,ee];
    end
end
% a(1)=a1;a(2)=d; a(3)=l;
val(1)=-val1; 
val(2)=-val2; 
val(3) = -employment_trans(1);
val(4) = -employment_trans(2);