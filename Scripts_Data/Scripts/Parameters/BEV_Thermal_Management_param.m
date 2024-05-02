%% Description:
% Code to define parameters for batteryCoolingHVAC.
% Open Model Workspace in the Model Explorer to view and modify parameter
% values. Click 'Reinitialize from Source' to reset to the parameter values
% in this script.

% Copyright 2022-2024 The MathWorks, Inc.

%% Initial conditions:
cabin_p_init           = 0.101325;   % [MPa] Initial air pressure
cabin_T_init           = 40;         % [degC] Initial air temperature
cabin_RH_init          = 0.5;        % Initial relative humidity
cabin_CO2_init         = 4e-4;       % Initial CO2 mole fraction
coolant_p_init         = 0.101325;   % [MPa] Initial coolant pressure
coolant_T_init         = 40;         % [degC] Initial coolant temperature
plate_T_init           = 40;         % [degC] Initial plate temperature
refrigerant_p_init     = 1;          % [MPa] Initial refrigerant pressure
refrigerant_alpha_init = 0.76;       % Initial refrigerant vapor void fraction
battery_T_init         = 40;         % [degC] Initial battery temperature. This temperature will be used on the entire battery as initialization value:
SOC_start              = 0.9;        % [-] This is the starting State of Charge of the battery

%% Vehicle Data
% The required data at the vehicel level
Veh.numWheel           = 2;              % Number of wheels per axle
Veh.CGFA               = 2.875/2;        % [m] Distance between CG and FA, assumption 50/50 mass distribution
Veh.CGRA               = 2.875/2;        % [m] Distance between CG and FA, assumption 50/50 mass distribution
Veh.CGGround           = 0.35;           % [m] Distance CG to ground. Taken from Ph.D. Thesis Nicoletti
Veh.AVeh               = 1.849*1.44*0.8; % [m^2]. Assumption: The frontal area of the vehilce is W*H*0.8 (empirical formula)
Veh.cD                 = 0.23;           % [-] Drag coefficient, dimensionless 
Veh.tireJ              = 2;              % [kg*m^2] Inertia of the tire. Realistic value if we account for tire, brakes and rim mass
Veh.tireR              = 0.334;          % [m] Tire radius, Assumption: 235/45 R18
Veh.tirecR             = 0.007;          % [-] Tire loss coefficient (dimensionless)
vehMass                = 1611;           % [m] Empty mass with driver

%% Cabin Data:
cabin_duct_area          = 0.04;        % [m^2] Air duct cross-sectional area for air flow in the cabin
cabin_glass_conductivity = 0.96;        % [W/(m*K)] Thermal conductivity of the glass
cabin_doors_conductivity = 0.08;        % [W/(m*K)] Thermal conductivity of the doors
cabin_roof_conductivity  = 0.08;        % [W/(m*K)]Thermal conductivity of the roof

%% Liquid Coolant System
coolant_pipe_D              = 0.019;  % [m] Coolant pipe diameter
coolant_channel_D           = 0.0092; % [m] Coolant jacket channels diameter
coolant_valve_displacement  = 0.0063; % [m] Max spool displacement
coolant_valve_S_max         = 0.0053; % [m] Spool position when valve is fully shut or open
coolant_valve_D_ratio_max   = 0.95;   % Max orifice diameter to pipe diameter ratio
coolant_valve_D_ratio_min   = 1e-3;   % Leakage orifice diameter to pipe diameter ratio
pump_displacement           = 0.02;   % [l/rev] Coolant pump volumetric displacement
pump_speed_max              = 1000;   % [rpm] Coolant pump max shaft speed
coolant_tank_volume         = 2.5/2;  % [l] Volume of each coolant tank
coolant_tank_area           = 0.11^2; % [m^2] Area of one side of coolant tank

%% Refrigeration System
refrigerant_pipe_D          = 0.01; % [m] Refrigerant pipe diameter

% Compressor map table
compressor_p_ratio_LUT      = [0; 1; 4.28795213348131; 7.57590426696263; 10.8638564004439; 14.1518085339253]; % Pressure ratio
compressor_rpm_LUT          = [0, 1800, 3600]; % [rpm] Shaft speed
compressor_mdot_corr_LUT    = [
                                0, 0, 0;
                                0, 0.0136946156177912, 0.0273892312355827;
                                0, 0.0102709617133435, 0.0205419234266869;
                                0, 0.00684730780889566, 0.0136946156177912;
                                0, 0.00342365390444783, 0.00684730780889563;
                                0, 0, 0]; % [kg/s] Corrected mass flow rate

