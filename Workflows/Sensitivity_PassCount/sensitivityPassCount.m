%% Sensitivity analysis passenger count
% In this test we will gradually increase the number of passengers from 1
% to 5. Each time a passenger is added, the mass of the vehicle increases
% and the heat developed in the cabin increases as well. 
%-----------------
% Copyright 2022-2023 The MathWorks, Inc.
%-----------------

% Open model if necessary
mdl = 'BEV_Thermal_Management';
if(~bdIsLoaded(mdl))
    open_system(mdl)
end


%% 1) Set links and initial parameters

% Block of the variable that will be changed
linkBlock = [mdl,'/Scenario/Number of Occupants'];

% Ensure that the cabin setpoint temperature is set to 22°C
setpointCabinT = [mdl,'/Scenario/Temperature Setpoint [degC]'];
set_param(setpointCabinT,'Value','22');

% Set model to fast restart
set_param(mdl, 'FastRestart', 'on');

%% 2) Perform sensitivity analysis
% Increase the number of passengers stepwise
clear passNumbEn
for i = 1:5

    % Increase number of passengers at each iteration
    set_param(linkBlock,'Value',num2str(i));

    % After setting the parameters, simulate and save the results
    simres = sim('BEV_Thermal_Management');
    passNumbEn(i)   = calcVehicleEnergy(simres.sscThermalManagement);
end

for i = 1:5
    passNumbEn(i).numPass = i;
end

% Turn off fast restart
set_param(mdl, 'FastRestart', 'off');

% Link where the results will be saved
temp_thisFolder     =  fileparts(which(mfilename));
saveLink = [temp_thisFolder filesep 'sensitivityPssCnt.mat'];

save(saveLink,'passNumbEn');

%% 3) Create tabular comparison of the simulations (Table 1 of the paper)
%Name of the rows of the tables
RNames={'1 Passenger'; '5 Passengers';'Delta'};
    
% Store the vartipes
celli=cell(1,7); celli(:)={'string'};
    
%Create the table to store the results
T=table('Size',[numel(RNames),7],'VariableTypes',celli,'RowNames',RNames);
T.Properties.VariableNames = {'Charged', 'E-Motor' , 'Gearbox', 'HVAC','Tires', 'Drag','Rem'};

% Fill out the table
T = compile_table(T,'Charged',passNumbEn(1).energyCharger,passNumbEn(end).energyCharger);
T = compile_table(T,'E-Motor',passNumbEn(1).energyLossEM,passNumbEn(end).energyLossEM);
T = compile_table(T,'Gearbox',passNumbEn(1).energyLossGrbx,passNumbEn(end).energyLossGrbx);
T = compile_table(T,'HVAC',   passNumbEn(1).energyHvac,passNumbEn(end).energyHvac);
T = compile_table(T,'Tires',   passNumbEn(1).energyLossTires,passNumbEn(end).energyLossTires);
T = compile_table(T,'Drag',   passNumbEn(1).energyLossDrag,passNumbEn(end).energyLossDrag);
T = compile_table(T,'Rem',   passNumbEn(1).energyBatteryRest,passNumbEn(end).energyBatteryRest);

%% 4) Analyze the differences in term of loaded power, range prevision and so on.
% Retrieve expected range, consumption, and charged energy
range_exp     = [passNumbEn.rangeExpected];
cons_driving  = [passNumbEn.consDriving];
loaded_energy = [passNumbEn.energyCharger];

% Assess how much the value change at each simulation
delta_range  = diff(range_exp);
delta_cons   = diff(cons_driving);
delta_energy = diff(loaded_energy);
delta_cost =  delta_energy*0.62; % We account for a price of 62cent/kWh, see paper

% Display results
fprintf('The mean range reduction per passenger is %.1f km\n', mean(delta_range));
fprintf('The mean consumption per passenger is %.1f kWh\n', mean(delta_cons));
fprintf('The additional recharged energy per passenger is %.1f kWh\n', mean(delta_energy));
fprintf('The additional cost energy per passenger is %.1f euro\n', mean(delta_cost));

%% Subfunction:
function T = compile_table(T,field,var1,var2)

T{1,field} = {sprintf('%.2f %s',var1,'kWh')};
T{2,field}  = {sprintf('%.2f %s',var2,'kWh')};
T{3,field}  = {sprintf('%.2f%%',100*(var2-var1)/var1)};
end