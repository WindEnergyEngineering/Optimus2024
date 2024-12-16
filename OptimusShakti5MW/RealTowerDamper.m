
clearvars;close all;clc;
%% PreProcessing SLOW

% Default Parameter Turbine and Controller
Parameter                           = DefaultParameter_SLOW2DOF;
Parameter                           = DefaultParameter_FBv1_ADv14(Parameter);

% Time
Parameter.Time.dt                   = 1/10;            % [s] simulation time step            
Parameter.Time.TMax                 = 60;            % [s] simulation length

% Wind
DeltaU                              = 1;
URef                                = 20;                
Disturbance.v_0.time                = [0;     0.01;      	30];            % [s]      time points to change wind speed
Disturbance.v_0.signals.values      = [URef;  URef+DeltaU;  URef+DeltaU];   % [m/s]    wind speeds  

% Initial Conditions from SteadyStates
SteadyStates = load('SteadyStatesShakti5MW_classic.mat','v_0','Omega','theta','x_T','M_g');                       
Parameter.IC.Omega          	    = interp1(SteadyStates.v_0,SteadyStates.Omega   ,URef,'linear','extrap');
Parameter.IC.theta          	    = interp1(SteadyStates.v_0,SteadyStates.theta   ,URef,'linear','extrap');
Parameter.IC.x_T                    = interp1(SteadyStates.v_0,SteadyStates.x_T     ,URef,'linear','extrap');
Parameter.IC.M_g          	        = interp1(SteadyStates.v_0,SteadyStates.M_g     ,URef,'linear','extrap');
%% Real Tower damper design

f_3P            = Parameter.CPC.Omega_g_rated/2/pi; % [Hz]      3P under rated conditions. Here the TD is active
f_Tower         = 0.28;                              % [Hz]      Eigenfrequency of the Tower

% LP Design
f_c_LP = 1;
w_0_LP = f_c_LP*2*pi;
num_LP = [w_0_LP];
denum_LP = [1 w_0_LP];
H_LP = tf(num_LP,denum_LP)
disp('--- LP-Filter ---------------------------------------------')
damp(H_LP)
disp('---------------------------------------------------------------------')
figure
hold on;grid on;
bode(H_LP)

% Notch Design 
f_c_N = 1;%f_3P;
w_0_N = f_c_N*2*pi;
D = 0.01;
BW = 0.1;
num_Notch = [1 2*BW*D*w_0_N w_0_N^2];
denum_Notch = [1 2*BW*w_0_N w_0_N^2];
H_N = tf(num_Notch,denum_Notch)
disp('--- LP-Filter ---------------------------------------------')
damp(H_N)
disp('---------------------------------------------------------------------')
figure
grid on;
bode(H_N)

% HP Design
f_c_HP = 0.1;
w_0_HP = f_c_HP*2*pi;
num_HP = [1 0];
denum_HP = [1 w_0_HP];
H_HP = tf(num_HP,denum_HP)
disp('--- LP-Filter ---------------------------------------------')
damp(H_HP)
disp('---------------------------------------------------------------------')
figure
grid on
bode(H_HP)

% % All Pass design
% % Sampling frequency and parameters
% fs = 1000;               % Sampling frequency in Hz
% f_interest = f_Tower;  % Frequency of interest in Hz
% theta = pi/2;          % Desired phase shift (+90 degrees)
% f_c_all = f_interest/fs;
% % All-pass filter design for +90° shift
% omega = 2 * pi * f_interest / fs; % Normalized angular frequency
% b = [1 cos(omega)];    % Numerator coefficients
% a = [1 -cos(omega)];   % Denominator coefficients
% 
% % Create transfer function
% H_allpass = tf(b,a);
% 
% % Display the transfer function
% disp('All-Pass Filter Transfer Function:');
% H_allpass
% % Plot frequency response
% figure;
% freqz(b, a, 1024, fs);
% title('Frequency Response of the All-Pass Filter');
%% Processing SLOW
% simout = sim('FBv1_SLOW2DOF_with_TowerDamper.mdl');
% Parameter.TD.gain = 0;%0.0424;
TDFlag = 0;
simoutClassic = sim('FBv1_SLOW2DOF_with_TowerDamper.mdl');

t = simoutClassic.tout;
x_dotdot = simoutClassic.logsout.get('y').Values.x_T_dotdot.Data;
x_dot = simoutClassic.logsout.get('y').Values.x_T_dot.Data;

%% Test Filter Design
% Parameter.TD.gain = 0.04;
TDFlag = 1;
simout = sim('FBv1_SLOW2DOF_with_TowerDamper.mdl');
x_dot_est = simout.logsout.get('y').Values.x_T_dot.Data;
figure
hold on; grid on;
plot(t,x_dot)
plot(simout.tout,x_dot_est)
ylabel('$\dot x_T$ [m/s]','Interpreter','latex')
xlabel('$t$ [s]','Interpreter','latex')
legend('reference','estimated')

%% Check frequencies
Y_1 = fft(x_dotdot);
Y_2 = fft(simout.logsout.get('y').Values.x_T_dotdot.Data);
fs =  1/Parameter.Time.dt;      % Sampling frequency  [Hz]
T = 1/fs;                       % Sampling period     [s]       
L = Parameter.Time.TMax/T+1;    % Length of signal    [-]

% Compute the two-sided spectrum P2. Then compute the single-sided spectrum P1 based on P2 and the even-valued signal length L.
P2 = abs(Y_1/L);
P2_2 = abs(Y_2/L);
P1 = P2(1:L/2+1);
P1_2 = P2_2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
P1_2(2:end-1) = 2*P1_2(2:end-1);
% Define the frequency domain f and plot the single-sided amplitude spectrum P1
f = fs*(0:(L/2))/L;

figure
hold on; grid on;
plot(f,P1) 
plot(f,P1_2)
title("Single-Sided Amplitude Spectrum of X(t)")
xlabel("f (Hz)")
ylabel("|P1(f)|")
legend('Integrator','Filtered')
