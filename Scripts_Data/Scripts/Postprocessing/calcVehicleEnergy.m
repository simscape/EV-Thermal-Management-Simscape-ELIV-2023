function out=calcVehicleEnergy(slog)
% Description: After simulating the vehicle this function postprocess the
%              Simscape results to estimate the power losses and the energy consumption
%              of each component of the vehicle
%-----------------
% Inputs: slog: This is the Simscape part of the Simulation output: simres.sscThermalManagement
%-----------------
% Outputs: out: The results are stored in the out structure
%-----------------
% Function Call Example: vehEnergies = calcVehicleEnergy(simres.sscThermalManagement);
%-----------------
%
% Copyright 2022-2024 The MathWorks, Inc.
%-----------------

%% 1) Preprocessing
% Recover vehicle data to calculate the vehicle losses later on
mdlWks = get_param('BEV_Thermal_Management','ModelWorkspace');
vehStruct = getVariable(mdlWks,'Veh');
vehMass = getVariable(mdlWks,'vehMass')+mean(slog.Driveline.Vehicle.mass_load.series.values('kg'));

% Retrieve simulation time, vehicle speed and driven distance
simTime   = slog.DCDC.DCDC.power_dissipated.series.time;
vehSpeed  = slog.Driveline.Vehicle.v.series.values('m/s');
vehDist   = cumtrapz(simTime,vehSpeed)/1000;                  % Driven distance in km

%% 2) Collect simulation data
%% 2.0) Charger
% Collect the energy provided by the charger
chargPwr = slog.Charger.PWRS2.Power_Sensor.P.series.values('W');
chargEn = cumtrapz(simTime, chargPwr)/3600/1000;

%% 2.1) Battery
% Collect energy, power, SOC, etc.
batSOC         = slog.Battery.Battery.ModuleAssembly1.Module1.socCell.series.values;
batEnMax       = 49.766;               % Energy of the battery in kWh when fully charged -> from the generated pack use propriety CumulativeEnergy
batEnStart     = batEnMax*batSOC(1);
batPwr         = slog.Battery.PWRS1.Power_Sensor.P.series.values('W');
batEn          = cumtrapz(simTime, slog.Battery.PWRS1.Power_Sensor.P.series.values('W'))/3600/1000;

%% 2.2) Electric Machine
% Machine Power and losses
EMPwrLoss   = slog.Motor.Motor.power_dissipated.series.values('W');
EMEnLoss    = cumtrapz(simTime,EMPwrLoss)/1000/3600;
EMSpd       = slog.Motor.Motor.w.series.values('rad/s');

%% 2.3) Gearbox
% Gearbox, no direct port for power losses. The losses are calculated from the difference between input and output energy
grbPwrIn   = slog.Motor.PWRS4.Power.P.series.values('W');
grbPwrOut  = slog.Motor.PWRS5.Power.P.series.values('W');
grbEnLoss  = cumtrapz(simTime,grbPwrIn-grbPwrOut)/3600/1000; % in kW

%% 2.4) HVAC System
% Includes all components for cooling and heating as well as the DCDC converter
% Includes: Fan, Blowe, Compressor, DCDC, EM and Battery Pumps
hvac = calcHVACEnergy(slog);

% Total power and energy of HVAC
hvacpwr = hvac.pwrtot;
hvacEN  = cumtrapz(simTime,hvacpwr)/1000/3600;

%% 2.5) Tires:
% No power port for the tire. Compare difference between axle power (from the gearbox) and
% translational power passed to the vehicle body
tirePwrOut = slog.Driveline.PWRS6.Power.O.series.values('W');
tireEnLoss  = cumtrapz(simTime, grbPwrOut-tirePwrOut)/1000/3600;
tireSpd = slog.Driveline.Tires_RR.tire_inertia.I.w.series.values('rad/s');

%% 2.6) Aerodynamic Losses:
dragPwrLoss = 1.18*0.5*vehStruct.AVeh*vehStruct.cD*(vehSpeed).^3;
dragEnLoss  = cumtrapz(simTime,dragPwrLoss)/3600/1000;

%% 2.7) Calculate the energy stored in the vehicle
% If the vehicle is still moving when the simulation is stopped, there is
% still energy stored in the vehicle and wheels. We have to account for this

% Kinetic energy stored in the vehicle in Wh
vehEnStrd = vehMass*0.5*(vehSpeed.^2)/3600;

% Kinetic energy stored in the tires in Wh
tireEnStrd = (1/3600)*4*vehStruct.tireJ*0.5*(tireSpd).^2;

% Kinetic energy stored in the motor in Wh
EMEnStrd = 0.5*(5e-6)*(EMSpd.^2)/3600;

% Total kinetic energy in kWh: 
totEnStrd = (tireEnStrd + EMEnStrd + vehEnStrd)/1000;

%% 2.8) Estimate the remaining range of the vehicle based on the mean consumption
% Remaining energy in the battery
batEnRest = batEnStart - batEn(end);

% Power consumed in the driving phase
vehPwrDriving = batPwr;
vehPwrDriving(vehSpeed<0.05)=0;

% Energy consumed in the driving phase, consumption and expected range
vehEnDriving  = cumtrapz(simTime, vehPwrDriving)/1000/3600;
vehCnsmptn    = 100*vehEnDriving(end)/vehDist(end);
vehExpctRange = 100*batEnRest/vehCnsmptn;

%% 3) Balance Energy to check that everything is modeled correctly

% This is the energy that should be left in the battery at the end of the cycle
batEnLeft = batEnStart - batEn(end);

% Disp the value that the battery should have at the end of the simulation.
% Compare this value with the Sankey Diagram plotted in the next step
%disp(['The remaining battery energy is ',num2str(batEnLeft(end)),' Wh']);

% Check energy balance during charging
%balanceChargeEnergy(slog)

%% 4) Assign outputs
% Energies in kWh
out.energyCharger      = chargEn(end);
out.energyBattery      = batEn(end);
out.energyBatteryStart = batEnStart;
out.energyLossEM       = EMEnLoss(end);
out.energyLossGrbx     = grbEnLoss(end);
out.energyHvac         = hvacEN(end);
out.energyLossTires    = tireEnLoss(end);
out.energyLossDrag     = dragEnLoss(end);
out.energyVehStrd      = totEnStrd(end);
out.energyBatteryRest  = batEnRest;

% Power in W
out.pwrCharger         = chargPwr;
out.pwrBattery         = batPwr;
out.SOC                = batSOC;
out.pwrLossEM          = EMPwrLoss;
out.pwrGrbx            = grbPwrIn;
out.hvac               = hvac;
out.pwrTires           = tirePwrOut;
out.pwrLossDrag        = dragPwrLoss;
out.consDriving        = vehCnsmptn;
out.rangeExpected      = vehExpctRange;

% Distances 
out.vehSpeed           = vehSpeed;          
out.vehDist            = vehDist;
out.simTime            = simTime;
end