%% Radiator
radiator_L                      = 0.6; % [m] Overall radiator length
radiator_W                      = 0.015; % [m] Overall radiator width
radiator_H                      = 0.2; % [m] Overal radiator height
radiator_N_tubes                = 25; % Number of coolant tubes
radiator_tube_H                 = 0.0015; % [m] Height of each coolant tube
radiator_fin_spacing            = 0.002; % Fin spacing
radiator_wall_thickness         = 1e-4; % [m] Material thickness
radiator_wall_conductivity      = 240; % [W/m/K] Material thermal conductivity

radiator_gap_H = (radiator_H - radiator_N_tubes*radiator_tube_H) / (radiator_N_tubes - 1); % [m] Height between coolant tubes
radiator_air_area_flow = (radiator_N_tubes - 1) * radiator_L * radiator_gap_H; % [m^2] Air flow cross-sectional area
radiator_air_area_primary = 2 * (radiator_N_tubes - 1) * radiator_W * (radiator_L + radiator_gap_H); % [m^2] Primary air heat transfer surface area
radiator_N_fins = (radiator_N_tubes - 1) * radiator_L / radiator_fin_spacing; % Total number of fins
radiator_air_area_fins = 2 * radiator_N_fins * radiator_W * radiator_gap_H; % [m^2] Total fin surface area
radiator_tube_Leq = 2*(radiator_H + 20*radiator_tube_H*radiator_N_tubes); % [m] Additional equivalent tube length for losses due to manifold and splits

% Clear unused variables
clear radiator_fin_spacing radiator_gap_H radiator_H radiator_N_fins

%% Condenser
condenser_L                 = 0.63 * 2; % [m] Overall condenser length (2 condensers)
condenser_W                 = 0.015;    % [m] Overall condenser width
condenser_H                 = 0.39;     % [m] Overall condenser height
condenser_N_tubes           = 40;       % Number of refrigerant tubes
condenser_N_tube_channels   = 12;       % Number of channels per refrigerant tube
condenser_tube_H            = 0.002;    % [m] Height of each refrigerant tube
condenser_fin_spacing       = 0.0005;   % [m] Fin spacing
condenser_wall_thickness    = 1e-4;     % [m] Material thickness
condenser_wall_conductivity = 240;      % [W/m/K] Material thermal conductivity

condenser_gap_H = (condenser_H - condenser_N_tubes*condenser_tube_H) / (condenser_N_tubes - 1); % [m] Height between refrigerant tubes
condenser_air_area_flow = (condenser_N_tubes - 1) * condenser_L * condenser_gap_H; % [m^2] Air flow cross-sectional area
condenser_air_area_primary = 2 * (condenser_N_tubes - 1) * condenser_W * (condenser_L + condenser_gap_H); % [m^2] Primary air heat transfer surface area
condenser_N_fins = (condenser_N_tubes - 1) * condenser_L / condenser_fin_spacing; % Total number of fins
condenser_air_area_fins = 2 * condenser_N_fins * condenser_W * condenser_gap_H; % [m^2] Total fin surface area
condenser_tube_area_webs = 2 * condenser_N_tubes * (condenser_N_tube_channels - 1) * condenser_tube_H * condenser_L; % [m^2] Total surface area of webs in refrigerant tubes
condenser_tube_Leq = 2*(condenser_H + 20*condenser_tube_H*condenser_N_tubes) ...
    + (condenser_N_tube_channels - 1)*condenser_L*condenser_tube_H/(condenser_W + condenser_tube_H); % [m] Additional equivalent tube length for losses due to manifold, splits, and webs

clear condenser_gap_H condenser_fin_spacing condenser_H condenser_N_fins condenser_N_tube_channels

%% Evaporator
evaporator_L                = 0.75; % [m] Overall evaporator length
evaporator_W                = 0.015; % [m] Overall evaporator width
evaporator_H                = 0.2; % [m] Overall evaporator height
evaporator_N_tubes          = 20; % Number of refrigerant tubes
evaporator_N_tube_channels  = 12; % Number of channels per refrigerant tube
evaporator_tube_H           = 0.002; % [m] Height of each refrigerant tube
evaporator_fin_spacing      = 0.0005; % Fin spacing
evaporator_wall_thickness   = 1e-4; % [m] Material thickness
evaporator_wall_conductivity= 240; % [W/m/K] Material thermal conductivity

