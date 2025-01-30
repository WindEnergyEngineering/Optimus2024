% -----------------------------
% Script: Tool to plot the openfast result file.
% In this raw version the windspeed, rotational speed, Power and tower top
% deflection are plotted. See OutListParameters.xlsx for a listing of available output channels
% ------------
% Modified:
% 
% ------------
% History: 
% Felix Lehmann on 29-09-2024
% ----------------------------------
% References:
% - used model: IEA-3.4-130-RWT
% - code based on: SummerGames2024 IEA Task52

clearvars;
%% Processing FAST
OutputFile  = 'IEA-3.4-130-RWT.out';

if ~exist(OutputFile,'file')    % only run FAST if out file does not exist
    dos('.\openfast_x64.exe IEA-3.4-130-RWT.fst');
end

%% PostProcessing FAST
fid         = fopen(OutputFile);
formatSpec  = repmat('%f',1,10);
FASTResults = textscan(fid,formatSpec,'HeaderLines',8);
Time        = FASTResults{:,1};
Wind1VelX   = FASTResults{:,2};
RotSpeed    = FASTResults{:,4};
TTDspFA     = FASTResults{:,5};
GenPwr      = FASTResults{:,9};
fclose(fid);


figure

% plot wind
subplot(411)
hold on;box on;grid on;
plot(Time,Wind1VelX)
ylabel('wind speed [m/s]')
title('openfast results for the IEA-3.4-130-RWT')

% plot rotor speed
subplot(412)
hold on;box on;grid on;
plot(Time,RotSpeed)
ylabel('rotor speed [rpm]')

% generator power
subplot(413)
hold on;box on;grid on;
plot(Time,GenPwr)
ylabel('generator power [kW]')

% plot tower top position
subplot(414)
hold on;box on;grid on;
plot(Time,TTDspFA)
xlabel('time [s]')
ylabel('tower top position [m]')
