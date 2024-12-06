% -----------------------------
% Script: Tests tower damper with wind step.
% Exercise 05 of Course "Controller Design for Wind Turbines and Wind Farms"
% -----------------------------
clearvars;close all;clc;

%% PreProcessing SLOW

% Default Parameter Turbine and Controller
Parameter                           = DefaultParameter_SLOW2DOF;
Parameter                           = DefaultParameter_FBv1_ADv14(Parameter);

% Time
Parameter.Time.dt                   = 0.01;            % [s] simulation time step            
Parameter.Time.TMax                 = 60;              % [s] simulation length

% Wind
DeltaU                              = 1;
URef                                = 20;                
Disturbance.v_0.time                = [0;     0.01;      	30];            % [s]      time points to change wind speed
Disturbance.v_0.signals.values      = [URef;  URef+DeltaU;  URef+DeltaU];   % [m/s]    wind speeds  

% Initial Conditions from SteadyStates
SteadyStates = load('SteadyStatesShakti5MW_classic.mat','v_0','Omega','theta','x_T');                       
Parameter.IC.Omega          	    = interp1(SteadyStates.v_0,SteadyStates.Omega   ,URef,'linear','extrap');
Parameter.IC.theta          	    = interp1(SteadyStates.v_0,SteadyStates.theta   ,URef,'linear','extrap');
Parameter.IC.x_T                    = interp1(SteadyStates.v_0,SteadyStates.x_T     ,URef,'linear','extrap');

%% Processing SLOW
simout = sim('FBv1_SLOW2DOF_With_TowerDamper.mdl');

%% PostProcessing SLOW
figure

% plot rotor speed
subplot(211)
hold on;box on;grid on;
plot(simout.tout,simout.logsout.get('y').Values.Omega.Data*60/2/pi)
ylabel('$\Omega$ [rpm]','Interpreter','latex')

% plot tower top velocity
subplot(212)
hold on;box on;grid on;
plot(simout.tout,simout.logsout.get('y').Values.x_T_dot.Data)
ylabel('$\dot x_T$ [m/s]','Interpreter','latex')
xlabel('time [s]')