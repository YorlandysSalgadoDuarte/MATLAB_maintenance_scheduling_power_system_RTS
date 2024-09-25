function [time, x, fval, exitflag, output, population, scores] = genetic_algorithm_optimization()
% this function coordinate the maintenance process for a technical system
% the structure dataBase contains the information related to the components
%--the code start here-----------------------------------------------------
clc; clear; % clear all
% load the database
inputFiles = fullfile(pwd, "inputData");
% there are four parameterizations
% 1. dataBaseIEEE_RTS_01: Maintenance Scheduling as RTS paper.
% 2. dataBaseIEEE_RTS_02: Maintenance scheduling with dispersion
% 3. dataBaseIEEE_RTS_03: Maintenance scheduling with dispersion and wind farms
% to be selected
databaseName = "dataBaseIEEE_RTS_01.mat";
structure = load(fullfile(inputFiles, databaseName));
dataBase = structure.dataBase; clear structure inputFiles
% start the optimization process
objectiveFunction = @(x)simulation(x, dataBase); % Monte Carlo method, option to be used %objectiveFunction = @(x)sum(x); % Testing convergency
nvars = length(dataBase.systemComponentsInformation.componentID); % number of variables
disp(["simulationWindow", dataBase.simulationParameters.simulationWindow, "hours"]) % windows of the simulation (8760 hours)
% upper bound of the optimization model
UB = zeros(1, length(dataBase.systemComponentsInformation.componentID)); % allocate for speed
% loop to guarantee maintenance scheduling within the simulation window
for k = 1:length(dataBase.systemComponentsInformation.componentID)
    for m = 1:length(dataBase.systemComponentsInformation.timeOperationBetweenMaintenance{k, 1})
        UB(1, k) = dataBase.simulationParameters.simulationWindow - (dataBase.systemComponentsInformation.durationFirstMaintenance(k) + sum(cell2mat(dataBase.systemComponentsInformation.timeOperationBetweenMaintenance{k, 1})) + sum(cell2mat(dataBase.systemComponentsInformation.timeDurationMaintenance{k, 1})));
    end
end
LB = dataBase.systemComponentsInformation.startFirstMaintenance'; % lower bound of the optimization model
% run the optimization function
% the function variate the initial start time of the maintenance and evaluate the impact of the proposed plan in the system, therefor, the solution is the best pland
% setting of the optimization algorithm
options = optimoptions('ga', 'Display', 'iter', 'UseParallel', true, 'Vectorized', 'off', 'PlotFcn', @gaplotbestf, 'OutputFcn', @savingSchedulingGeneticAlgorithm);
rng('default') % control random number generation
[x, fval, exitflag, output, population, scores] = ga(objectiveFunction, nvars, [], [], [], [], LB, UB, [], [], options); % ga algorithm
x = round(x); % results of the model
% translate hours to date
time = schedulingDatetime(x);
%-- the code ends here-----------------------------------------------------
end