% Description: This script plots the energy balance of the model
%              energyAcct_Driveline by visualizing input energy, 
%              losses, and stored energy
%-----------------
% Copyright 2022-2023 The MathWorks, Inc.
%-----------------

mdl = 'energyAcct_Driveline';

if ~exist(['simlog_' mdl], 'var')
    open_system(mdl)
    sim(mdl)
end

%% Get Time Vector
simTime     = simlog_energyAcct_Driveline.Power_Sensor_Input_Gearbox.P.series.time;

%% Torque Source
% External Energy Input
powerInst.Torque_SourceR = simlog_energyAcct_Driveline.Power_Sensor_Input_Gearbox.P.series.values('kW');
energyCml.Torque_SourceR = cumtrapz(simTime, powerInst.Torque_SourceR)/3600;
energyTot.Torque_SourceR = energyCml.Torque_SourceR(end);

% Energy Stored
% none

% Energy Losses
% none

%% Gearbox

% External Energy Input
% none

% Energy Stored
% none

% Energy Losses, Viscous
powerInst.Gearbox.viscousB = simlog_energyAcct_Driveline.Gearbox.damperB.power_dissipated.series.values('kW');
powerInst.Gearbox.viscousF = simlog_energyAcct_Driveline.Gearbox.damperF.power_dissipated.series.values('kW');

lossesCml.Gearbox.viscous   = cumtrapz(simTime, powerInst.Gearbox.viscousB + powerInst.Gearbox.viscousF)/3600;
lossesTot.Gearbox.viscous   = lossesCml.Gearbox.viscous(end);

% Energy Losses, Meshing
% Note - meshing losses *not* captured in logging
% Determined using (Energy In - Energy Out - Viscous Losses)
powerInst.GearboxF   = simlog_energyAcct_Driveline.Power_Sensor_Gearbox_Tires.P.series.values('kW');
energyCml.GearboxF   = cumtrapz(simTime, powerInst.GearboxF)/3600;
energyTot.GearboxF   = energyCml.GearboxF(end);

lossesCml.Gearbox.all    = energyCml.Torque_SourceR - energyCml.GearboxF;
lossesTot.Gearbox.all    = lossesCml.Gearbox.all(end);

% Meshing losses       = (Energy In - Energy Out - Viscous Losses)
powerInst.Gearbox.mesh = powerInst.Torque_SourceR - powerInst.GearboxF - powerInst.Gearbox.viscousB - powerInst.Gearbox.viscousF;
lossesCml.Gearbox.mesh = cumtrapz(simTime, powerInst.Gearbox.mesh)/3600;
lossesTot.Gearbox.mesh = lossesCml.Gearbox.mesh(end);

%% Tires

% External Energy Input
% none

% Energy Stored: Rotational Kinetic Energy
tireJ_FL = eval(get_param([mdl '/Tires FL'],'inertia'));
tireJ_FR = eval(get_param([mdl '/Tires FR'],'inertia'));
tireJ_RL = eval(get_param([mdl '/Tires RL'],'inertia'));
tireJ_RR = eval(get_param([mdl '/Tires RR'],'inertia'));
wFL = simlog_energyAcct_Driveline.Tires_FL.A.w.series.values('rad/s');
wFR = simlog_energyAcct_Driveline.Tires_FR.A.w.series.values('rad/s');
wRL = simlog_energyAcct_Driveline.Tires_RL.A.w.series.values('rad/s');
wRR = simlog_energyAcct_Driveline.Tires_RR.A.w.series.values('rad/s');

storedCml.Tire.FL  = (0.5*tireJ_FL*wFL.^2)/1000/3600; 
storedCml.Tire.FR  = (0.5*tireJ_FL*wFR.^2)/1000/3600; 
storedCml.Tire.RL  = (0.5*tireJ_FL*wRL.^2)/1000/3600; 
storedCml.Tire.RR  = (0.5*tireJ_FL*wRR.^2)/1000/3600; 
storedCml.Tire.all = storedCml.Tire.FL+storedCml.Tire.FR+storedCml.Tire.RL+storedCml.Tire.RR;
storedTot.Tire.all = storedCml.Tire.all(end);

clear tireJ_FL tireJ_FR tireJ_RL tireJ_RR wFL wFR wRL wRR

% Energy Losses: Compliance
% Not calculated 
lossesCml.Tires.compliance = 0;

% Energy Losses: Rolling Resistance
% Not captured in logging
% Determined using (Energy In - Energy Out - Energy Stored)
powerInst.TiresH  = simlog_energyAcct_Driveline.Power_Sensor_Tires_Vehicle.P.series.values('kW');
energyCml.TiresH  = cumtrapz(simTime, powerInst.TiresH)/3600;
energyTot.TiresH  = energyCml.TiresH(end);

lossesCml.Tires.rolling_resistance   = ...
    energyCml.GearboxF - energyCml.TiresH - storedCml.Tire.all - lossesCml.Tires.compliance;
lossesTot.Tires.rolling_resistance   = lossesCml.Tires.rolling_resistance(end);

%% Vehicle
% Losses calculated first - necessary for calculating input from wind

