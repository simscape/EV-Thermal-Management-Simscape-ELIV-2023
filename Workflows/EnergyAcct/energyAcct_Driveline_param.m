%% Description:
% Code to define parameters for energyAcct_Driveline.slx

% Copyright 2022-2023 The MathWorks, Inc.

%% Gearbox data
drvEnAcc.Gearbox.ratio      = 9;            % Transmission ratio, unitless
drvEnAcc.Gearbox.eff        = 0.9700;       % Efficiency, unitless
drvEnAcc.Gearbox.visc       = [0.01 0.01];  % Viscous losses, unitless

%% Tire data
drvEnAcc.Tire.radius        = 0.3340;  % Radius of the tire, m
drvEnAcc.Tire.inertia       = 2;       % Inertia of one tire, kg*m^2
drvEnAcc.Tire.resist.coeff  = 0.0070;  % Resitance coefficient of one tire, unitless
drvEnAcc.Tire.resist.thresh = 0.1;     % Treshold speed, m/s

%% Vehicle data
drvEnAcc.Vehicle.mass       = 1611;    % Mass of the vehicle, kg
drvEnAcc.Vehicle.CG2FA      = 1.4375;  % Distance vehicle's COG to front axle, m
drvEnAcc.Vehicle.CG2RA      = 1.4375;  % Distance vehicle's COG to rear axle, m
drvEnAcc.Vehicle.CG2gnd     = 0.3500;  % Height of the COG (from the ground), m
drvEnAcc.Vehicle.areaF      = 2.1300;  % Front surface vehicle, m^2
drvEnAcc.Vehicle.cD         = 0.2300;  % Drag coefficient vehicle, unitless
drvEnAcc.Vehicle.rhoAir     = 1.18;    % Density of the air, kg/m^3

%% Driving scenario settings
drvEnAcc.Scenario.wind      = 10;      % Wind speed, m/s
drvEnAcc.Scenario.trqscale  = 0.05;    % Scaling factor, unitless
drvEnAcc.Scenario.incline   = 5;       % Degrees