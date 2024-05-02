% Description: This script plots the Energy Accounting of the model
%              energyAcct_ElectroMech by visualizing input energy, 
%              losses, and stored energy
%-----------------
% Copyright 2022-2023 The MathWorks, Inc.
%-----------------

mdl = 'energyAcct_ElectroMech';

if ~exist(['simlog_' mdl], 'var')
    open_system(mdl)
    sim(mdl)
end

%% Get Time Vector
simTime     = simlog_energyAcct_ElectroMech.Inertia.w.series.time;

%% Battery
% External Energy Input 
% None

% Energy Losses
powerInst.Battery.losses  = simlog_energyAcct_ElectroMech.Battery.power_dissipated.series.values('W');
lossesCml.Battery         = cumtrapz(simTime,powerInst.Battery.losses)/3600;
lossesTot.Battery         = lossesCml.Battery(end);

% Energy Stored
% Challenging to calculate, as usable energy depends on conditions of discharge
% Calculate portion of stored energy that is used 
% Stored Energy used during test = power output + power dissipated

% Power output
powerInst.BatteryP = simlog_energyAcct_ElectroMech.Power_Sensor_Output_Battery.P.series.values('W');
cumTrapP            = cumtrapz(simTime, powerInst.BatteryP)/3600; 

% Subtract from maximum value to get energy stored that was used
storedCml.Battery = max(cumTrapP)-cumTrapP + max(lossesCml.Battery)-lossesCml.Battery;
storedTot.Battery = storedCml.Battery(1); % Stored at start of simulation

%% Resistor
% External Energy Input
% none

% Energy Stored
% none

% Energy Losses
powerInst.Resistor = simlog_energyAcct_ElectroMech.Resistor.power_dissipated.series.values('W');
lossesCml.Resistor = cumtrapz(simTime,powerInst.Resistor)/3600;
lossesTot.Resistor = lossesCml.Resistor(end);

%% Motor

% External Energy Input
% none

% Energy Stored: Kinetic
rotorSpeed             = simlog_energyAcct_ElectroMech.Motor.w.series.values('rad/s');
rotorInertia           = str2double(get_param([mdl '/Motor'],'J'));
storedCml.Motor        = (0.5*rotorInertia.*rotorSpeed.^2)/3600;

% Energy Losses: Electrical
lossesCml.MotorElect = cumtrapz(simTime, simlog_energyAcct_ElectroMech.Motor.power_dissipated.series.values('W'))/3600;
lossesTot.MotorElect = lossesCml.MotorElect(end);

% Energy Losses: Damping
rotorDamping           = str2double(get_param([mdl '/Motor'],'lam'));
powerInst.MotorDamping = rotorDamping.*rotorSpeed.^2;
lossesCml.MotorDamping = cumtrapz(simTime, powerInst.MotorDamping)/3600;
lossesTot.MotorDamping = lossesCml.MotorDamping(end);

clear rotorInertia rotorDamping rotorSpeed

%% Inertia

% External Energy Input
% none

% Energy Stored: Kinetic
inertiaInertia = str2double(get_param([mdl '/Inertia'],'inertia'));
inertiaSpeed   = simlog_energyAcct_ElectroMech.Inertia.w.series.values('rad/s');
storedCml.Inertia = (0.5*inertiaInertia*inertiaSpeed.^2)/3600;

% Energy Losses
% none

%% Plot Energy Totals in Time

setOfColors = summer;
InputColors  = setOfColors(1:60:end,:);
setOfColors = autumn;
LossesColors  = setOfColors(60:60:end,:);
setOfColors = cool;
StoredColors  = setOfColors(1:40:end,:);

if ~exist('h3_energyAcct_ElectroMech', 'var') || ...
        ~isgraphics(h3_energyAcct_ElectroMech, 'figure')
    h3_energyAcct_ElectroMech = figure('Name', 'energyAcct_ElectroMech');
end
figure(h3_energyAcct_ElectroMech)
clf(h3_energyAcct_ElectroMech)

plot(simTime,storedCml.Motor,...
    'Color',StoredColors(2,:),'LineWidth',2,'DisplayName','Stored Motor Kinetic');
hold on
plot(simTime,storedCml.Inertia,...
    'Color',StoredColors(3,:),'LineWidth',2,'DisplayName','Stored Inertia Kinetic');
plot(simTime,storedCml.Battery,...
    'Color',StoredColors(4,:),'LineWidth',2,'DisplayName','Stored Battery');

