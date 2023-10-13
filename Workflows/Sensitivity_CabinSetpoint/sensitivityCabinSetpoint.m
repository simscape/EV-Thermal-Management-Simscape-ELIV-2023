%% Sensitivity analysis passenger count
% In this test we will gradually increase the cabin setpoint temperature
% from 22°C to 32°C. The vehicle is simulated with a constant passenger count of 5 
%-----------------
% Copyright 2022-2023 The MathWorks, Inc.
%-----------------

% Open model if necessary
mdl = 'BEV_Thermal_Management';
if(~bdIsLoaded(mdl))
    open_system(mdl)
end

%% 1) Set links and initial parameters
% Ensure that the number of passenger is set to 5
passNumber = [mdl '/Scenario/Number of Occupants'];
set_param(passNumber,'Value','5');

% Get handle to the setpoint temperature block:
setpointCabinT = [mdl '/Scenario/Temperature Setpoint [degC]'];

% Set model to fast restart
set_param(mdl, 'FastRestart', 'on');

%% 2) Perform sensitivity analysis
% Increase the cabin temperature stepwise
cabinTset = linspace(22,32,6); % Temperature vector
clear setpointCabinEn
for i = 1:numel(cabinTset)

    % Increase number of passengers at each iteration
    set_param(setpointCabinT,'Value',num2str(cabinTset(i)));

    % After setting the parameters, simulate and save the results
    simres = sim('BEV_Thermal_Management');
    setpointCabinEn(i) = calcVehicleEnergy(simres.sscThermalManagement);
end

for i = 1:numel(cabinTset)
    setpointCabinEn(i).cabinSetpointTemp = cabinTset(i);
end

% Turn off fast restart
set_param(mdl, 'FastRestart', 'off');


% Link where the results will be saved
temp_thisFolder     =  fileparts(which(mfilename));
saveLink = [temp_thisFolder filesep 'sensitivityCbnStp.mat'];

save(saveLink,'setpointCabinEn');

%% 3) Create tabular comparison of the simulations
%Name of the rows of the tables
RNames={sprintf('%0.1f degC',cabinTset(1)); sprintf('%0.1f degC',cabinTset(end));'Delta'};

%Store the vartipes
celli=cell(1,7); celli(:)={'string'};

%Create the table to store the results
T=table('Size',[numel(RNames),7],'VariableTypes',celli,'RowNames',RNames);
T.Properties.VariableNames = {'Charged', 'E-Motor' , 'Gearbox', 'HVAC','Tires', 'Drag','Rem'};

% Fill out the table
T = compile_table(T,'Charged',setpointCabinEn(1).energyCharger,setpointCabinEn(end).energyCharger);
T = compile_table(T,'E-Motor',setpointCabinEn(1).energyLossEM,setpointCabinEn(end).energyLossEM);
T = compile_table(T,'Gearbox',setpointCabinEn(1).energyLossGrbx,setpointCabinEn(end).energyLossGrbx);
T = compile_table(T,'HVAC',   setpointCabinEn(1).energyHvac,setpointCabinEn(end).energyHvac);
T = compile_table(T,'Tires',   setpointCabinEn(1).energyLossTires,setpointCabinEn(end).energyLossTires);
T = compile_table(T,'Drag',   setpointCabinEn(1).energyLossDrag,setpointCabinEn(end).energyLossDrag);
T = compile_table(T,'Rem',   setpointCabinEn(1).energyBatteryRest,setpointCabinEn(end).energyBatteryRest);

%% 4) Analyze the differences in term of loaded power, range prevision and so on.
% Retrieve expected range, consumption, and charged energy
range_exp     = [setpointCabinEn.rangeExpected];
cons_driving  = [setpointCabinEn.consDriving];
loaded_energy = [setpointCabinEn.energyCharger];

% Assess how much the value change at each simulation
delta_range  = diff(range_exp);
delta_cons   = diff(cons_driving);
delta_energy = diff(loaded_energy);
delta_cost =  delta_energy*0.62;

% Display results
fprintf('The mean range reduction per passenger is %.1f km\n', mean(delta_range));
fprintf('The mean consumption per passenger is %.1f kWh\n', mean(delta_cons));
fprintf('The additional recharged energy per passenger is %.1f kWh\n', mean(delta_energy));
fprintf('The additional cost energy per passenger is %.1f euro\n', mean(delta_cost));

%% Subfunctions
function T = compile_table(T,field,var1,var2)

T{1,field}  = {sprintf('%.2f %s',var1,'kWh')};
T{2,field}  = {sprintf('%.2f %s',var2,'kWh')};
T{3,field}  = {sprintf('%.2f%%',100*(var2-var1)/var1)};
end