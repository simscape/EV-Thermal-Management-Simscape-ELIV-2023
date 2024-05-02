%% Description: Code to plot simulation results from energyAcct_ElectroMech
% Copyright 2023-2024 The MathWorks, Inc.

%% Get simulation results
simTime     = simlog_energyAcct_ElectroMech.Battery.i.series.time;
trqMotIs    = simlog_energyAcct_ElectroMech.Motor.t.series.values('N*m');
trqMotRef   = simlog_energyAcct_ElectroMech.PS_Switch.O.series.values('N*m');
wMot        = simlog_energyAcct_ElectroMech.Motor.w.series.values('rpm');
stateOfChrg = simlog_energyAcct_ElectroMech.Battery.stateOfCharge.series.values;
currBatt    = simlog_energyAcct_ElectroMech.Battery.i.series.values('A');

%% Reuse figure if it exists, else create new figure
if ~exist('h1_energyAcct_ElectroMech', 'var') || ...
        ~isgraphics(h1_energyAcct_ElectroMech, 'figure')
    h1_energyAcct_ElectroMech = figure('Name', 'energyAcct_ElectroMech');
end
figure(h1_energyAcct_ElectroMech)
clf(h1_energyAcct_ElectroMech)

%% Plot results
ah(1) = subplot(3,1,1);
plot(simTime/60, -trqMotIs,'LineWidth', 2,'DisplayName','Measured');
hold on
plot(simTime/60, trqMotRef,'LineStyle','--', 'LineWidth', 2,'DisplayName','Command');
hold off
title('Motor Torque','FontSize',11)
legend('Location','Best','FontSize',10);
ylabel('N*m','FontSize',11);
set(gca,'Xlim',[0,simTime(end)/60]); grid on

ah(2) = subplot(3,1,2);
plot(simTime/60, wMot,'LineWidth', 2);
title('Rotor Speed','FontSize',11)
ylabel('rpm','FontSize',11);
set(gca,'Xlim',[0,simTime(end)/60]); grid on

ah(3) = subplot(3,1,3);
yyaxis left
plot(simTime/60, stateOfChrg,'LineWidth', 2);
ylabel('SOC (0-1)','FontSize',11);
yyaxis right
plot(simTime/60, currBatt,'LineWidth', 2);
ylabel('A','FontSize',11);
title('Battery SOC and Current','FontSize',11)
xlabel('Time (min)','FontSize',11);
set(gca,'Xlim',[0,simTime(end)/60]); grid on

%ah(4) = subplot(2,2,4);
%xlabel('Time in s');
%set(gca,'Xlim',[0,simTime(end)/60]); grid on