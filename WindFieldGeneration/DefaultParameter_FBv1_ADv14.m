function [Parameter] = DefaultParameter_FBv1_ADv14(Parameter)
% DS on 03-Feb-2019

%% Pitch Controller
Parameter.CPC.theta_K                   = deg2rad(20);                      % [rad]     % gain scheduling parameter, brute-force-optimized
Parameter.CPC.kp                        = 0.025;                          	% [s]       % proportional gain, brute-force-optimized
Parameter.CPC.Ti                        = 10;                               % [s]       % integral gain, brute-force-optimized

Parameter.CPC.Omega_g_rated             = rpm2radPs(11.753)/Parameter.Turbine.i; % [rad/s]  % rated generator speed, from Pietro
Parameter.CPC.theta_min                 = deg2rad(1.2);                     % [rad]     % pitch angle in region 1-2.5, brute-force optimized

%% Torque Controller
Parameter.VSC.kp                        = 3000;                             % [Nm/(rad/s)]  % proportional gain, first guess
Parameter.VSC.Ti                        = 2.5;                              % [s]           % integral gain, first guess
Parameter.VSC.k                         = 1.9;                              % [Nm/(rad/s)^2]% gain region 2, brute-force-optimized

P_a_rated  = 3.6e6;                                                         % [W]       % maximal aerodynamic power (can be changed for de- or up-rating), from Pietro
Parameter.VSC.M_g_rated                 = P_a_rated/Parameter.CPC.Omega_g_rated*Parameter.Turbine.eta_gb;  % [Nm] rated generator torque
Parameter.VSC.i_G_max                   = 1.1;                              % [-]       % ratio for maximum generator torque, standard value
Parameter.VSC.Omega_g_1d5               = rpm2radPs(8)/Parameter.Turbine.i; % [rad/s]   % generator speed during region 1.5, brute-force-optimized          

Parameter.VSC.Delta_Omega_g             = 0.10*Parameter.CPC.Omega_g_rated; % [rad/s]   % over-/under-speed limit for setpoint-fading, first guess
Parameter.VSC.Delta_theta               = deg2rad(20);                      % [rad]     % change of pitch angle at which under-speed limit should be reached, brute-force-optimized
Parameter.VSC.Delta_P                   = 3.35e6;                          	% [W]       % change of power at which over-speed limit should be reached, first guess

%% Filter Generator Speed
Parameter.Filter.LowPass.Enable         = 1;                                % [0/1]     % flag to enable low pass filter for generator speed
Parameter.Filter.LowPass.f_cutoff       = 1;                                % [Hz]      % cut-off-frequency for low pass filter for generator speed, first guess
Parameter.Filter.LowPass2.f_cutoff     	= 0.02;                             % [Hz]      % cut-off-frequency for low pass filter for setpoint-fading, first guess
Parameter.Filter.LowPass3.f_cutoff      = 0.01;                             % [Hz]      % cut-off-frequency for low pass filter for dynamic notch filter, first guess
Parameter.Filter.NotchFilter.Enable   	= 1;                                % [0/1]     % flag to enable dynamic notch filter for generator speed
Parameter.Filter.NotchFilter.Gain       = 3*Parameter.Turbine.i;            % [-]       % gain on generator rotational frequency for dynamic notch filter, standard value
Parameter.Filter.NotchFilter.BW      	= 0.10;                             % [Hz]      % bandwidth of dynamic notch filter, first guess
Parameter.Filter.NotchFilter.D       	= 0.01;                             % [-]       % depth of dynamic notch filter, first guess
                             
%% helper functions
function y = rpm2radPs(u)
    y = u * 2*pi/60;

end

end


