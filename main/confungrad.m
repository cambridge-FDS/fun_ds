function [c,ceq,DC,DCeq] = confungrad(a, params, pi0, pi1,rho,delta, state, eps)
a0 = params.states(state,1); z0=params.states(state,2);
d = (1/(params.zetta*eps*z0*rho))^(1/(params.theta1-1)) * a(2);
cons = (1+params.intr)*a0+params.w*rho*eps*z0*(1-a(3)-a(2)-a(4))-a(1)-d;
c(1) = -cons; % Inequality constraints
% No nonlinear equality constraints
ceq=[];
% Gradient of the constraints:
if nargout > 2
    DC= [1;
        params.w*rho*eps*z0+(1/(params.zetta*eps*z0*rho))^(1/(params.theta1-1));
        params.w*rho*eps*z0;
        params.w*rho*eps*z0
        ];
    DCeq = [];
end
end