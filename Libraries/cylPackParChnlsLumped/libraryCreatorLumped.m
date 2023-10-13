function libraryCreatorLumped(Libname)
%% Description: 
% This scripts shows how to create the library for the Simscape Battery
% model. The same library could also be created using the Simscape Battery Builder App.

% Copyright 2022-2023 The MathWorks, Inc.


%% Implementation:

%% 1) Set up savepath

% This part of the script generates the link where the battery will be
% saved. I wrap the entire library in a folder with the same name as the
% library itself for better clarity (do not modify!).
prj     = matlab.project.currentProject;
Libpath =  append(prj.RootFolder,'\','Libraries\',Libname,'\');

% If the library folder does not exist, create it
if ~isfolder(Libpath) 
    mkdir(Libpath); 
    disp('Creating folder for storing the new battery library'); 
end

%% 2) Set up the Simscape Battery model
% Import simscape library
import simscape.battery.builder.*

% Create cell
cylCell = Cell("Geometry",CylindricalGeometry());

% Activate the thermal port
cylCell.CellModelOptions.BlockParameters.thermal_port='model';
cylCell.CellModelOptions.BlockParameters.T_dependence = 'yes';

% Now set the parallel assembly as needed
cylParAssembly = ParallelAssembly('Cell',cylCell,'NumParallelCells',32,'Rows',1,'Topology','Hexagonal','StackingAxis','X');

% Create module
cylModule = Module('ParallelAssembly',cylParAssembly,'NumSeriesAssemblies',12,'StackingAxis','Y');

% Create one module assembly from the base modules:
cylModAssembly = ModuleAssembly('Module',repmat(cylModule,1,2),'StackingAxis','X');

% Finally create the pack
cylPack = Pack('ModuleAssembly', repmat(cylModAssembly,1,4),...
               'InterModuleAssemblyGap',simscape.Value(90,'mm'), ...
               'StackingAxis','Y',...
               'AmbientThermalPath','CellBasedThermalResistance',...
               'CoolantThermalPath','CellBasedThermalResistance', ...
               'CoolingPlate','Bottom', ... 
               'CoolingPlateBlockPath','batt_lib/Thermal/Parallel Channels');

%% 3) Create the library:
% Depending on the battery size this process might take a few minutes
buildBattery(cylPack,...
    "LibraryName",Libname,...
    "MaskParameters","VariableNames",...
    "Directory",Libpath,...
    "MaskInitialTargets","VariableNames");
