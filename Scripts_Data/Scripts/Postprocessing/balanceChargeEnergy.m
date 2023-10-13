function balanceChargeEnergy(slog)
% Checks how the power flows in the vehicle while it is charging

% Colors used for plot
Colors = [215, 136, 36;...
          242, 169, 0; ...
          0  , 75 , 135; ...
          0  , 118, 168;...
          198, 241, 255;
          0, 169, 224]/255;

% Simulation time in s
simTime = slog.DCDC.DCDC.power_dissipated.series.time;

%% 1) Plot the energy balance during charging
% Retrieve the timesteps when the vehicle is charging
currChrg = slog.Charger.Charger.i.series.values('A');
ID       = currChrg>0.1;

% Power flow to the HV and LV components
pwr2HVAC = zeroifID(slog.DCDC.Power_DCDC_in.Power_Sensor.P.series.values('W'),~ID);
pwr2Batt = zeroifID(slog.Battery.Battery_Power_Out.Power_Sensor.P.series.values('W'),~ID);
pwr2EM   = zeroifID(slog.Motor.Motor_Power_in.Power_Sensor.P.series.values('W'),~ID);
pwrCharg = slog.Charger.Charging_Power.Power_Sensor.P.series.values('W');
pwrCmprs = zeroifID(slog.Compressor.Battery_voltage.V.series.values('V').*slog.Compressor.Controlled_Current_Source.i.series.values('A'),~ID);

% Corresponding amount of energy taken by each component when charging
En2HVAC  = cumtrapz(simTime, pwr2HVAC)/3600/1000;
En2Batt  = cumtrapz(simTime, pwr2Batt)/3600/1000;
En2EM    = cumtrapz(simTime, pwr2EM)/3600/1000;
En2Charg = cumtrapz(simTime, pwrCharg)/3600/1000;
En2Cmprs = cumtrapz(simTime, pwrCmprs)/3600/1000;

% Plot the results. Here we check if the sum of the energies flowing
% trhough each component is equal to the energy provided by the charger
figure('Name','Energy Balance During Charging'); hold on
title('When energies are accounted right, CHG and TOT lines coincide')

plot(simTime, En2Charg,'Color',Colors(1,:),'LineWidth',2);
plot(simTime, En2HVAC,'Color',Colors(2,:),'LineWidth',2);
plot(simTime, -En2Batt,'Color',Colors(3,:),'LineWidth',2);
plot(simTime, En2EM,'Color',Colors(4,:),'LineWidth',2);
plot(simTime, En2Cmprs,'Color',Colors(5,:),'LineWidth',2);
plot(simTime, En2EM-En2Batt+En2HVAC+En2Cmprs,'red','LineStyle','--','LineWidth',2);
legend('CHRG','HVAC','BATT','EM','CMPRS','TOT');

xlabel('Time in s');
ylabel('Energy in kWh');


end

function vec= zeroifID(vec,ID)

vec(ID) = 0;

end