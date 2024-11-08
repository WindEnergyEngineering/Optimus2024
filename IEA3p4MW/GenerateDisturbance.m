% -----------------------------
% Script: Generates a set of time series for rotor-effective wind speed.
% Exercise 06 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ----------------------------------

clearvars;close all;clc;

%% Configuration

% Parameter 
Parameter.Turbine.R                     = 65;       % [m] rotor radius
Parameter.Time.dt                       = 0.1;      % [s] simulation time step            
Parameter.Time.TMax                     = 3600;     % [s] simulation lenght
Parameter.TurbSim.IRef                  = 0.14;     % [-] ClassB

% windfield
[windfield.grid.Y,windfield.grid.Z]     = meshgrid(-68:8:68);

%% Generate Disturbances
figure
hold on;box on
xlabel('t [s]')
ylabel('v_0 [m/s]')

% Mean wind speeds for DLC 1.2
URef_v      = [3:1:12];
nURef       = length(URef_v);

% loop over wind speeds
for iURef = 1:nURef
    
    % Generate Rotor-Effective Wind Speed
    URef                        = URef_v(iURef);
    Parameter.TurbSim.URef      = URef;
    Parameter.TurbSim.RandSeed 	= URef; % to be different for every URef
    fprintf('Generating %d m/s!\n',URef)
    Disturbance                 = GenerateRotorEffectiveWindSpeed(windfield,Parameter);
    
    % plot and save
    plot(Disturbance.v_0.time,Disturbance.v_0.signals.values);
    drawnow
    save(['wind\URef_',num2str(URef,'%02d'),'_Disturbance'],'Disturbance','windfield','Parameter')    
    
end
%% Post Processing Disturbance
% Mean windspeed used can be manually adjusted
v = [3 3 3 4 4 5 5 6 6 5 7 9 9 10 11 12 10 9 8 6 6 5 5 4 4];               % v [m/s}
%v = [3 4];

% load only needed Disturbance time series 
for i = min(v):max(v)
    load(['wind\URef_',num2str(i,'%02d'),'_Disturbance.mat'], 'Disturbance');
    v_length = length(Disturbance.v_0.signals.values);
    v_table([1:v_length],i) = Disturbance.v_0.signals.values;
    
end

Disturbance.v_0.signals.values = [];
% shift the series circular
for j = 1:length(v)
    v_actual      = v_table(:,v(j));
    % Start series
    if j == 1
    Disturbance.v_0.signals.values = [v_actual]; %Disturbance.v_0.signals.values;  
    % later series
    else
        v_old           = v_table(end,v(j-1));
        v_oldMinusOne   = v_table(end-1,v(j-1));
        dv_old          = abs((v_old-v_oldMinusOne));
        d_absolute      = abs(v_old-v_actual);
        
        % Error band for wind threshold !!! adjustable !!!
        v_threshold      = 0.1;
        %vdot_threshold   = 0.005;
    
        IndexAbsValues = find(d_absolute <= v_threshold); 
        % Derivative approache 
        %dv = diff(v_actual(IndexAbsValues));

        %d_dot = dv_old - dv;
        %IndexDotValues = find(d_dot <= abs(vdot_threshold));
        
        % Number of censecutive values nedded !!! adjustable !!!
        thresholdRegion = 30;
        startIndex = find_consecutive_region(IndexAbsValues, thresholdRegion);
        
        % final circular shifting
        vn = circshift(v_actual, startIndex);
        % store results
        Disturbance.v_0.signals.values = [Disturbance.v_0.signals.values; vn];
    end

end
% store results
Disturbance.v_0.time = [0:0.1:25*3600-0.1];
save('wind\shittyWind1_Disturbance','Disturbance','windfield','Parameter')

% plot results
figure

p = plot(Disturbance.v_0.signals.values,'x-','MarkerIndices',[36000:36000:length(Disturbance.v_0.signals.values)]);
p.MarkerFaceColor = [1 0.5 0];
p.MarkerSize = 8;
p.MarkerEdgeColor = [1 0.5 0];
title('Combined timeseries of Scenario X')
ylabel('v_0 [m/s]')
xlabel('time [ds]')


