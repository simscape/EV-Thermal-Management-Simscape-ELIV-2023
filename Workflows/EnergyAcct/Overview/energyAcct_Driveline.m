%% Energy Accounting, Driveline
%
% This example shows energy accounting in a driveline model.
%
% Copyright 2021-2024 The MathWorks, Inc.

%% Model

open_system('energyAcct_Driveline')
set_param(find_system('energyAcct_Driveline','MatchFilter',@Simulink.match.allVariants,'FindAll', 'on','SearchDepth',1,'type','annotation','Tag','ModelFeatures'),'Interpreter','off')

%% Test 1: No Wind
energyAcct_Driveline_param
drvEnAcc.Scenario.wind = 0;
sim('energyAcct_Driveline')
energyAcct_Driveline_plot1scenario
energyAcct_Driveline_calc

%% Test 2: Headwind
drvEnAcc.Scenario.wind = 10;
sim('energyAcct_Driveline')
energyAcct_Driveline_plot1scenario
energyAcct_Driveline_calc

%% Test 4: Tailwind
drvEnAcc.Scenario.wind = -10;
sim('energyAcct_Driveline')
energyAcct_Driveline_plot1scenario
energyAcct_Driveline_calc

%% Test 4: Low Speed, No Wind 
drvEnAcc.Scenario.wind = 0;
drvEnAcc.Scenario.trqscale  = 0.01;
sim('energyAcct_Driveline')
energyAcct_Driveline_plot1scenario
energyAcct_Driveline_calc

%% Test 5: Downhill
energyAcct_Driveline_param
drvEnAcc.Scenario.incline = -5; % Deg
sim('energyAcct_Driveline')
energyAcct_Driveline_plot1scenario
energyAcct_Driveline_calc


%% Test 6: High Inertia Wheels, Low Inertia Chassis 
energyAcct_Driveline_param
drvEnAcc.Tire.inertia = 20;
drvEnAcc.Vehicle.mass = 161;
drvEnAcc.Scenario.wind = 0;
sim('energyAcct_Driveline')
energyAcct_Driveline_plot1scenario
energyAcct_Driveline_calc

%%
energyAcct_Driveline_param
close all
bdclose all