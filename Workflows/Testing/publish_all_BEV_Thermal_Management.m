
warning('off','Simulink:Engine:MdlFileShadowedByFile');
warning('off','Simulink:Harness:WarnABoutNameShadowingOnActivation');

curr_proj = simulinkproject;
cd(curr_proj.RootFolder);
cd('Overview')

% Close main model to avoid shadowing error
bdclose('BEV_Thermal_Management');

% Loop over publish scripts
filelist_m=dir('*.m');
filenames_m = {filelist_m.name};
for i=1:length(filenames_m)
    if ~(strcmp(filenames_m{i},'publish_all_html.m'))
    publish(filenames_m{i},'showCode',false)
    end
end

%% Publish Workflow Documentation
 
% Publish Sensitivity Cabin Setpoint count
cd(fileparts(which('sensitivityCabinSetpoint.m')))
cd('Overview')
publish('BEV_Thermal_Management_CabinSetpoint.m','showCode',false)
cd(curr_proj.RootFolder);

% Publish Sensitivity Passenger count
cd(fileparts(which('sensitivityPassCount.m')))
cd('Overview')
publish('BEV_Thermal_Management_PassCount.m','showCode',false)
cd(curr_proj.RootFolder);

% Publish Sensitivity Passenger count
cd(fileparts(which('energyAcct_ElectroMech.slx')))
cd('Overview')
publish('energyAcct_Driveline.m','showCode',true)
publish('energyAcct_ElectroMech.m','showCode',true)
cd(curr_proj.RootFolder);


