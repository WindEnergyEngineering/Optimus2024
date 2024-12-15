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
X = S + 2*randn(size(t));
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

H_HP = tf([w_0_HP 0],[w_0_HP 1])
disp('--- LP-Filter ---------------------------------------------')
damp(H_HP)
disp('---------------------------------------------------------------------')
figure
grid on
bode(H_HP)

%% Filter effect - frequency domain
% Compute the frequency response of the LP-filter
[H, W] = freqresp(H_LP, 2*pi*f); % 2*pi*f converts frequency to rad/s

% Apply the filter (element-wise multiplication)
Filtered_P_f = squeeze(H) .* P1.';

% Compute the frequency response of the Notch-filter
[H_notch, W_notch] = freqresp(H_N, 2*pi*f); % 2*pi*f converts frequency to rad/s

% Apply the filter (element-wise multiplication)
Filtered_P_f_notch = squeeze(H_notch) .* Filtered_P_f;

% transform back to time domain
P_t_filtered_notch = ifft(Filtered_P_f_notch, 'symmetric'); % Signal after both filters


% Plot the results
figure;
subplot(3, 1, 1);
plot(f, abs(P1));
title('Original Signal in Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('|P(f)|');

subplot(3, 1, 2);
plot(f, abs(Filtered_P_f));
title('LP-Filtered Signal in Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('|LP-Filtered P(f)|');

subplot(3, 1, 3);
plot(f, abs(Filtered_P_f_notch));
title('Notch-Filtered Signal in Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('|Notch-Filtered P(f)|');

figure
subplot(2,1,1)
plot(t(1:751)*1000, X(1:751));
title('Original signal in Time Domain');
xlabel('Time [ms]');
ylabel('Amplitude');

subplot(2,1,2)
plot(t(1:751)*1000, P_t_filtered_notch*1000);
title('Signal After Low Pass and Notch Filters in Time Domain');
xlabel('Time [ms]');
ylabel('Amplitude');
%% Bode of final Signa
% Compute the phase of the original signal
Phase_P_f = angle(P1);

% Compute the phase of the double-filtered signal
Phase_Filtered_P_f_Notch = angle(Filtered_P_f_notch);

% Compute the phase displacement
Phase_Displacement = unwrap(Phase_Filtered_P_f_Notch - Phase_P_f);



% Plot the phase displacement
figure;
plot(f, rad2deg(Phase_Displacement));
title('Phase Displacement Between Original and Double-Filtered Signal');
xlabel('Frequency (Hz)');
ylabel('Phase Displacement (radians)');
grid on;

%% Filter signal - Simulink time domain

% SimulationTmax = t(end);
% dt             = SimulationTmax/length(t);
% Enable_LP       = 1;
% Enable_N        = 1;
% Enable_HP       = 0;
% 
% simout = sim("TestFilter.slx");
% 
% tsim = simout.tout;
% S_n = simout.logsout.get('d').Values.d.Data;
% S_LP = simout.logsout.get('y_LP').Values.y_LP.Data;
% S_N = simout.logsout.get('y_LP_N').Values.y_N.Data;
% S_HP = simout.logsout.get('y_LP_N_HP').Values.y_HP.Data;
% 
% figure
% hold on; grid on;
% plot(tsim(1:100)*1000,S_n(1:100))
% plot(tsim(1:100)*1000,S_LP(1:100))
% plot(tsim(1:100)*1000,S_N(1:100))
% plot(tsim(1:100)*1000,S_HP(1:100))
% ylabel('X(t)')
% xlabel('t[ms]')
% legend('Unfilterd','LP-filtered','Notch-filtered','HP-filterd')
 