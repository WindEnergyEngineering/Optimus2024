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
TSR = unique(TSR);

% find unique PITCH
PITCH = unique(PITCH);

% Cp table generation
% u = length(TSR)/length(unique(TSR)); 
Cp_table = reshape(CP,[length(TSR),length(PITCH)]);

% Ct table generation
% u = length(TSR)/length(unique(TSR)); 
Ct_table = reshape(CT,[length(TSR),length(PITCH)]);

% Cq table generation
% u = length(TSR)/length(unique(TSR)); 
Cq_table = reshape(CM,[length(TSR),length(PITCH)]);

%% Writing to file:
OutputFile = 'Shakti_5MW_Cp_Ct_Cq.txt';
fid = fopen(OutputFile,'w');
% Header    
fprintf(fid,'%s\n','# ----- Rotor performance tables for the Optimus Shakti Turbine -----');
fprintf(fid,'%s\n','# ------------ Written on Nov-12-24 using values from QBlade --------');
fprintf(fid,'\n');
% Pitch Vector
fprintf(fid,'%s\n',"# Pitch angle vector, " + num2str(length(PITCH)) + " entries - x axis (matrix columns) (deg)");
fprintf(fid,'%f\t',PITCH);
fprintf(fid,'\n');
% Pitch Vector
fprintf(fid,'%s\n',"# TSR vector, " + num2str(length(PITCH)) + " entries - y axis (matrix rows) (-)");
fprintf(fid,'%f\t',TSR);
fprintf(fid,'\n');
% Wind Vector
fprintf(fid,'%s\n','# Wind speed vector - z axis (m/s)');
fprintf(fid,'%f\t',WIND(1,1));
fprintf(fid,'\n\n');
% Cp Table
fprintf(fid,'%s\n','# Power coefficient');
fclose(fid);
writematrix(Cp_table,OutputFile,'Delimiter','tab','WriteMode','append');

% Ct Table
fid = fopen(OutputFile,'a');
fprintf(fid,'\n');
fprintf(fid,'\n');
fprintf(fid,'%s\n','#  Thrust coefficient');
fclose(fid);
writematrix(Ct_table,OutputFile,'Delimiter','tab','WriteMode','append');

% Cq Table
fid = fopen(OutputFile,'a');
fprintf(fid,'\n');
fprintf(fid,'\n');
fprintf(fid,'%s\n','# Torque coefficient');
fclose(fid);
writematrix(Cq_table,OutputFile,'Delimiter','tab','WriteMode','append');
  
%%