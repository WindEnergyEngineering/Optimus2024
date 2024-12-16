clearvars;close all;clc;

%% 50 Hz Signal
Fs = 1000;            % Sampling frequency  [Hz]                    
T = 1/Fs;             % Sampling period     [s]       
L = 1500;             % Length of signal    [-]
t = (0:L-1)*T;        % Time vector         [s]
% Define the frequency domain f and plot the single-sided amplitude spectrum P1
f = Fs*(0:(L/2))/L;
% t = (0:1/Fs:(length(f)-1)/Fs); % Time vector

% Form a signal containing a 50 Hz sinusoid of amplitude 0.7
S = 0.7*sin(2*pi*50*t);

% Corrupt the signal with zero-mean white noise with a variance of
X = S + randn(size(t));
Disturbance.signal.time = t';
Disturbance.signal.signals.values = X';


figure
hold on; grid on;
plot(1000*t(1:50),X(1:50))
title("Signal Corrupted with Zero-Mean Random Noise")
xlabel("t [ms]")
ylabel("X(t)")

% FFT
Y = fft(X);

% Compute the two-sided spectrum P2. Then compute the single-sided spectrum P1 based on P2 and the even-valued signal length L.
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);



figure
hold on; grid on;
plot(f,P1) 
title("Single-Sided Amplitude Spectrum of X(t)")
xlabel("f (Hz)")
ylabel("|P1(f)|")

%% LP-Filter
f_c_LP = 50;
w_0_LP = f_c_LP*2*pi;

H_LP = tf([w_0_LP],[1 w_0_LP])
disp('--- LP-Filter ---------------------------------------------')
damp(H_LP)
disp('---------------------------------------------------------------------')
figure
hold on;grid on;
bode(H_LP)

%% 3P-Notch
f_c_N = 50;
w_0_N = f_c_N*2*pi;
D = 0.01;
BW = 0.1;

H_N = tf([1 2*BW*D*w_0_N w_0_N^2],[1 2*BW*w_0_N w_0_N^2])
disp('--- LP-Filter ---------------------------------------------')
damp(H_N)
disp('---------------------------------------------------------------------')
figure
grid on;
bode(H_N)

%% HP-Filter
f_c_HP = 50;
w_0_HP = f_c_HP*2*pi;

H_HP = tf([1 0],[1 w_0_HP])
disp('--- LP-Filter ---------------------------------------------')
damp(H_HP)
disp('---------------------------------------------------------------------')
figure
grid on
bode(H_HP)
%% AllPass-Filter
% Sampling frequency and parameters
fs = 10;             % Sampling frequency in Hz
f_interest = .28;       % Frequency of interest in Hz
theta = pi/2;          % Desired phase shift (+90 degrees)

% All-pass filter design for +90° shift
omega = 2 * pi * f_interest / fs; % Normalized angular frequency
b = [1 cos(omega)];    % Numerator coefficients
a = [1 -cos(omega)];   % Denominator coefficients

% Create transfer function
H_allpass = tf(b,a);

% Display the transfer function
disp('All-Pass Filter Transfer Function:');
H_allpass
% Plot frequency response
figure;
freqz(b, a, 1024, fs);
title('Frequency Response of the All-Pass Filter');
%% Filter effect - frequency domain
% Compute the frequency response of the LP-filter
[H, W] = freqresp(H_LP, 2*pi*f); % 2*pi*f converts frequency to rad/s

% Apply the filter (element-wise multiplication)
Filtered_P_f = squeeze(H) .* P1.';

% Compute the frequency response of the Notch-filter
% [H_notch, W_notch] = freqresp(H_N, 2*pi*f); % 2*pi*f converts frequency to rad/s

% Compute the frequency response of the HP-filter
[H_HP, W] = freqresp(H_HP, 2*pi*f); % 2*pi*f converts frequency to rad/s

% Apply the filter (element-wise multiplication)
Filtered_P_f_LHP = squeeze(H_HP) .* Filtered_P_f;

% Back into the time domain
P_t_filtered = ifft(Filtered_P_f_LHP,'symmetric');

% Apply the Hilbert transform
analytic_signal = hilbert(P_t_filtered);          % Compute the analytic signal
P_t_filtered_shifted = -imag(analytic_signal); % Extract the imaginary part (90° phase shift)
%% Plot the results
figure;
subplot(3, 1, 1);
plot(f, abs(P1));
title('Original Signal in Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('|P(f)|');
ylim([0 .7])

subplot(3, 1, 2);
plot(f, abs(Filtered_P_f));
title('LP-Filtered Signal in Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('|LP-Filtered P(f)|');
ylim([0 .7])

subplot(3, 1, 3);
plot(f, abs(Filtered_P_f_LHP));
title('LP+HP-Filtered in Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('|LP+HP-Filtered P(f)|');
ylim([0 .7])

figure
hold on;grid on;
plot(t(1:751)*1000,X(1:751))
plot(t(1:751)*1000,P_t_filtered*1000)
plot(t(1:751)*1000,P_t_filtered_shifted*1000)
xlabel('t [ms]')
ylabel('Amplitude')
legend('unfitered','filtered','filtered+shifted')
%% Bode of final Signal
% % Compute the phase of the original signal
% Phase_P_f = angle(P1);
% 
% % Compute the phase of the double-filtered signal
% Phase_Filtered_P_f = angle(Filtered_P_f_All);
% 
% % Compute the phase displacement
% Phase_Displacement = unwrap(Phase_Filtered_P_f - Phase_P_f);
% 
% 
% 
% % Plot the phase displacement
% figure;
% plot(f, rad2deg(Phase_Displacement));
% title('Phase Displacement Between Original and Double-Filtered Signal');
% xlabel('Frequency (Hz)');
% ylabel('Phase Displacement (radians)');
% grid on;

%% Filter signal - Simulink time domain

SimulationTmax = t(end);
dt             = SimulationTmax/length(t);
Enable_LP       = 1;
Enable_HP       = 1;

% FIR Hilbert Filter
fs = 1000;             % Sampling frequency
N = 64;                % Filter order (adjust based on precision requirements)
h = -firpm(N, [0.1 0.9], [1 1], 'hilbert'); % FIR Hilbert transform filter

% All-Pass Filter
fs = 1000;               % Sampling frequency
f_interest = 10;         % Frequency of interest
omega = 2 * pi * f_interest / fs;

% All-pass filter coefficients for +90° shift
b = [1 cos(omega)]; % Numerator
a = [1 -cos(omega)];% Denuminator

simout = sim("TestFilter.slx");

tsim = simout.tout;
S_n = simout.logsout.get('d').Values.d.Data;
S_LP = simout.logsout.get('y_LP').Values.y_LP.Data;
S_HP = simout.logsout.get('y_all').Values.y_HP.Data;
y = simout.logsout.get('y').Values.y.Data;

figure
hold on; grid on;
plot(tsim(1:100)*1000,S_n(1:100))
plot(tsim(1:100)*1000,S_LP(1:100))
plot(tsim(1:100)*1000,S_HP(1:100))
plot(tsim(1:100)*1000,y(1:100))
ylabel('X(t)')
xlabel('t[ms]')
legend('Unfilterd','LP-filtered','LP+HP-filterd','Filtered+shifted')

