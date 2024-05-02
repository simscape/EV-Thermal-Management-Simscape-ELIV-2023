function plotHVACEnergy(out)
% Description: After simulating the vehicle and passing the results trough the
%              function calcVehicleEnergy, the output of the function is reused here to
%              represent the HVAC consumption as a bar plot
%-----------------
% Inputs:      out: This struct is the output of the function calcVehicleEnergy
%-----------------
% Copyright 2022-2024 The MathWorks, Inc.
%-----------------

%% Implementation
% Retrieve the calculated HVAC consumption
out = out.hvac;

% Colors to be used in the plots
Colors = [215, 136, 36; 242, 169, 0; 255, 206, 94; 255, 255, 255; 153, 153, 153; 0,0,0]/255;

% Build a vector containing the consumption (in kWh) and initialize labels
hvacEn = round([out.energyCmpr; out.energyFan; out.energyBlwr; out.energyPmps  + out.energyDCDC; out.energyPTC; out.energyHeater],2);
labels = categorical({'Compressor'; 'Condenser fan'; 'Blower';'Pumps/DC-DC';'PTC';'Heater'});

% Filter out the components that are smaller than 1 W. No need to represent them
hvacEn(find(hvacEn<0.001)) = [];
labels(find(hvacEn<0.001)) = [];

% For better visibility, resort the components in descending order
[reqEnSrtd,I] = sort(hvacEn,'descend');
labelsSrtd    = labels(I);

% Figure name
figString = ['h1_' mfilename];
% Only create a figure if no figure exists
figExist = 0;
fig_hExist = evalin('base',['exist(''' figString ''')']);
if (fig_hExist)
    figExist = evalin('base',['ishandle(' figString ') && strcmp(get(' figString ', ''type''), ''figure'')']);
end
if ~figExist
    fig_h = figure('Name',figString);
    assignin('base',figString,fig_h);
else
    fig_h = evalin('base',figString);
end
figure(fig_h)
clf(fig_h)

% Create bar plot
h1 = bar(gca,reqEnSrtd,'FaceColor','flat');

% Set axes dimensions and layout
set(gca,'XLim',[0.5,numel(reqEnSrtd)+0.5],'YLim',[0,max(reqEnSrtd)*1.1]);
set(gca, 'XTick',1:numel(hvacEn),'XTickLabel', labelsSrtd,'FontSize',11);
title(['Total HVAC energy: ',num2str(sum(hvacEn)),' kWh']);
ylabel('HVAC Losses in kWh');

% Set color and dimensions of the bar plot
set(h1,'CData',Colors(1:numel(hvacEn),:),'BarWidth',1);

% Write consumption values above the bar plot
text(h1.XEndPoints,h1.YEndPoints,num2str(reqEnSrtd),'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',10);
end