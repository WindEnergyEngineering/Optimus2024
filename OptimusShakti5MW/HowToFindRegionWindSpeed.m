% -----------------------------
% Script: Finding wind speed for all regions, including rated.
% Optimus Project 2024/2025
% Authors: Felix Lehmann, Karan Soni, Julius Preuschoff
% Script based on:
% Exercise 08 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% by Prof. David Schlipf
% ----------------------------------
clearvars;clc;close all;
%% Find rated wind speed
clearvars;close all;
Parameter                       	    = DefaultParameter_SLOW2DOF;
Parameter                               = DefaultParameter_FBv1_ADv14(Parameter);   
v_0                                     = 0:.1:30; % [m/s]
v_0_min                                 = 0;
v_0_max                                 = 30;        
theta                                   = Parameter.CPC.theta_min;
k                                       = Parameter.VSC.k;  

regions = ["rated" "1" "1.5" "2.5"];
v_regions = NaN; % [m/s]
for r = 1:1:length(regions)
region = regions(r);
switch region
    case 'rated'
        Omega = Parameter.CPC.Omega_g_rated/Parameter.Turbine.r_GB;
        M_g   = Parameter.VSC.M_g_rated;
    case '1'
        Omega = Parameter.VSC.Omega_g_1d5/Parameter.Turbine.r_GB;
        M_g   = 0;  
    case '1.5'
        Omega = Parameter.VSC.Omega_g_1d5/Parameter.Turbine.r_GB;
        M_g   = k*(Omega*Parameter.Turbine.r_GB)^2;
    case '2.5'
        Omega = Parameter.CPC.Omega_g_rated/Parameter.Turbine.r_GB;
        M_g   = k*(Omega*Parameter.Turbine.r_GB)^2; 
    otherwise
        disp('error')
end

% Brute Force Optimization       
for  iv_0=1:length(v_0)        
    Residual(iv_0)=OmegaDot(Omega,theta,M_g,v_0(iv_0),Parameter); 
end        

figure
hold on
Select_str = num2str(region);
title("Region " + Select_str)
plot(v_0,Residual*60/2/pi)
plot([v_0(1) v_0(end)],[0,0])
xlabel('wind speed [m/s]')
ylabel('rotor acceleration [rpm/s]')
% Optimization using fminbnd
fun = @(v)(OmegaDot(Omega,theta,M_g,v,Parameter))^2;
v1 = 2.5;
v2 = 30;
[v,Omega_dot_Sq,exitflag] = fminbnd(fun,v1,v2,optimset('Display','none'));
v_regions(r) = v;
end
format compact;
regions
v_regions
