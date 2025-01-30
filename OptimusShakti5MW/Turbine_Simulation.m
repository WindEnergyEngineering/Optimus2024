% -----------------------------
% Script: Tests pitch controller at different operation points.
% Exercise 03 of "Controller Design for Wind Turbines and Wind Farms"
% -----------------------------

clearvars;clc;

%% PreProcessing SLOW for all simulations

% Default Parameter Turbine and Controller
Parameter                       = DefaultParameter_SLOW2DOF;
Parameter                       = DefaultParameter_PitchActuator(Parameter);
Parameter                       = DefaultParameter_FBv1_ADv14(Parameter);

% Time
dt                              = 1/80;
Parameter.Time.dt               = dt;   % [s] simulation time step              
Parameter.Time.TMax             = 80;   % [s] simulation length

%% Loop over Operation Points

OPs = [10];
step = 0.1;
nOP = length(OPs);

for iOP=1:nOP
    
    % get Operation Point
    OP = OPs(iOP);

    % wind for this OP
    Disturbance.v_0.time            = [0; 30; 30+dt;  60];       % [s]      time points to change wind speed
    Disturbance.v_0.signals.values  = [0;  0;  step; step]+OP;    % [m/s]    wind speeds

    % Initial Conditions from SteadyStates for this OP
    SteadyStates = load('SteadyStatesShakti5MW_classic.mat','v_0','Omega','theta','M_g','x_T');                       
    Parameter.IC.Omega          	= interp1(SteadyStates.v_0,SteadyStates.Omega,OP,'linear','extrap');
    Parameter.IC.theta          	= interp1(SteadyStates.v_0,SteadyStates.theta,OP,'linear','extrap');
    Parameter.IC.M_g          	    = interp1(SteadyStates.v_0,SteadyStates.M_g,  OP,'linear','extrap');
    Parameter.IC.x_T          	    = interp1(SteadyStates.v_0,SteadyStates.x_T,  OP,'linear','extrap');

    % Processing SLOW for this OP
    simout = sim('FBv1_SLOW2DOF.mdl');
    
    % collect simulation Data
    Omega(:,iOP)    = simout.logsout.get('y').Values.Omega.Data;
    M_g(:,iOP)      = simout.logsout.get('y').Values.M_g.Data;
    Power_el(:,iOP) = simout.logsout.get('y').Values.P_el.Data;
    lambda(:,iOP)   = simout.logsout.get('y').Values.lambda.Data;
    theta(:,iOP)    = simout.logsout.get('y').Values.theta.Data;
    v_0(:,iOP)      = simout.logsout.get('d').Values.v_0.Data;
    x_T(:,iOP)      = simout.logsout.get('y').Values.x_T.Data;
 
end

tout = simout.tout;

%% Run FAST simualtion to compare
% wind = 20;
% % find parameter placeholder in inflow file and replace with wind speed
%     windstr = num2str(wind) + ".0";
%     filename = 'TemplateIEA-3.4-130-RWT_InflowFile.dat';
%     new_filename = 'IEA-3.4-130-RWT_InflowFile.dat';
%     S = fileread(filename);
%     S = regexprep(S, 'PlaceholderWind', windstr); % replace with wind speed
%     fid = fopen(new_filename, 'w');
%     fwrite(fid, S);
%     fclose(fid);
%     
%     % run FAST
%     dos('.\IEA-3.4-130-RWT\Optimus_HH140_D178\DLC_1_2\openfast_x64.exe IEA-3.4-130-RWT.fst');
%     
    % rename output and move file to output directory
%     OutputFile  = 'IEA-3.4-130-RWT.out';
     
%     new_filename = "OutputFiles\" + "IEA-3.4-130-RWT" + num2str(wind(i),'%02d') + ".out";
%     out = fileread(OutputFile);
%     fid = fopen(new_filename, 'w');
%     fwrite(fid, out);
%     fclose(fid);

%     movefile(OutputFile,new_filename);
%% PostProcessing FAST
% fid         = fopen(OutputFile);
% formatSpec  = repmat('%f',1,10);
% FASTResults = textscan(fid,formatSpec,'HeaderLines',8);
% Time        = FASTResults{:,1};
% Wind1VelX   = FASTResults{:,2};
% RotSpeed    = FASTResults{:,4};
% TTDspFA     = FASTResults{:,5};
% GenPwr      = FASTResults{:,9};
% fclose(fid);
%% PostProcessing SLOW
figure

subplot(611)
hold on;box on;grid on;
plot(tout,Omega*60/2/pi)
ylabel('\Omega [rpm]')
legend(strcat(num2str(OPs'),' m/s'))

subplot(612)
hold on;box on;grid on;
plot(tout,rad2deg(theta))
ylabel('\theta [°]')
legend(strcat(num2str(OPs'),' m/s'))

subplot(613)
hold on;box on;grid on;
plot(tout,M_g./1000)
ylabel('M_g [kNm]')
legend(strcat(num2str(OPs'),' m/s'))

subplot(614)
hold on;box on;grid on;
plot(tout,Power_el./1000)
ylabel('Power [kW]')
legend(strcat(num2str(OPs'),' m/s'))

subplot(615)
hold on;box on;grid on;
plot(tout,v_0)
ylabel('v_0 [m/s]')
legend(strcat(num2str(OPs'),' m/s'))

subplot(616)
hold on;box on;grid on;
plot(tout,x_T)
ylabel('x_T [m]')
legend(strcat(num2str(OPs'),' m/s')) 