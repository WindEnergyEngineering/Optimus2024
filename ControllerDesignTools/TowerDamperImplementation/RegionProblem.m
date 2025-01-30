clc;
format compact

P_a_rated = 5.42e6;
Omega_g_rated = rpm2radPs(458);
eta_gb = 0.955; 
M_g_rated = P_a_rated/Omega_g_rated*eta_gb

c_P_opt = 0.48;
lambda_opt = 8.75; 
rho = 1.225; 
R = 89; 
r_GB = 53.25;

M_g_2to2d5 = 1/2*rho*pi*R^2*c_P_opt*(Omega_g_rated/r_GB*R/lambda_opt)^3/(Omega_g_rated)*eta_gb

P_a_2to2d5 = 1/2*rho*pi*R^2*c_P_opt*(Omega_g_rated/r_GB*R/lambda_opt)^3