% Energy Losses: Drag
% Note - drag losses not captured in logging, calculated from equation
vWind   = simlog_energyAcct_Driveline.Vehicle.wind.series.values('m/s');
vVeh    = simlog_energyAcct_Driveline.Vehicle.H.v.series.values('m/s');

aVeh    = eval(get_param([mdl '/Vehicle'],'area'));
CdVeh   = eval(get_param([mdl '/Vehicle'],'Cd'));
rhoAir  = eval(get_param([mdl '/Vehicle'],'rho'));

% Total power drag+wind 
powerInst_drag_wind = (0.5*CdVeh*aVeh*rhoAir*vVeh.*sign(vVeh+vWind).*(vVeh+vWind).^2)/1000;

% Losses Drag Only (no wind)
powerInst_drag_only = (0.5*CdVeh*aVeh*rhoAir*vVeh.*(vVeh).^2)/1000;

% Energy Losses Drag Only
powerInst.Vehicle.drag = powerInst_drag_only;
lossesCml.Vehicle.drag = cumtrapz(simTime,powerInst.Vehicle.drag)/3600;
lossesTot.Vehicle.drag = lossesCml.Vehicle.drag(end);

% External Energy Input: Wind
% Energy Input Wind Only = (Drag+Wind) - (Drag Only)
powerInst.Vehicle.wind = powerInst_drag_wind-powerInst_drag_only;
energyCml.Vehicle.wind = cumtrapz(simTime,powerInst.Vehicle.wind)/3600;
energyTot.Vehicle.wind = energyCml.Vehicle.wind(end);

% Energy Stored: Kinetic Energy
% Calculate using KE = 0.5*m*v^2
mVeh    = eval(get_param([mdl '/Vehicle'],'mass'));
storedCml.Vehicle.kinetic   = (0.5*mVeh*vVeh.^2)/1000/3600;

% Energy Stored: Potential Energy
% Calculate using PE = m*g*h
% Height is not logged, calculate using inclination angle and speed
qIncline = simlog_energyAcct_Driveline.Vehicle.beta.series.values('deg');
vyVeh   = vVeh.*sind(qIncline);   % vVeh is in plane of axles
pHeight = cumtrapz(simTime,vyVeh);
pHeight = pHeight-min(pHeight);   % Ensure stored energy is captured at start

% Set minimum height during test trajectory to 0
gVeh    = eval(get_param([mdl '/Vehicle'],'g'));

storedCml.Vehicle.potential = mVeh*gVeh*pHeight/1000/3600;


clear vVeh mVeh aVeh CdVeh rhoAir

%% Plot Energy Totals in Time

setOfColors = summer;
InputColors  = setOfColors(1:60:end,:);
setOfColors = autumn;
LossesColors  = setOfColors(60:60:end,:);
setOfColors = cool;
StoredColors  = setOfColors(1:40:end,:);

if ~exist('h3_energyAcct_Driveline', 'var') || ...
        ~isgraphics(h3_energyAcct_Driveline, 'figure')
    h3_energyAcct_Driveline = figure('Name', 'energyAcct_Driveline');
end
figure(h3_energyAcct_Driveline)
clf(h3_energyAcct_Driveline)

% Plot Inputs
plot(simTime,energyCml.Torque_SourceR,'Color',InputColors(1,:),...
    'LineWidth',2,'DisplayName','Torque Source Input');
hold on
plot(simTime,-energyCml.Vehicle.wind,'Color',InputColors(2,:),...
    'LineWidth',2,'DisplayName','Wind Input');

% Plot Stored
plot(simTime,storedCml.Tire.all,...
    'Color',StoredColors(2,:),'LineWidth',2,'DisplayName','Stored Tires');
plot(simTime,storedCml.Vehicle.kinetic,...
    'Color',StoredColors(3,:),'LineWidth',2,'DisplayName','Stored Vehicle Kinetic');
plot(simTime,storedCml.Vehicle.potential,...
    'Color',StoredColors(4,:),'LineWidth',2,'DisplayName','Stored Vehicle Potential');

plot(simTime,energyCml.Torque_SourceR-energyCml.Vehicle.wind+storedCml.Vehicle.potential(1),...
    'Color','c','LineWidth',3,'DisplayName','   Total Input+Initial Stored');

% Plot Losses
plot(simTime,lossesCml.Vehicle.drag,...
    'Color',LossesColors(1,:),'LineWidth',2, 'DisplayName','Losses Drag');
plot(simTime,lossesCml.Tires.rolling_resistance,...
    'Color',LossesColors(2,:),'LineWidth',2,'DisplayName','Losses Tires');
plot(simTime,lossesCml.Gearbox.viscous,...
    'Color',LossesColors(3,:),'LineWidth',2,'DisplayName','Losses Gearbox Viscous');
plot(simTime,lossesCml.Gearbox.mesh,...
    'Color',LossesColors(4,:),'LineWidth',2,'DisplayName','Losses Gearbox Mesh');
plot(simTime,lossesCml.Gearbox.mesh+lossesCml.Gearbox.viscous+lossesCml.Tires.rolling_resistance+lossesCml.Vehicle.drag,...
    'r-.','DisplayName','  Total Losses');

