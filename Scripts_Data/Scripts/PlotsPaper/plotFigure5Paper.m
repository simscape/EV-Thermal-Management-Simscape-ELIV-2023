%% This scripts creates the Figure 5 of the paper
% Description: This script creates the figure 5 of the paper. The figure 5
%              plots the speed over time of the simulated cycle as well as 
%              the total driven distance
%-----------------
% Copyright 2022-2023 The MathWorks, Inc.
%-----------------

plotDriveChargeCycle
title('')

% Create figure and set the dimensions
set(gcf, 'Units','centimeters','Position',[0,0,14.9,5]);

%% 4) Adjust the axes so that the plot is centered in the figure
% Get the current insets and position of the figure and its real dimensions
% which are represented by posrec and include the right y-axis
inset = get(gca,'TightInset');   % [left bottom width height]
pos   = get(gca,'Position');     % [left bottom width height]
posrec = [pos(1)-inset(1),pos(2)-inset(2),pos(3)+inset(1)+inset(3),pos(4)+inset(4)+inset(2)];
ax = gca;

% Find right and left margin and center the graph in X
lmargin = posrec(1);
rmargin = 1-posrec(1) - posrec(3);
Xshift = (lmargin + rmargin)/2;
ax.Position(1) = ax.Position(1)-Xshift;

% Find bottom and top margin and center the graph in Y
bmargin = posrec(2);
tmargin = 1-posrec(2) - posrec(4);
Yshift = (bmargin + tmargin)/2;
ax.Position(2) = ax.Position(2)+Yshift;

% Assemble location for saving figure
temp_thisFolder     =  fileparts(which(mfilename));
figFolder = [temp_thisFolder filesep 'Figures'];
if(~isfolder(figFolder))
    mkdir(figFolder)
end

%% 5) Save the figure
print(gcf,[figFolder filesep 'driveCycle'],'-djpeg','-r400')
hold off