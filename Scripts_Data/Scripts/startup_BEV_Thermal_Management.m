%% Description:
% This is the startup function of the project. Add commands here that you
% want to be excecuted when the project is open.

% Copyright 2022-2023 The MathWorks, Inc.

% Build custom library if necessary
prj     = matlab.project.currentProject;
cd(fileparts(which("libraryCreatorLumped.m")))
Libname = 'cylPackParChnlsLumped';
if(~exist(['+' Libname],'dir'))
    libraryCreatorLumped(Libname)
end
cd(prj.RootFolder)

% Open the main system
open_system('BEV_Thermal_Management.slx');
