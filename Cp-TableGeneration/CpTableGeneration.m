clear all; close all; clc;

%% Open File
InputFile  = 'Blade_111_WidSpeed1016.txt';

%% PostProcessing QBlade Output
fid         = fopen(InputFile);
formatSpec  = repmat('%f',1,10);
Results = textscan(fid,formatSpec,'HeaderLines',7);

WIND        = Results{:,1};
ROT         = Results{:,2};
PITCH       = Results{:,3};
POWER       = Results{:,4};
THRUST      = Results{:,5};
TORQUE      = Results{:,6};
TSR         = Results{:,7};
CP          = Results{:,8};
CT          = Results{:,9};
CM          = Results{:,10};
fclose(fid);

% find unique TSR
TSR = unique(TSR)';

% find unique PITCH
PITCH = unique(PITCH)*pi/180;

% Cp table generation
% u = length(TSR)/length(unique(TSR)); 
Cp_table = reshape(CP,[length(TSR),length(PITCH)]);

% Ct table generation
% u = length(TSR)/length(unique(TSR)); 
Ct_table = reshape(CT,[length(TSR),length(PITCH)]);

% Cq table generation
% u = length(TSR)/length(unique(TSR)); 
Cq_table = reshape(CM,[length(TSR),length(PITCH)]);


%% Creating .mat file for use in SLOW model 
name = 'PowerAndThrustCoefficients_SHAKTI_v1';
info    = ['Created from Qblade for the Optimus 5MW Shakti with script CpTableGeneration.'];
c_P     = Cp_table;
c_T     = Ct_table;
lambda  = TSR;
theta   = PITCH;
save(name,'info','c_P','c_T','lambda','theta')