plot(simTime,storedCml.Tire.all+storedCml.Vehicle.kinetic+storedCml.Vehicle.potential,...
    'Color',StoredColors(1,:),'LineStyle','-.','DisplayName',' Total Stored');

plot(simTime,storedCml.Vehicle.kinetic+storedCml.Vehicle.potential+storedCml.Tire.all+lossesCml.Gearbox.mesh+lossesCml.Gearbox.viscous+lossesCml.Tires.rolling_resistance+lossesCml.Vehicle.drag,'k--','LineWidth',2,'DisplayName','Losses+Stored');

hold off

title('Cumulative Energy vs. Time')
xlabel('Time (s)')
ylabel('Energy (kWh)')
legend('Location','Best')

%% Area Plot
if ~exist('h4_energyAcct_Driveline', 'var') || ...
        ~isgraphics(h4_energyAcct_Driveline, 'figure')
    h4_energyAcct_Driveline = figure('Name', 'energyAcct_Driveline');
end
figure(h4_energyAcct_Driveline)
clf(h4_energyAcct_Driveline)

EnergySummary = [];aLeg = [];

EnergySummary(:,1) = lossesCml.Vehicle.drag;      aLeg{1} = 'Losses Drag';
EnergySummary(:,2) = lossesCml.Tires.rolling_resistance; aLeg{2} = 'Losses Tires';
EnergySummary(:,3) = lossesCml.Gearbox.mesh;      aLeg{3} = 'Losses Gears Mesh';
EnergySummary(:,4) = lossesCml.Gearbox.viscous;   aLeg{4} = 'Losses Gears Viscous';

EnergySummary(:,5) = storedCml.Vehicle.kinetic;   aLeg{5} = 'Stored Vehicle Kinetic';
EnergySummary(:,6) = storedCml.Vehicle.potential; aLeg{6} = 'Stored Vehicle Potential';
EnergySummary(:,7) = storedCml.Tire.all;          aLeg{7} = 'Stored Tires';

area_h=area(simTime,EnergySummary);

hold on
Initial_Input = ...
    -energyCml.Vehicle.wind+energyCml.Torque_SourceR+...
    storedCml.Vehicle.potential(1);
sum_h=plot(simTime,Initial_Input,'k--','LineWidth',2,'DisplayName','Energy Input');
hold off

ESumTot=sum(EnergySummary,2);
Ini_Inp = Initial_Input(end);

aLeg{8} = sprintf('%s %s',...
    'Input+Initial',['(Err: ' sprintf('%3.1e',(ESumTot(end)-Ini_Inp(end))/ESumTot(end)) '%)']);

legend([sum_h fliplr(area_h)],fliplr(aLeg),'Location','SouthEast')
%legend(aLeg,'Location','SouthEast')
title('Cumulative Energy (Area)')

OrderOfColors = [
    LossesColors(1,:)
    LossesColors(2,:)
    LossesColors(3,:)
    LossesColors(4,:)
    StoredColors(3,:)
    StoredColors(4,:)
    StoredColors(5,:)
    ];
colororder(OrderOfColors);

xlabel('Time (s)')
ylabel('Energy (kWh)')

% Note: For slide, set(gcf,'Position',[889   445   560   278])


%% Sankey Plot

% Wind can act as an input or a loss, or offer nothing
% Adjust inputs to Sankey function based on total wind contribution
if(energyTot.Vehicle.wind<0)
    inputs = [energyTot.Torque_SourceR+storedCml.Vehicle.potential(1) -energyTot.Vehicle.wind];
    losses = [lossesTot.Gearbox.viscous lossesTot.Gearbox.mesh lossesTot.Tires.rolling_resistance lossesTot.Vehicle.drag];
    labels = {'Torque Source','Wind','Gearbox Viscous','Gearbox Meshing','Tires','Drag','Stored'};
elseif(energyTot.Vehicle.wind>0)
    inputs = [energyTot.Torque_SourceR storedCml.Vehicle.potential(1)];
    losses = [lossesTot.Gearbox.viscous lossesTot.Gearbox.mesh lossesTot.Tires.rolling_resistance lossesTot.Vehicle.drag energyTot.Vehicle.wind];
    labels = {'Torque Source','Stored','Gearbox Viscous','Gearbox Meshing','Tires','Drag','Wind','Stored'};
elseif(energyTot.Vehicle.wind==0)
    inputs = [energyTot.Torque_SourceR storedCml.Vehicle.potential(1)];
    losses = [lossesTot.Gearbox.viscous lossesTot.Gearbox.mesh lossesTot.Tires.rolling_resistance lossesTot.Vehicle.drag];
    labels = {'Torque Source','Stored','Gearbox Viscous','Gearbox Meshing','Tires','Drag','Stored'};
end
unit   = 'kWh';
if((sum(losses)-sum(inputs))<1e-3)
    losses(end) = losses(end)-(sum(inputs)-sum(losses))-sum(inputs)*1e-6;
end

plotSankey_Vertical(inputs, losses, unit, labels)