evaporator_gap_H = (evaporator_H - evaporator_N_tubes*evaporator_tube_H) / (evaporator_N_tubes - 1); % [m] Height between refrigerant tubes
evaporator_air_area_flow = (evaporator_N_tubes - 1) * evaporator_L * evaporator_gap_H; % [m^2] Air flow cross-sectional area
evaporator_air_area_primary = 2 * (evaporator_N_tubes - 1) * evaporator_W * (evaporator_L + evaporator_gap_H); % [m^2] Primary air heat transfer surface area
evaporator_N_fins = (evaporator_N_tubes - 1) * evaporator_L / evaporator_fin_spacing; % Total number of fins
evaporator_air_area_fins = 2 * evaporator_N_fins * evaporator_W * evaporator_gap_H; % [m^2] Total fin surface area
evaporator_tube_area_webs = 2 * evaporator_N_tubes * (evaporator_N_tube_channels - 1) * evaporator_L * evaporator_tube_H; % [m^2] Total surface area of webs in refrigerant tubes
evaporator_tube_Leq = 2*(evaporator_H + 20*evaporator_tube_H*evaporator_N_tubes); ...
    + (evaporator_N_tube_channels - 1)*evaporator_L*evaporator_tube_H/(evaporator_W + evaporator_tube_H); % [m] Additional equivalent tube length for losses due to manifold, splits, and webs

% Delete help variables
clear evaporator_gap_H evaporator_H evaporator_N_fins evaporator_N_tube_channels evaporator_fin_spacing

%% Chiller
chiller_N_tubes             = 100; % Number of refrigerant tubes
chiller_tube_L              = 0.4; % [m] Length of each refrigerant tube
chiller_tube_D              = 0.0035; % [m] Diameter of each refrigerant tube
chiller_wall_thickness      = 1e-4; % [m] Material thickness
chiller_wall_conductivity   = 240; % [W/m/K] Material thermal conductivity
chiller_N_baffles           = 3; % Number of coolant baffles
chiller_area_primary        = chiller_N_tubes * pi * chiller_tube_D * chiller_tube_L; % [m^2] Primary heat transfer surface area
chiller_area_baffles        = chiller_N_baffles * 0.7 * 2 * chiller_N_tubes*((2*chiller_tube_D)^2 - pi*chiller_tube_D^2/4); % [m^2] Total surface area of coolant baffles
chiller_tube_Leq            = 2*0.2*chiller_tube_D*chiller_N_tubes; % [m] Additonal equivalent tube length for losses due to manifold and splits.

%% General Battery Data:
% Calculate area of the surface in contact with air. This is used for the convective heat transfer
cellLatSurf             = 2*pi*10.5*70;
cellTopSurf             = pi*10.5;
Battery.moduleOuterSurf = (12*2+64*2)*(cellLatSurf/2)*10^-6 + cellTopSurf*64*12*10^-6; % Outer surface of one module assembly in m^2 (This exclude the portion in contact with the cooling plate)
Battery.battOuterSurf   = 4*Battery.moduleOuterSurf;                 % Outer surface of the entire battery in m^2 (This exclude the portion in contact with the cooling plate)
Battery.battConv        = 5;                                         % Convection between battery and static air
Battery.Np              = 32;                                        % Total number of parallel cells                                                                         
Battery.Ns              = 96;                                        % Total number of serial cells
Battery.cellAh          = 4.493;                                     % Data used for the battery limits

% Clear unused variables
clear cellLatSurf cellTopSurf

%% Module Data (Electrical and Thermal)

% The following vectors and scalar value have been taken from the
% Parameterization manager (21700 Molicel cell)

