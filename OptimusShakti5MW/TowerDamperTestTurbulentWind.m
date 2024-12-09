% -----------------------------
% Script: Tests tower damper with turbulent wind.
% Exercise 05 of "Controller Design for Wind Turbines and Wind Farms"
% -----------------------------
clearvars;close all;clc;

%% PreProcessing SLOW

% Default Parameter Turbine and Controller
Parameter                           = DefaultParameter_SLOW2DOF;
Parameter                           = DefaultParameter_PitchActuator(Parameter);
Parameter                           = DefaultParameter_FBv1_ADv14(Parameter);

% Time
Parameter.Time.dt                   = 1/10;             % [s] simulation time step            
Parameter.Time.TMax                 = 3600;             % [s] simulation length

% wind
OP = 20;                            
load(['wind/URef_',num2str(OP,'%02d'),'_Disturbance'],'Disturbance')              

% Initial Conditions from SteadyStates
SteadyStates = load('SteadyStatesShakti5MW_classic.mat','v_0','Omega','theta','x_T','M_g');                       
Parameter.IC.Omega          	    = interp1(SteadyStates.v_0,SteadyStates.Omega   ,OP,'linear','extrap');
Parameter.IC.theta          	    = interp1(SteadyStates.v_0,SteadyStates.theta   ,OP,'linear','extrap');
Parameter.IC.x_T                    = interp1(SteadyStates.v_0,SteadyStates.x_T     ,OP,'linear','extrap');
Parameter.IC.M_g                    = interp1(SteadyStates.v_0,SteadyStates.M_g     ,OP,'linear','extrap');
%% Processing SLOW with and without Tower Damper
TD1 = sim('FBv1_SLOW2DOF_with_TowerDamper.mdl','ReturnWorkspaceOutputs','on');
TD1_PA = sim('FBv1_SLOW2DOF_TD_PA.mdl','ReturnWorkspaceOutputs','on');
Parameter.TD.gain  = 0;
TD0 = sim('FBv1_SLOW2DOF_TD_PA.mdl','ReturnWorkspaceOutputs','on');
%% PostProcessing SLOW

% estimate spectra
nBlocks                 = 6;
SamplingFrequency       = 1/Parameter.Time.dt;
nDataPerBlock           = round(length(TD1.tout)/nBlocks);
M_yT_TD1                = TD1.logsout.get('y').Values.M_yT.Data;
[S_M_yT_TD1,~]          = pwelch(detrend(M_yT_TD1,  'constant'),nDataPerBlock,[],[],SamplingFrequency);
M_yT_TD0                = TD0.logsout.get('y').Values.M_yT.Data;
[S_M_yT_TD0,~]          = pwelch(detrend(M_yT_TD0,  'constant'),nDataPerBlock,[],[],SamplingFrequency);
M_yT_TD1_PA             = TD1_PA.logsout.get('y').Values.M_yT.Data;
[S_M_yT_TD1_PA,f_est]   = pwelch(detrend(M_yT_TD1_PA,  'constant'),nDataPerBlock,[],[],SamplingFrequency);

figure
hold on;grid on;box on
title('tower base bending moment spectrum')
plot(f_est,S_M_yT_TD0)
plot(f_est,S_M_yT_TD1)
plot(f_est,S_M_yT_TD1_PA)
set(gca,'xScale','log')
set(gca,'yScale','log')
ylabel('[(Nm)^2/Hz]')
legend('without TD','with TD','with TD + PA','Location','best')
xlabel('frequency [Hz]')