%% 1) Check for pre-existing simulation results

% Generate simulation results if they don't exist
if ~exist('simres', 'var')
    simres = sim('BEV_Thermal_Management');
end

if ~exist('vehEnergies', 'var')
    vehEnergies=calcVehicleEnergy(simres.sscThermalManagement);
end

%% 2) Retrieve the required data and create the figure

% Get the data
vehSpeed = vehEnergies.vehSpeed*3.6;   % in km/h
vehDist  = vehEnergies.vehDist;        % in kilometers
vehTime  = vehEnergies.simTime/60;     % in minutes

% Reuse figure if it exists, else create new figure
if ~exist('h1_drive_charge_scenario', 'var') || ...
        ~isgraphics(h1_drive_charge_scenario, 'figure')
    h1_drive_charge_scenario = figure('Name', 'drive_charge_scenario');
end
figure(h1_drive_charge_scenario)
clf(h1_drive_charge_scenario)

% Color data used for the y-axes [left, right]
Colors = [0,0,0; 215, 136, 36]/255;
colororder(Colors); hold on;


%% 3) Plot the speed and driven distance profile

% Plot vehicle speed over time
plot(vehTime,vehSpeed,'LineWidth',2,'Color',[0,0,0])

% Set up axes (left side):
ylabel('Speed in km/h'); xlabel('Time in min');
set(gca, 'YLim', [0,1.1*max(vehSpeed)]);

% Plot the driven distance over time
yyaxis right
plot(vehTime,vehDist,'LineWidth',2,'Color',Colors(2,:))
ylabel('Distance in km')
set(gca, 'XLim', [0,max(vehTime)],'FontSize',11);

title('Drive and Charge Scenario')