ModuleType1.SOC_vecCell       = [0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1]; % Vector of state-of-charge values, SOC
ModuleType1.T_vecCell         = [-40 -30 -20 0 23 45 60]+273.15; % Vector of temperatures in K
ModuleType1.V0_matCell        = [3.17242 3.17242 3.17242 3.17242 3.17242 3.17242 3.17242;3.18272 3.18272 3.18272 3.18272 3.18272 3.18272 3.18272;3.19302 3.19302 3.19302 3.19302 3.19302 3.19302 3.19302;3.20331 3.20331 3.20331 3.20331 3.20331 3.20331 3.20331;3.21361 3.21361 3.21361 3.21361 3.21361 3.21361 3.21361;3.22391 3.22391 3.22391 3.22391 3.22391 3.22391 3.22391;3.23421 3.23421 3.23421 3.23421 3.23421 3.23421 3.23421;3.24451 3.24451 3.24451 3.24451 3.24451 3.24451 3.24451;3.25481 3.25481 3.25481 3.25481 3.25481 3.25481 3.25481;3.2651 3.2651 3.2651 3.2651 3.2651 3.2651 3.2651;3.2754 3.2754 3.2754 3.2754 3.2754 3.2754 3.2754;3.2857 3.2857 3.2857 3.2857 3.2857 3.2857 3.2857;3.296 3.296 3.296 3.296 3.296 3.296 3.296;3.3063 3.3063 3.3063 3.3063 3.3063 3.3063 3.3063;3.31659 3.31659 3.31659 3.31659 3.31659 3.31659 3.31659;3.32689 3.32689 3.32689 3.32689 3.32689 3.32689 3.32689;3.33719 3.33719 3.33719 3.33719 3.33719 3.33719 3.33719;3.34749 3.34749 3.34749 3.34749 3.34749 3.34749 3.34749;3.35779 3.35779 3.35779 3.35779 3.35779 3.35779 3.35779;3.36809 3.36809 3.36809 3.36809 3.36809 3.36809 3.36809;3.37838 3.37838 3.37838 3.37838 3.37838 3.37838 3.37838;3.38868 3.38868 3.38868 3.38868 3.38868 3.38868 3.38868;3.39898 3.39898 3.39898 3.39898 3.39898 3.39898 3.39898;3.40928 3.40928 3.40928 3.40928 3.40928 3.40928 3.40928;3.41958 3.41958 3.41958 3.41958 3.41958 3.41958 3.41958;3.42988 3.42988 3.42988 3.42988 3.42988 3.42988 3.42988;3.44017 3.44017 3.44017 3.44017 3.44017 3.44017 3.44017;3.45047 3.45047 3.45047 3.45047 3.45047 3.45047 3.45047;3.46077 3.46077 3.46077 3.46077 3.46077 3.46077 3.46077;3.47107 3.47107 3.47107 3.47107 3.47107 3.47107 3.47107;3.48137 3.48137 3.48137 3.48137 3.48137 3.48137 3.48137;3.49166 3.49166 3.49166 3.49166 3.49166 3.49166 3.49166;3.50196 3.50196 3.50196 3.50196 3.50196 3.50196 3.50196;3.51226 3.51226 3.51226 3.51226 3.51226 3.51226 3.51226;3.52256 3.52256 3.52256 3.52256 3.52256 3.52256 3.52256;3.53286 3.53286 3.53286 3.53286 3.53286 3.53286 3.53286;3.54316 3.54316 3.54316 3.54316 3.54316 3.54316 3.54316;3.55345 3.55345 3.55345 3.55345 3.55345 3.55345 3.55345;3.56375 3.56375 3.56375 3.56375 3.56375 3.56375 3.56375;3.57405 3.57405 3.57405 3.57405 3.57405 3.57405 3.57405;3.58435 3.58435 3.58435 3.58435 3.58435 3.58435 3.58435;3.59465 3.59465 3.59465 3.59465 3.59465 3.59465 3.59465;3.60495 3.60495 3.60495 3.60495 3.60495 3.60495 3.60495;3.61524 3.61524 3.61524 3.61524 3.61524 3.61524 3.61524;3.62554 3.62554 3.62554 3.62554 3.62554 3.62554 3.62554;3.63584 3.63584 3.63584 3.63584 3.63584 3.63584 3.63584;3.64614 3.64614 3.64614 3.64614 3.64614 3.64614 3.64614;3.65644 3.65644 3.65644 3.65644 3.65644 3.65644 3.65644;3.66673 3.66673 3.66673 3.66673 3.66673 3.66673 3.66673;3.67703 3.67703 3.67703 3.67703 3.67703 3.67703 3.67703;3.68733 3.68733 3.68733 3.68733 3.68733 3.68733 3.68733;3.69763 3.69763 3.69763 3.69763 3.69763 3.69763 3.69763;3.71041 3.71041 3.71041 3.71041 3.71041 3.71041 3.71041;3.72113 3.72113 3.72113 3.72113 3.72113 3.72113 3.72113;3.72997 3.72997 3.72997 3.72997 3.72997 3.72997 3.72997;3.73882 3.73882 3.73882 3.73882 3.73882 3.73882 3.73882;3.74912 3.74912 3.74912 3.74912 3.74912 3.74912 3.74912;3.75936 3.75936 3.75936 3.75936 3.75936 3.75936 3.75936;3.76951 3.76951 3.76951 3.76951 3.76951 3.76951 3.76951;3.7791 3.7791 3.7791 3.7791 3.7791 3.7791 3.7791;3.78865 3.78865 3.78865 3.78865 3.78865 3.78865 3.78865;3.79787 3.79787 3.79787 3.79787 3.79787 3.79787 3.79787;3.80709 3.80709 3.80709 3.80709 3.80709 3.80709 3.80709;3.8161 3.8161 3.8161 3.8161 3.8161 3.8161 3.8161;3.82509 3.82509 3.82509 3.82509 3.82509 3.82509 3.82509;3.83409 3.83409 3.83409 3.83409 3.83409 3.83409 3.83409;3.84308 3.84308 3.84308 3.84308 3.84308 3.84308 3.84308;3.85207 3.85207 3.85207 3.85207 3.85207 3.85207 3.85207;3.86107 3.86107 3.86107 3.86107 3.86107 3.86107 3.86107;3.87006 3.87006 3.87006 3.87006 3.87006 3.87006 3.87006;3.87901 3.87901 3.87901 3.87901 3.87901 3.87901 3.87901;3.88831 3.88831 3.88831 3.88831 3.88831 3.88831 3.88831;3.89824 3.89824 3.89824 3.89824 3.89824 3.89824 3.89824;3.90887 3.90887 3.90887 3.90887 3.90887 3.90887 3.90887;3.91951 3.91951 3.91951 3.91951 3.91951 3.91951 3.91951;3.93012 3.93012 3.93012 3.93012 3.93012 3.93012 3.93012;3.94073 3.94073 3.94073 3.94073 3.94073 3.94073 3.94073;3.95138 3.95138 3.95138 3.95138 3.95138 3.95138 3.95138;3.96184 3.96184 3.96184 3.96184 3.96184 3.96184 3.96184;3.97226 3.97226 3.97226 3.97226 3.97226 3.97226 3.97226;3.98268 3.98268 3.98268 3.98268 3.98268 3.98268 3.98268;3.99311 3.99311 3.99311 3.99311 3.99311 3.99311 3.99311;4.0032 4.0032 4.0032 4.0032 4.0032 4.0032 4.0032;4.01221 4.01221 4.01221 4.01221 4.01221 4.01221 4.01221;4.01944 4.01944 4.01944 4.01944 4.01944 4.01944 4.01944;4.02668 4.02668 4.02668 4.02668 4.02668 4.02668 4.02668;4.03286 4.03286 4.03286 4.03286 4.03286 4.03286 4.03286;4.03874 4.03874 4.03874 4.03874 4.03874 4.03874 4.03874;4.04383 4.04383 4.04383 4.04383 4.04383 4.04383 4.04383;4.0488 4.0488 4.0488 4.0488 4.0488 4.0488 4.0488;4.05377 4.05377 4.05377 4.05377 4.05377 4.05377 4.05377;4.05873 4.05873 4.05873 4.05873 4.05873 4.05873 4.05873;4.06312 4.06312 4.06312 4.06312 4.06312 4.06312 4.06312;4.06753 4.06753 4.06753 4.06753 4.06753 4.06753 4.06753;4.07333 4.07333 4.07333 4.07333 4.07333 4.07333 4.07333;4.08117 4.08117 4.08117 4.08117 4.08117 4.08117 4.08117;4.08904 4.08904 4.08904 4.08904 4.08904 4.08904 4.08904;4.09911 4.09911 4.09911 4.09911 4.09911 4.09911 4.09911;4.11111 4.11111 4.11111 4.11111 4.11111 4.11111 4.11111;4.13802 4.13802 4.13802 4.13802 4.13802 4.13802 4.13802;4.16831 4.16831 4.16831 4.16831 4.16831 4.16831 4.16831]; % Open-circuit voltage, V0(SOC,T), in V
ModuleType1.R0_matCell        = [0.3026 0.35142 0.34349 0.24415 0.02095 0.15874 0.14729;0.2941 0.33555 0.32379 0.22614 0.01921 0.13363 0.12249;0.28559 0.31969 0.30408 0.20813 0.01774 0.10853 0.10276;0.27709 0.30382 0.28438 0.19012 0.0166 0.09423 0.0861;0.26858 0.28796 0.26468 0.17211 0.01557 0.07998 0.0748;0.26008 0.27209 0.24498 0.1541 0.01469 0.07024 0.06679;0.25157 0.25623 0.22527 0.1361 0.01398 0.06387 0.05877;0.24307 0.24036 0.20557 0.11861 0.01338 0.0575 0.05275;0.23456 0.2245 0.18587 0.10674 0.01283 0.05113 0.04899;0.22606 0.20863 0.16617 0.09525 0.01239 0.04679 0.04522;0.21755 0.19277 0.14651 0.08799 0.01196 0.0439 0.04145;0.20905 0.1769 0.13098 0.08073 0.01155 0.04101 0.03817;0.20054 0.16103 0.11905 0.07347 0.01116 0.03813 0.03522;0.19204 0.14769 0.11102 0.06895 0.01079 0.03524 0.03228;0.18353 0.13913 0.10517 0.06499 0.01042 0.03235 0.02934;0.17503 0.13157 0.09933 0.06104 0.01007 0.02946 0.0264;0.16653 0.1271 0.09371 0.05708 0.00974 0.02657 0.02345;0.15804 0.12264 0.09094 0.05312 0.00949 0.02417 0.02125;0.15354 0.11817 0.08816 0.04917 0.00924 0.02286 0.01972;0.14976 0.11385 0.08539 0.04748 0.009 0.02156 0.0182;0.14598 0.11213 0.08261 0.04617 0.00876 0.02025 0.01667;0.14219 0.11042 0.08103 0.04487 0.00855 0.01894 0.01515;0.14033 0.10871 0.08035 0.04356 0.00843 0.01763 0.01363;0.13876 0.10699 0.07967 0.04225 0.00832 0.01632 0.0121;0.13718 0.10528 0.07899 0.04094 0.00826 0.01501 0.01058;0.13561 0.10357 0.07831 0.03964 0.00825 0.0137 0.00906;0.13404 0.10198 0.07763 0.03833 0.00825 0.01239 0.00753;0.13247 0.10119 0.07695 0.03702 0.00826 0.01108 0.0065;0.13096 0.10039 0.07627 0.03624 0.00827 0.00977 0.00633;0.13043 0.0996 0.07559 0.03615 0.00828 0.00846 0.00617;0.1299 0.0988 0.07491 0.03606 0.0083 0.00774 0.006;0.12937 0.09801 0.07423 0.03597 0.00834 0.00779 0.00583;0.12883 0.09721 0.07355 0.03588 0.00838 0.00783 0.00567;0.1283 0.09642 0.07301 0.03579 0.00842 0.00787 0.0055;0.12777 0.09585 0.07296 0.0357 0.00848 0.00792 0.00534;0.12724 0.09584 0.07291 0.03561 0.00855 0.00796 0.00517;0.12675 0.09584 0.07286 0.03552 0.00863 0.00801 0.005;0.12643 0.09583 0.0728 0.03543 0.00871 0.00805 0.00484;0.12611 0.09582 0.07275 0.03534 0.00879 0.00809 0.00467;0.12579 0.09582 0.0727 0.03525 0.00887 0.00814 0.0045;0.12547 0.09581 0.07264 0.03526 0.00895 0.00818 0.00434;0.12514 0.0958 0.07259 0.03537 0.00903 0.00823 0.00405;0.12482 0.09579 0.07254 0.03547 0.00911 0.00804 0.00366;0.1245 0.09579 0.07248 0.03558 0.00918 0.00776 0.00327;0.12418 0.09578 0.07243 0.03568 0.00925 0.00748 0.00287;0.12386 0.09577 0.07231 0.03579 0.00931 0.0072 0.00248;0.12354 0.09576 0.0721 0.03589 0.00938 0.00692 0.00209;0.12322 0.09576 0.07189 0.036 0.00946 0.00664 0.0017;0.12301 0.09575 0.07168 0.03611 0.00953 0.00636 0.00131;0.12309 0.09574 0.07147 0.03621 0.00961 0.00608 0.00092;0.12318 0.09573 0.07125 0.0363 0.00968 0.0058 0.00053;0.12326 0.09573 0.07104 0.03637 0.00976 0.00552 0.00014;0.12389 0.09628 0.07138 0.03699 0.00991 0.00579 0.0003;0.12407 0.09637 0.07126 0.03715 0.01 0.0056 0.0003;0.12383 0.09605 0.07073 0.0369 0.01003 0.00504 0.0003;0.12359 0.09573 0.07019 0.03664 0.01006 0.00503 0.0003;0.12367 0.09573 0.06998 0.03671 0.01013 0.00534 0.00063;0.12375 0.09572 0.06975 0.03677 0.01022 0.00564 0.00094;0.1238 0.09569 0.07006 0.0368 0.0103 0.00593 0.00123;0.12372 0.09554 0.07026 0.03671 0.01037 0.00608 0.00139;0.12364 0.09537 0.07046 0.03661 0.01043 0.00623 0.00155;0.12348 0.09514 0.07058 0.03644 0.01049 0.0063 0.00163;0.12333 0.0949 0.07071 0.03627 0.01055 0.00638 0.00171;0.12312 0.09461 0.07078 0.03605 0.01061 0.00641 0.00175;0.12291 0.09433 0.07085 0.03583 0.01066 0.00643 0.00168;0.12271 0.09404 0.07093 0.03568 0.01072 0.00646 0.00161;0.12275 0.09398 0.071 0.03622 0.01077 0.00646 0.00153;0.12316 0.09449 0.07107 0.03677 0.01082 0.00636 0.00145;0.12357 0.095 0.07115 0.03731 0.01088 0.00625 0.00137;0.12398 0.09551 0.07151 0.03785 0.01093 0.00614 0.00129;0.12438 0.09601 0.07221 0.03839 0.01099 0.00602 0.0012;0.12486 0.09659 0.07299 0.039 0.01105 0.00599 0.00119;0.12548 0.09731 0.07391 0.03975 0.01114 0.00609 0.00131;0.12626 0.09818 0.07499 0.04066 0.01125 0.00634 0.0016;0.12703 0.09906 0.07606 0.04135 0.01136 0.0066 0.00188;0.1278 0.09993 0.07713 0.04182 0.01148 0.00685 0.00216;0.12885 0.10083 0.07821 0.0423 0.01161 0.00664 0.00237;0.1304 0.1025 0.07929 0.04278 0.01175 0.0064 0.00226;0.13191 0.10413 0.08033 0.04322 0.01188 0.00612 0.00212;0.1334 0.10575 0.08152 0.04366 0.01202 0.00583 0.00197;0.1349 0.10737 0.08334 0.04409 0.01215 0.00555 0.00181;0.1364 0.10899 0.08516 0.04453 0.01228 0.00526 0.00166;0.13782 0.11053 0.08691 0.04489 0.01241 0.00493 0.00143;0.13978 0.11186 0.08841 0.04501 0.01253 0.00579 0.00097;0.14193 0.11346 0.08952 0.04473 0.01261 0.00624 0.00061;0.14408 0.11506 0.09064 0.04532 0.01269 0.0067 0.00118;0.146 0.11643 0.09152 0.04583 0.01275 0.00692 0.00152;0.14899 0.11789 0.09233 0.04627 0.0128 0.00708 0.00179;0.15208 0.12161 0.09384 0.04654 0.01285 0.00706 0.00189;0.15514 0.12531 0.09564 0.04678 0.01289 0.00702 0.00196;0.15821 0.12903 0.09744 0.04702 0.01294 0.00695 0.00203;0.16375 0.13297 0.09924 0.04726 0.01298 0.00679 0.0021;0.16932 0.13677 0.10091 0.04737 0.01296 0.00651 0.00191;0.17489 0.14058 0.10295 0.04748 0.01292 0.00623 0.00143;0.18279 0.14469 0.10537 0.04791 0.01292 0.00626 0.00126;0.19983 0.14936 0.10825 0.04847 0.01288 0.00675 0.00154;0.21876 0.15772 0.11113 0.04857 0.01282 0.00686 0.00183;0.25283 0.16658 0.1145 0.04915 0.0128 0.0047 0.00241;0.28382 0.17618 0.1183 0.05016 0.01232 0.00296 0.00075;0.29564 0.18952 0.12487 0.05251 0.01214 0.00454 0.0024;0.30821 0.2036 0.13204 0.04828 0.00952 0.00687 0.00481]; % Terminal resistance, R0(SOC,T), in Ohm
ModuleType1.V_rangeCell       = [2.25,Inf]; % Terminal voltage operating range [Min Max], in V
ModuleType1.AHCell            = 4.5;        % Cell capacity, AH, A*hr

