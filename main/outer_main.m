%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This is the outer loop, searching for parameters minimizing
%   the weighted distance of simulated moments to empirical targets.
%   Here, pattern search is used.
%   
%   Inputs: - Inner main (solve value functions and caluculates moments)
%           - parameter guess and bounds
%   Output: - optimal parameter space
%
%   Steps to start optimization:
%   1. save targets and sdinv to file
%   2. initialise object to store (done here)
%   3. make sure to comment out either patternsearch or fmincon
%   4. run outer_main.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup
clear all;
clc;
%initialise object to save estimated moments
timestamp = datetime("today");
estimate_moments_all = [];
save(sprintf('results/estimate_moments_all_%s.mat',timestamp), 'estimate_moments_all');
parameters_all = [];
save(sprintf('results/parameters_all_%s.mat', timestamp), 'parameters_all');
estimate_distance =[];
save(sprintf('results/estimate_distance_%s.mat', timestamp), 'estimate_distance');

%% Pattern search
% parameters = [theta1, psi, Vheaven, zetta, zetta_h, phi_0 (cath.), phi_2 (cath.),
% phi_0 (pent.), phi_2(pent.), phi_0 (prot.), phi_2 (prot.), phi_0 (other),
% phi_2 (other), phi_0 (non_rel), phi_2 (non_rel) , alpha]
% FIXME: adj Introduce adjustment parameter for old to adjust pray time (think
% more about reaonable modeling approach to achieve this)

load ./results/params_opt.mat
parameters_initial=[params_opt];
%lb=                [0.01, 1, 3, 0.001, 0.001, 0.025, 0.002, 0.01, 0.002, 0.01, 0.001, 0.01, 0.0005, 0.02, 0.01, 0, 1];
%ub=                [1, 20, 20, 1, 1, 0.05, 0.01, 0.04, 0.01, 0.05, 0.01, 0.05, 0.01, 0.1, 0.1, 1, 2]; 
lb = 0.8*[params_opt];
ub = 1.2*[params_opt];

ObjFunc=@(parameters)inner_main(parameters, timestamp);


% surrogateopt
options = optimoptions('surrogateopt','InitialPoints',parameters_initial,'Display','iter','PlotFcn','surrogateoptplot','MaxFunctionEvaluations',10000,'MinSampleDistance',1e-2);
[parameters1,distance1,Exitflag,Output,Trials] = surrogateopt(ObjFunc,lb,ub,options);
