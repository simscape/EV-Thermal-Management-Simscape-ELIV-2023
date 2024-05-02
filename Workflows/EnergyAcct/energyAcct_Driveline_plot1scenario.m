%% Plot Description:
% Code to plot simulation results from energyAcct_Driveline
%

% Copyright 2023-2024 The MathWorks, Inc.


%% Get simulation results
simlog_t   = simlog_energyAcct_Driveline.Power_Sensor_Input_Gearbox.P.series.time;

simlog_trq     = -simlog_energyAcct_Driveline.Torque_Source.t.series.values('N*m');
simlog_wind    =  simlog_energyAcct_Driveline.Vehicle.wind.series.values('m/s');
simlog_incline =  simlog_energyAcct_Driveline.Vehicle.beta.series.values('deg');

simlog_v       = simlog_energyAcct_Driveline.Vehicle.V.series.values('km/hr');
simlog_p       = cumtrapz(simlog_t,simlog_v)/3600;

%% Reuse figure if it exists, else create new figure
if ~exist('h1_energyAcct_Driveline', 'var') || ...
        ~isgraphics(h1_energyAcct_Driveline, 'figure')
    h1_energyAcct_Driveline = figure('Name', 'energyAcct_Driveline');
end
figure(h1_energyAcct_Driveline)
clf(h1_energyAcct_Driveline)

%% Plot results
ah(1) = subplot(3,1,1);
plot(simlog_t, simlog_trq,'LineWidth', 2)
ylabel ('N*m','FontSize',11)
title('Input Torque','FontSize',11)
grid on

ah(2) = subplot(3,1,2);
yyaxis left
plot(simlog_t, simlog_wind,'LineWidth', 2)
ylabel ('m/s','FontSize',11)
yyaxis right
plot(simlog_t, simlog_incline,'--','LineWidth', 2)
ylabel ('deg','FontSize',11)
title('Wind Speed (>0 is Headwind), Incline (deg)','FontSize',11)
grid on

ah(3) = subplot(3,1,3);
yyaxis left
plot(simlog_t, simlog_p,'--','LineWidth', 2)
ylabel('km','FontSize',11)
yyaxis right
plot(simlog_t, simlog_v,'LineWidth', 2)
ylabel('km/hr','FontSize',11)

title('Position and Speed','FontSize',11)
xlabel('Time (s)','FontSize',11)

grid on


%% Remove temporary variables