% For the thermal mass, I assume a specific heat of 760 J/(K*kg) taken
% from:  10.1016/j.ijheatmasstransfer.2020.120330 And by assuming a cell
% mass of 70 g I can estimate the thermal mass of the cell
ModuleType1.thermal_massCell  = 760*0.07;        % Thermal mass, J/K

% For the cooling path resistance we assume that the heat has to go trough
% the entire cell height (70 mm) and that the cell conductance is 30 W/(Km)
% The assumption 30 W/(K*m) was taken from https://doi.org/10.3390/batteries8020016
ModuleType1.CoolantResistance = (70*1e-3)/(30*pi*(10.5*1e-3)^2);   % Cell level coolant thermal path resistance, in K/W

% This represents the radial resistance of the cell. The value seems
% realistic and has been estimated from  https://doi.org/10.3390/batteries8020016 
ModuleType1.AmbientResistance = 1;   % Cell level ambient thermal path resistance, K/W -> Assumption from  https://doi.org/10.3390/batteries8020016 

%% Initial targets for the module
% The initial targets are set programmatically by looping trough the four module assemblies and selecting one by one all the modules
for i = 1:4 % Loop trough the four module assemblies
    eval(['ModuleAssembly',num2str(i),'=struct;']);
    for ii = 1:2 % Select each one of the two modules
        eval(['ModuleAssembly',num2str(i),'.','Module',num2str(ii),'.','iCell = 0;'])
        eval(['ModuleAssembly',num2str(i),'.','Module',num2str(ii),'.','vCell = 0;'])
        eval(['ModuleAssembly',num2str(i),'.','Module',num2str(ii),'.','socCell = SOC_start;'])
        eval(['ModuleAssembly',num2str(i),'.','Module',num2str(ii),'.','numCyclesCell = 0;'])
        eval(['ModuleAssembly',num2str(i),'.','Module',num2str(ii),'.','temperatureCell = battery_T_init + 273.15;'])
        eval(['ModuleAssembly',num2str(i),'.','Module',num2str(ii),'.','vParallelAssembly = repmat(0, 12, 1);'])
        eval(['ModuleAssembly',num2str(i),'.','Module',num2str(ii),'.','socParallelAssembly = repmat(SOC_start, 12, 1);'])
    end
