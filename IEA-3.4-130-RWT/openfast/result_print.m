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
formatSpec  = repmat('%f',1,39);
FASTResults = textscan(fid,formatSpec,'HeaderLines',8);
Time        = FASTResults{:,1};
Wind1VelX   = FASTResults{:,2};
BldPitch1   = FASTResults{:,5};
RotSpeed    = FASTResults{:,7};
Azimuth     = FASTResults{:,6};
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

% BldPitch1
subplot(413)
hold on;box on;grid on;
plot(Time,BldPitch1)
ylabel('Blade 1 Pitch [°]')

% plot Azimuth
subplot(414)
hold on;box on;grid on;
plot(Time,Azimuth)
xlabel('time [s]')
ylabel('Azimuth [°]')
%%
saveas(gcf,'Barchart.png')


%%

RotTorq   = FASTResults{:,8};
RootFxb1   = FASTResults{:,14};
RootFyb1    = FASTResults{:,15};
RootFzb1     = FASTResults{:,16};
RootMxb1   = FASTResults{:,17};
RootMyb1   = FASTResults{:,18};
RootMzb1    = FASTResults{:,19};
RootFxc1     = FASTResults{:,20};
RootFyc1   = FASTResults{:,21};
RootMxc1   = FASTResults{:,22};
RootMyc1    = FASTResults{:,23};
LSShftFxa     = FASTResults{:,24};
LSShftFya   = FASTResults{:,25};
LSShftFza   = FASTResults{:,26};
LSShftMxa    = FASTResults{:,27};
LSSTipMya     = FASTResults{:,28};
LSSTipMza   = FASTResults{:,29};
LSShftFys   = FASTResults{:,30};
LSShftFzs    = FASTResults{:,31};
LSSTipMys     = FASTResults{:,32};
LSSTipMzs   = FASTResults{:,33};
YawBrFxp   = FASTResults{:,34};
YawBrFyp    = FASTResults{:,35};
YawBrFzp     = FASTResults{:,36};
YawBrMxp  = FASTResults{:,37};
YawBrMyp   = FASTResults{:,38};
YawBrMzp    = FASTResults{:,39};

max_Root = [max(RootFxb1)  max(RootFyb1) max(RootFzb1) max(RootMxb1) max(RootMyb1) max(RootMzb1) max(RootFxc1) max(RootFyc1) max(RootMxc1) max(RootMyc1)];
max_LSS = [max(LSShftFxa) max(LSShftFya) max(LSShftFza) max(LSShftMxa) max(LSSTipMya) max(LSSTipMza) max(LSShftFys) max(LSShftFzs) max(LSSTipMys) max(LSSTipMzs)];
max_Yaw = [max(YawBrFxp) max(YawBrFyp) max(YawBrFzp) max(YawBrMxp) max(YawBrMyp) max(YawBrMzp)];
output = [max_Root max_LSS max_Yaw]
csvwrite('Output.txt',output)
%find(RootFxb1 == max_Root(:,1))
%find(RootFyb1 == max_Root(:,2))
%line = [find(RootFxb1 == max_Root(:,1)) max(RootFyb1) max(RootFzb1) max(RootMxb1) max(RootMyb1) max(RootMzb1) max(RootFxc1) max(RootFyc1) max(RootMxc1) max(RootMyc1)]