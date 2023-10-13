%% This script creates the Figure 8 of the paper
%
%-----------------
% Copyright 2022-2023 The MathWorks, Inc.
%-----------------

%% Create plot
plotHVACLossesSetpointSweep

% Set legend and title
ax= gca; ax.Title.String = ''; ax.Box = 'off';
set(gcf,'Units','centimeters','Position', [0,0,14.9,5]);
legend('Setpoint 22°C', 'Setpoint 26°C','Setpoint 32°C');

% Assemble location for saving figure
temp_thisFolder     =  fileparts(which(mfilename));
figFolder = [temp_thisFolder filesep 'Figures'];
if(~isfolder(figFolder))
    mkdir(figFolder)
end

% Save the figure
print(gcf,[figFolder filesep  'FigCabinTBarPlot'],'-djpeg','-r400')