end
% Suppress MATLAB editor message regarding readability of repmat
%#ok<*REPMAT>
clear i ii

%% Cooling Plate Data
% Except for the Design and Material Parameters, the other parameters have
% been left to their default values

% Plate Design Parameters
CoolingPlateBottom.nChannels     = 8;                 % Number of coolant channels
CoolingPlateBottom.channelDia    = 0.005;             % Coolant channel hydraulic diameter, m
CoolingPlateBottom.distributorDia= coolant_pipe_D;    % Distributor pipe diameter, m
CoolingPlateBottom.roughnessPipe = 1.5e-05;           % Coolant channel and distributor roughness, m

% Plate Material Parameters
CoolingPlateBottom.plateTh       = 2e-3;              % Thickness of cooling plate material, m
CoolingPlateBottom.plateThCond   = 200;               % Thermal conductivity of cooling plate material in W/(m*K) -> Assumption: Plate is made out of Aluminum
CoolingPlateBottom.plateDen      = 2700;              % Density of cooling plate material in kg/m^3 -> Assumption: Plate is made out of Aluminium
CoolingPlateBottom.plateCp       = 900;               % Specific heat of cooling plate material in J/(K*kg) -> Assumption: Plate is made out of Aluminium
CoolingPlateBottom.plateTemp_ini = plate_T_init+273.15; % Initial temperature of the cooling plate and the coolant fluid, K

