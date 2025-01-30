clear all; close all; clc;

%% Open File
InputFile  = 'Blade_1711_Imp2Simulation_5.txt';

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
Cp_table = reshape(CP,[length(PITCH),length(TSR)]);

% Ct table generation
% u = length(TSR)/length(unique(TSR)); 
Ct_table = reshape(CT,[length(PITCH),length(TSR)]);

% Cq table generation
% u = length(TSR)/length(unique(TSR)); 
Cq_table = reshape(CM,[length(PITCH),length(TSR)]);


%% Creating .mat file for use in SLOW model 
name = 'PowerAndThrustCoefficients_SHAKTI_v5';

info    = ['Created from Qblade for the Optimus 5MW Shakti with script CpTableGeneration.'];
c_P     = Cp_table';
c_T     = Ct_table';
lambda  = TSR;
theta   = PITCH;    
save(name,'info','c_P','c_T','lambda','theta')
%%
figure
surf(rad2deg(theta),lambda,c_P)
xlabel('\theta [deg]')
ylabel('\lambda')
zlabel('c_P')
title('from QBlade')

fprintf('Shakti Surface ranges:\n');
fprintf('theta min: %f\n',rad2deg(min(theta)));
fprintf('theta max: %f\n',rad2deg(max(theta)));
fprintf('lambda min: %f\n',min(lambda));
fprintf('lambda max: %f\n',max(lambda));

SS = load('PowerAndThrustCoefficients_ADv14','c_P','c_T','theta','lambda');
figure
surf(rad2deg(SS.theta),SS.lambda,SS.c_P)
xlabel('\theta [deg]')
ylabel('\lambda')
zlabel('c_P')
title('NREL 3.4 MW')

fprintf('NREL 3.4 MW surface ranges:\n');
fprintf('theta min: %f\n',rad2deg(min(SS.theta)));
fprintf('theta max: %f\n',rad2deg(max(SS.theta)));
fprintf('lambda min: %f\n',min(SS.lambda));
fprintf('lambda max: %f\n',max(SS.lambda));

