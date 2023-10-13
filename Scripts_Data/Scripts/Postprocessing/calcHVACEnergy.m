function out = calcHVACEnergy(slog)
% Description: After simulating the vehicle, this  
% this output of the function is reused here to
%              represent the HVAC consumption as a bar plot
%-----------------
% Inputs: slog: This is the Simscape part of the Simulation output: simres.sscThermalManagement
%-----------------
% Outputs: out: The results are stored in the out structure
%-----------------
% Copyright 2022-2023 The MathWorks, Inc.
%-----------------

% Get Simulation time 
simTime = slog.Battery.Battery_voltage.V.series.time;

%% Compressor
cmprsPwr = slog.Compressor.Compressor.power.series.values('W');
cmprsEn  = trapz(simTime,cmprsPwr)/3600/1000;

%% DCDC
% Estimate the losses in the power transmission between HV and LV networks
DCDCPwrLoss = slog.DCDC.DCDC.power_dissipated.series.values('W');
DCDCEnLoss  = trapz(simTime, DCDCPwrLoss)/3600/1000;

%% Cooling fan
fanPwr = slog.Condenser.Fan.mechanical_power.series.values('W');
fanEn  = trapz(simTime,fanPwr)/3600/1000;

%% Motor and Battery pumps
batPumpPwr = slog.Battery_Pump.Battery_Pump.mechanical_power.series.values('W');
EMPumpPwr  = slog.Motor_Pump.Motor_Pump.mechanical_power.series.values('W');

% Calculate in Wh and sum up
batPumpEn  = trapz(simTime,batPumpPwr)/3600/1000;
EMPumpEn   = trapz(simTime,EMPumpPwr)/3600/1000;
PumpsEn    = batPumpEn+EMPumpEn;

%% Cabin blower
blowPwr = slog.Blower.Blower.power.series.values('W');
blowEn   = trapz(simTime,blowPwr)/3600/1000;

%% Heater:
heaterPwr = slog.Heater.Controlled_Heat_Flow_Rate_Source.Q.series.values('W');
heaterEn  = trapz(simTime, heaterPwr)/3600/1000;

%% PTC Heater:
PTCPwr = slog.PTC.Controlled_Heat_Flow_Rate_Source.Q.series.values('W');
PTCEn  = trapz(simTime, PTCPwr)/3600/1000;

%% Cabin heat losses
% The heat that goes from the outside to heat up the cabin
cabinHeat = slog.Cabin.Cabin.Heat_Flow_to_Outside.Q.series.values('W');
cabinEn   = trapz(simTime,cabinHeat)/3600/1000;

%% Assign outputs:
% Energies in kWh
out.energyCmpr    = cmprsEn;
out.energyFan     = fanEn;
out.energyPmps    = PumpsEn;
out.energyBlwr    = blowEn;
out.energyCbn     = cabinEn;
out.energyDCDC    = DCDCEnLoss;
out.energyHeater  = heaterEn;
out.energyPTC     = PTCEn;
out.energyHVACtot = cmprsEn+ PumpsEn + blowEn + fanEn + DCDCEnLoss;

% Simulation time in sec
out.simTime       = simTime;

% Power in W
out.pwrFan        = fanPwr;
out.pwrBlwr       = blowPwr;
out.pwrCmpr       = cmprsPwr;
out.pwrPmps       = EMPumpPwr+batPumpPwr;
out.pwrDCDC       = DCDCPwrLoss;
out.pwrHeater     = heaterPwr;
out.pwrPTC        = PTCPwr;
out.pwrtot        = EMPumpPwr+batPumpPwr+cmprsPwr+blowPwr+fanPwr+DCDCPwrLoss+heaterPwr + PTCPwr;
out.heatCbn       = cabinHeat;
end