% Fluid Properties Parameters 
CoolingPlateBottom.Re_lam        = 2000; % Reynolds number upper limit for laminar flow
CoolingPlateBottom.Re_tur        = 4000; % Reynolds number lower limit for turbulent flow
CoolingPlateBottom.Nu_lam        = 3.66; % Nusselt number for laminar flow heat transfer
CoolingPlateBottom.length_add    = 1e-3; % Aggregate equivalent length of local resistances, m
CoolingPlateBottom.shape_factor  = 64; % Laminar friction constant for Darcy friction factor

% Cooling plate interface parameters (DO NOT CHANGE)
CoolingPlateBottom.plateDimX                = 2; % Number of partitions in X dimension for the cooling plate
CoolingPlateBottom.plateDimY                = 1; % Number of partitions in Y dimension for the cooling plate
CoolingPlateBottom.numBattThermalNodes1     = 8; % Number of battery thermal nodes (surface 1)
CoolingPlateBottom.dimensionThermalNodes1   = [0.7206 0.2696;0.7206 0.2696;0.7206 0.2696;0.7206 0.2696;0.7206 0.2696;0.7206 0.2696;0.7206 0.269599999999998;0.7206 0.269599999999998]; % Dimension of battery thermal nodes (surface 1)
CoolingPlateBottom.locationThermalNodes1    = [0.3603 0.1348;1.0819 0.1348;0.3603 0.4944;1.0819 0.4944;0.3603 0.854;1.0819 0.854;0.3603 1.2136;1.0819 1.2136]; % Coordinates of battery thermal nodes (surface 1)

%% E-Drive Data
% Data used for the electric drive
Edrive.max_torque = 200;   % Torque max in Nm of the motor 
Edrive.max_power  = 100e3; % Power in W of the motor (max power)
Edrive.Tctc       = 0.002; % Motor torque control time constant(s)

% This is the loss data used in the model of the standard BEV
Edrive.loss_maps         = load('eDriveLossMaps.mat');
Edrive.transmissionRatio = 9;
Edrive.gearboxEff        = 0.97;

%% DCDC converter
% Voltage demand and power from Audi documents, efficiency as a default value
DCDC.DCDCEff        = 0.8;   % Efficiency DC DC converter
DCDC.DCDCOutputVltg = 12;    % in V
DCDC.DCRatedPwr     = 3000;  % in W