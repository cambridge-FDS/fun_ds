function r = vfi(params, educ_rho, educ_pi0, educ_pi1, Ach)
% function to return value and policy functions for each generation,
% depending on religion, education and chuch density level.
% Input:    - params: parameter structure
%           - rel: vector of phi_0 and phi_2, religion-specific
%           - educ: rho vector-element of education specific prod.
%           - trans: education specific transition probs.
% Output: structure of value and policy functions
    %% Define objects and VFI parameters
    N=size(params.states,1);
    tol=0.2; maxits=500; dif=9999; its=1;
    v1_o=zeros(N,1); v1_m=zeros(N,1); v1_y=zeros(N,1);pol_o=zeros(N,11);pol_m=zeros(N,11); pol_y=zeros(N,11);
    V0_guess.v0_o=[1:N]; 
    V0_guess.v0_m=[1:N]; 
    V0_guess.v0_y=[1:N];
    pi0 = educ_pi0;
    pi1 = educ_pi1;
    rho = educ_rho;
    %% Defining the contstraints for fmincon
    A =[0,-1,0,0;0,0,-1,0;0,0,0,-1;0,1,1,1]; B=[0;0;0;1];
    x0=[params.a_min, 0.02, 0.6, 0.02];
    lb=[params.a_min;0; 0; 0];
    ub=[params.a_max; params.a_max; 1; 1];
    %% VFI with Howard's improvement algorithm
    while (dif > tol && its < maxits)
        % define options for fmincon: use sqp algorithm with
        % forward diff (fastest, see test_file.m)
        options = optimoptions('fmincon','StepTolerance',1e-8,'Algorithm','sqp', 'Display','off','FiniteDifferenceType','forward');
        for i = 1:N
            if mod(its,10)==0 || its<3  % Howard's improvement algorithm (now every 10th iteration compute both)
                %disp("value and policy")
                if its>1
                    x0 = pol_o(i,1:4);
                end
                func_old   = @(a) valueold7(a, params, pi0, pi1, rho, Ach, i, V0_guess);
                nonlcon_old = @(a) confungrad(a, params, pi0, pi1,rho, Ach, i, params.eps0o);
                varo       = fmincon(func_old,x0',A,B,[],[],lb,ub,nonlcon_old,options);
                [val, pol] = valueold7(varo, params, pi0, pi1,rho,Ach, i, V0_guess);
                v1_o (i,1) = -val;
                pol_o(i,:) = pol;

                if its>1
                    x0 = pol_m(i,1:4);
                end
                func_mid   = @(a) valuemid7(a, params, pi0, pi1, rho, Ach, i, V0_guess);
                nonlcon_mid = @(a) confungrad(a, params, pi0, pi1,rho,Ach, i, params.eps0m);
                varm       = fmincon(func_mid,x0',A,B,[],[],lb,ub,nonlcon_mid,options);
                [val, pol]  = valuemid7(varm, params, pi0, pi1,rho,Ach, i, V0_guess);
                v1_m(i,1) = -val;
                pol_m(i,:) = pol;

                if its>1
                    x0 = pol_y(i,1:4);
                end
                func_young = @(a) valueyoung7(a, params, pi0, pi1,rho,Ach, i, V0_guess);
                nonlcon_young = @(a) confungrad(a, params, pi0, pi1,rho,Ach, i, params.eps0y);
                vary       = fmincon(func_young,x0',A,B,[],[],lb,ub,nonlcon_young,options);
                [val, pol]  = valueyoung7(vary, params, pi0, pi1,rho,Ach, i, V0_guess);
                v1_y(i,1) = -val;
                pol_y(i,:) = pol;
            else
                %disp("value function iteration")
                v1_o (i,1) = -valueold7(pol_o(i,:), params, pi0, pi1,rho,Ach,i, V0_guess);
                v1_m(i,1)  = -valuemid7(pol_m(i,:), params, pi0, pi1,rho,Ach,i, V0_guess);
                v1_y(i,1)  = -valueyoung7(pol_y(i,:), params, pi0, pi1,rho,Ach,i, V0_guess);
            end

        end

        dif1 = norm(v1_o-V0_guess.v0_o);
        V0_guess.v0_o = v1_o;

        dif2 = norm(v1_m-V0_guess.v0_m);
        V0_guess.v0_m = v1_m;

        dif3 = norm(v1_y-V0_guess.v0_y);
        V0_guess.v0_y = v1_y;

        diff = max(dif1,dif2); dif = max(diff,dif3);
        its  = its+1;
    end
    %its

    v_old=zeros(N,4);v_mid=zeros(N,4);v_young=zeros(N,4);
    %expense shock
    for i=1:N
        [v_old(i,:)]= -valueold7sol(pol_o(i,:), params, pi0, pi1,rho,Ach,i, V0_guess);
        [v_mid(i,:  )]= -valuemid7sol(pol_m(i,:), params, pi0, pi1,rho,Ach,i, V0_guess);
        [v_young(i,:)]= -valueyoung7sol(pol_y(i,:), params, pi0, pi1,rho,Ach,i, V0_guess);
    end

    r=struct('v_old',v_old(:,1:2), 'v_mid',v_mid(:,1:2), 'v_young',v_young(:,1:2), 'pol_o',pol_o,'pol_m',pol_m, 'pol_y', pol_y, 'trans_o',v_old(:,3:4),'trans_m',v_mid(:,3:4),'trans_y',v_young(:,3:4));

end
        