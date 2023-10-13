%% This script creates the Figure 6 of the paper
% Description: This script creates the figures for figure 6 of the paper
%              For this case the simulated vehicle had 1 passenger and a setpoint
%              temperature of 22°C for the cabin (also compare the paper).
%              Remember to check that the vehicle has the right
%              parameterization because the script will otherwise start a
%              new simulation with whatever vehicle is parameterized in the
%              model
%-----------------
% Copyright 2022-2023 The MathWorks, Inc.
%-----------------

%% 1) Check for pre-existing simulation results
% Generate simulation results if they don't exist
if ~exist('simres', 'var')
    simres = sim('BEV_Thermal_Management');
end

if ~exist('vehEnergies', 'var')
    vehEnergies=calcVehicleEnergy(simres.sscThermalManagement);
end

%% 2) Create Barplot with the consumption at the system level
plotVehicleEnergy(vehEnergies);

% Set axes and figure dimensions
ax= gca; ax.Title.String = ''; ax.Box = 'off';
set(gcf,'Units','centimeters','Position', [0,0,14.9,5]);

% Assemble location for saving figure
temp_thisFolder     =  fileparts(which(mfilename));
figFolder = [temp_thisFolder filesep 'Figures'];
if(~isfolder(figFolder))
    mkdir(figFolder)
end

% Save the figure
print(gcf,[figFolder filesep 'FigTotConsBarplot'],'-djpeg','-r400')

%% 3) Create Barplot with the consumption at the HVAC level
plotHVACEnergy(vehEnergies);

% Set axes and figure dimensions
ax= gca; ax.Title.String = ''; ax.Box = 'off';
set(gcf,'Units','centimeters','Position', [0,0,14.9,5]);

% Save the figure
print(gcf,[figFolder filesep 'FigHVACConsBarplot'],'-djpeg','-r400')