plot(simTime,storedCml.Motor(1)+storedCml.Inertia(1)+storedCml.Battery(1)+zeros(size(simTime)),...
    'c','LineWidth',3,'DisplayName','Total Input+Initial Stored');

plot(simTime,storedCml.Battery+storedCml.Motor+storedCml.Inertia,...
    'Color',StoredColors(1,:),'LineStyle','-.','DisplayName',' Total Stored');

plot(simTime,lossesCml.Battery,...
    'Color',LossesColors(1,:),'LineWidth',2, 'DisplayName','Losses Battery');
plot(simTime,lossesCml.Resistor,...
    'Color',LossesColors(2,:),'LineWidth',2, 'DisplayName','Losses Resistor');
plot(simTime,lossesCml.MotorElect,...
    'Color',LossesColors(3,:),'LineWidth',2,'DisplayName','Losses Motor Electrical');
plot(simTime,lossesCml.MotorDamping,...
    'Color',LossesColors(4,:),'LineWidth',2,'DisplayName','Losses Motor Damping');
plot(simTime,lossesCml.Battery+lossesCml.Resistor+lossesCml.MotorElect+lossesCml.MotorDamping,...
    'r-.','DisplayName','  Total Losses');


plot(simTime,lossesCml.Battery+lossesCml.Resistor+lossesCml.MotorElect+lossesCml.MotorDamping+...
    +storedCml.Battery+storedCml.Motor+storedCml.Inertia,...
    'k--','LineWidth',2,'DisplayName','Losses+Stored');

hold off

title('Cumulative Energy vs. Time')
xlabel('Time (s)')
ylabel('Energy (Wh)')
legend('Location','Best')


%% Area Plot

setOfColors = summer;
InputColors  = setOfColors(1:60:end,:);
setOfColors = autumn;
LossesColors  = setOfColors(60:60:end,:);
setOfColors = cool;
StoredColors  = setOfColors(1:40:end,:);

EnergySummary = []; aLeg = [];
EnergySummary(:,1) = lossesCml.Battery;        aLeg{1} = 'Losses Battery';
EnergySummary(:,2) = lossesCml.Resistor;       aLeg{2} = 'Losses Resistor';
EnergySummary(:,3) = lossesCml.MotorElect;     aLeg{3} = 'Losses Motor Electrical';
EnergySummary(:,4) = lossesCml.MotorDamping;   aLeg{4} = 'Losses Motor Mechanical';

EnergySummary(:,5) = storedCml.Motor;          aLeg{5} = 'Stored Motor Kinetic';
EnergySummary(:,6) = storedCml.Inertia;        aLeg{6} = 'Stored Inertia Kinetic';
EnergySummary(:,7) = storedCml.Battery;        aLeg{7} = 'Stored Battery';

if ~exist('h4_energyAcct_ElectroMech', 'var') || ...
        ~isgraphics(h4_energyAcct_ElectroMech, 'figure')
    h4_energyAcct_ElectroMech = figure('Name', 'energyAcct_ElectroMech');
end
figure(h4_energyAcct_ElectroMech)
clf(h4_energyAcct_ElectroMech)

area_h=area(simTime,EnergySummary);
hold on
Initial_Input = storedCml.Battery(1)*ones(size(simTime));
sum_h=plot(simTime,Initial_Input,'k--','LineWidth',2,'DisplayName','Energy Input');
hold off

ESumTot=sum(EnergySummary,2);
Ini_Inp = Initial_Input(end);

aLeg{8} = sprintf('%s %s',...
    'Input+Initial',['(Err: ' sprintf('%3.1e',(ESumTot(end)-Ini_Inp(end))/ESumTot(end)) '%)']);

%legend(aLeg,'Location','West')
legend([sum_h fliplr(area_h)],fliplr(aLeg),'Location','West')

title('Cumulative Energy (Area)')

OrderOfColors = [
    LossesColors(1,:)
    LossesColors(2,:)
    LossesColors(3,:)
    LossesColors(4,:)
    StoredColors(2,:)
    StoredColors(3,:)
    StoredColors(4,:)
    ];
colororder(OrderOfColors);

xlabel('Time (s)')
ylabel('Energy (Wh)')


%% Sankey Plot

plotSankey_Vertical(abs(storedTot.Battery),[lossesTot.Battery,lossesTot.Resistor,lossesTot.MotorElect,lossesTot.MotorDamping],'Wh', ...
                    {'Battery Charge Used','Battery','Resistor', 'Motor Electrical', 'Motor Damping','Stored (Motor)'});
