% filter chain test

clearvars;close all;clc;

% Default Parameter Turbine and Controller
Parameter                           = DefaultParameter_SLOW2DOF;
Parameter                           = DefaultParameter_PitchActuator(Parameter);
Parameter                           = DefaultParameter_FBv1_ADv14(Parameter);

f_Tower         = 0.28;                             % [Hz]      Eigenfrequency of the Tower

%% Simulink Test
Parameter.Time.dt                   = 1/100;            % [s] simulation time step  
dt = Parameter.Time.dt;
Parameter.Time.TMax                 = 10;            % [s] simulation length
T = Parameter.Time.TMax;
t = (0:dt:T);        % Time vector         [s]

% Form a signal containing a f_Tower Hz sinusoid
u = cos(2*pi*f_Tower*t);

Disturbance.v_0.time = t';
Disturbance.v_0.signals.values = u';

% Initial Conditions from SteadyStates
% SteadyStates = load('SteadyStatesShakti5MW_classic.mat','v_0','Omega','theta','x_T','M_g');                       
% Parameter.IC.Omega          	    = interp1(SteadyStates.v_0,SteadyStates.Omega   ,URef,'linear','extrap');
Parameter.IC.theta          	    = 0;%interp1(SteadyStates.v_0,SteadyStates.theta   ,URef,'linear','extrap');
% Parameter.IC.x_T                    = interp1(SteadyStates.v_0,SteadyStates.x_T     ,URef,'linear','extrap');
% Parameter.IC.M_g          	        = interp1(SteadyStates.v_0,SteadyStates.M_g     ,URef,'linear','extrap');

Parameter.TD.gain = 1;%0.0424;
Gain = 0.06;
simout = sim('TestFilter.slx');

time = simout.tout;
input = simout.logsout.get('Log').Values.v_0.Data;
theta_ref = simout.logsout.get('Log').Values.theta_ref.Data;
theta_filter = simout.logsout.get('Log').Values.theta_filter.Data;
%% Plotting
figure
hold on; grid on;
plot(time,input)
plot(time,theta_ref)
plot(time,theta_filter)
xlabel('time [s]')
ylabel('\theta [rad]')
legend('Input','Integrator', 'Filter',Location='southwest')