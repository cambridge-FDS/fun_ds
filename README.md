# A City of God: Afterlife Beliefs and Job Support in Brazil
This repository contains the code for "A City of God: Afterlife Beliefs and Job Support in Brazil"

## Calibration

The main function to run the calibration is `outer_main.m`. This outer loop runs the simulated method of moments to find the optimal structural parameters. It searches over the parameter space to minimize the weighted distance to the data moments, weighted by their inverse standard deviations.

The function `inner_main` computes all data moments we match against, given a set of parameters. For various characteristics (religion, education etc.) it solves the value function iteration for all generations (young, middle, old) and returns the respective estimates of the population moments. 

All externally calibrated parameters can be found under `external_parameters`. 

Results of calibration runs are saved under results. Specicically, we save the array of weighted distances, the estimated moments for each setting of parameters.

## Counterfactual analysis

After having found the set of optimal structural parameters, several functions offer sensitivity checks and analyse counterfactuals, to quantify the effect of the underlying mechanisms. 



