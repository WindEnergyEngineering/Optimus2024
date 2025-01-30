% -----------------------------
% Script: Calculates SteadyStates.
% Exercise 08 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ----------------------------------
%% 1. Initialitzation 
clearvars; close all;clc;
%% 2. Config
[v_0,FlagPITorqueControl,Flag1d5opt,FlagThetaMin,Parameter]    = StaticCalculationsConfig;

%% 3. Allocation
theta_set = 0:deg2rad(0.1):deg2rad(5);
Omega               = zeros(1,length(v_0));
theta               = zeros(1,length(v_0));
M_g                 = zeros(1,length(v_0));
Omega_dot_Sq        = zeros(1,length(v_0));
lambda              = zeros(1,length(v_0));
c_P                 = zeros(1,length(v_0));
max_c_p             = zeros(1,length(v_0));
max_cp_theta        = zeros(1,length(v_0));
max_lambda          = zeros(1,length(v_0));
exitflag            = zeros(1,length(v_0));

% Weilbull parameters
C                   = 2/sqrt(pi)*7.5;% [m/s] TC III
k                   = 2;            % [-]

%% 4. Loop over wind speeds to determine omega, theta, M_g
for iv_0=1:length(v_0)
    v_0i        	= v_0(iv_0);
    
    %% 4.1 Determin Region
    if FlagPITorqueControl == 1
            % Exercise 8.2a: adjusted by fle (13.11.24)
            if v_0i < Parameter.VSC.v_1
                Region = '1';
            elseif v_0i < Parameter.VSC.v_1d5 
                Region = '1.5';
            elseif v_0i >= Parameter.VSC.v_1d5 && v_0i < Parameter.VSC.v_2d5
                Region = '2';
            elseif v_0i >= Parameter.VSC.v_2d5 && v_0i < Parameter.VSC.v_rated
                Region = '2.5';
            else
                Region = '3';
            end
      
    else % no PI torque control
        if      v_0i < Parameter.VSC.v_rated
            Region = 'StateFeedback';
        else
            Region = '3';
        end
    end

    %% 4.2 Determin Static Values
    switch Region %
        case {'1'} %Determin Omega and M_g in Region 1, where theta is fixed: adjusted by fle (15.11.24)
            Omega_min   = rpm2radPs(0);
            Omega_max   = Parameter.VSC.Omega_g_1d5/Parameter.Turbine.r_GB;
            M_g_j       = 0;
            theta_j     = Parameter.CPC.theta_min;

            [Omega_j,Omega_dot_Sq(iv_0),exitflag(iv_0)] = ...
                fminbnd(@(Omega) (OmegaDot(Omega,theta_j,M_g_j,v_0i,Parameter))^2,...
                Omega_min,Omega_max,optimset('Display','none'));

            Omega(iv_0) = Omega_j;
            M_g(iv_0)   = M_g_j;
            theta(iv_0) = theta_j;


        case {'1.5'} %Determin M_g in Region 1.5, where theta and Omega_g is fixed: adjusted by fle (15.11.24)
            Omega_j     = Parameter.VSC.Omega_g_1d5/Parameter.Turbine.r_GB;

            if 1 == Flag1d5opt
                for manni = 1:length(theta_set)
                    lambda(manni)      = Omega_j*Parameter.Turbine.R/(v_0(iv_0));
                    c_P(manni)         = interp2(Parameter.Turbine.SS.theta,Parameter.Turbine.SS.lambda,Parameter.Turbine.SS.c_P,theta_set(manni),lambda(manni),'linear',0);
                end
                    
                [value, index] = max(c_P);
                max_c_p(iv_0) = value;
                max_cp_theta(iv_0) = theta(index);
                max_lambda(iv_0) = lambda(index);
    
                theta_j     = theta_set(index);
            else
                theta_j     = Parameter.CPC.theta_min;
            end

                M_g_min     = 0;
                M_g_max     = kOmegaSquare(Omega_j*Parameter.Turbine.r_GB,theta_j,Parameter);

                [M_g_j,Omega_dot_Sq(iv_0),exitflag(iv_0)] = ...
                    fminbnd(@(M_g) (OmegaDot(Omega_j,theta_j,M_g,v_0i,Parameter))^2,...
                    M_g_min,M_g_max,optimset('Display','none'));

            Omega(iv_0) = Omega_j;
            M_g(iv_0)   = M_g_j;
            theta(iv_0) = theta_j;

        case {'2','StateFeedback'} % Determin Omega and M_g in Region 2 (or 1-2.5 for state feedback), where theta is fixed 
            if 1 == FlagThetaMin
                for manni = 1:length(theta_set)
                    lambda(manni)      = Omega_j*Parameter.Turbine.R/(v_0(iv_0));
                    c_P(manni)         = interp2(Parameter.Turbine.SS.theta,Parameter.Turbine.SS.lambda,Parameter.Turbine.SS.c_P,theta_set(manni),lambda(manni),'linear',0);
                end
                    
                [value, index] = max(c_P);
                max_c_p(iv_0) = value;
                max_cp_theta(iv_0) = theta(index);
                max_lambda(iv_0) = lambda(index);
    
                theta_j     = theta_set(index);
            else
                theta_j     = Parameter.CPC.theta_min;
            end

            % Exercise 8.1b: adjusted by fle (12.11.24)
            Omega_min   = rpm2radPs(5); % to avoid Stall
            Omega_max   = Parameter.CPC.Omega_g_rated/Parameter.Turbine.r_GB;
           
            [Omega_j,Omega_dot_Sq(iv_0),exitflag(iv_0)] = ...
                fminbnd(@(Omega) (OmegaDot(Omega,theta_j,v_0i,Parameter))^2,...
                Omega_min,Omega_max,optimset('Display','none'));

            Omega(iv_0) = Omega_j;
            M_g(iv_0)   = Parameter.VSC.NonlinearStateFeedback(Omega_j*Parameter.Turbine.r_GB,theta_j,Parameter);
            theta(iv_0) = theta_j;


        case {'2.5'} %Determin M_g in Region 2.5, where theta and Omega_g is fixed: adjusted by fle (15.11.24)
            Omega_j     = Parameter.CPC.Omega_g_rated/Parameter.Turbine.r_GB;
            theta_j     = Parameter.CPC.theta_min;           
            M_g_min     = 0;
            M_g_max     = Parameter.VSC.M_g_rated; % M_g_rated for PS otherwise M_g_max is producing a small overswing in M and P

            [M_g(iv_0),Omega_dot_Sq(iv_0),exitflag(iv_0)] = ...
                fminbnd(@(M_g) (OmegaDot(Omega_j,theta_j,M_g,v_0i,Parameter))^2,...
                M_g_min,M_g_max,optimset('Display','none'));

            Omega(iv_0) = Omega_j;
            theta(iv_0) = theta_j;
        
                   
        case '3' % Determin theta in Region 3, where Omega and M_g are fixed   
            % Exercise 8.1b: adjusted by fle (12.11.24)
            Omega_j     = Parameter.CPC.Omega_g_rated/Parameter.Turbine.r_GB;
            theta_min   = Parameter.CPC.theta_min;
            theta_max   = max(Parameter.Turbine.SS.theta(:));
            M_g_j       = Parameter.VSC.M_g_rated;

            [theta_j,Omega_dot_Sq(iv_0),exitflag(iv_0)] = ...
                fminbnd(@(theta) (OmegaDot(Omega_j,theta,M_g_j,v_0i,Parameter))^2,...
                theta_min,theta_max,optimset('Display','none'));

            Omega(iv_0) = Omega_j;
            M_g(iv_0)   = M_g_j;
            theta(iv_0) = theta_j;           
    end
end

%% 5. Calculation of additional variables
% Exercise 8.1b: adjusted by fle (12.11.24)
lambda   	= Omega*Parameter.Turbine.R./v_0;
c_T      	= interp2(Parameter.Turbine.SS.theta,Parameter.Turbine.SS.lambda,Parameter.Turbine.SS.c_T,theta,lambda,'linear',0);
F_a      	= .5*pi*Parameter.Turbine.R^2*c_T*Parameter.General.rho.*v_0.^2;
x_T         = F_a/Parameter.Turbine.k_Te+Parameter.Turbine.x_T0;
P           = M_g*Parameter.Generator.eta_el.*Omega*Parameter.Turbine.r_GB;

% Exercise 8.2c: 
Distribution    = k/C*(v_0/C).^(k-1).*exp(-(v_0/C).^k);
Weights         = Distribution/sum(Distribution); % relative frequency


if  1 == Flag1d5opt
    AEP_1d5opt = sum(P.*Weights)*8760;
    save("SteadyStatesShakti5MW_PS.mat","v_0","Omega","M_g","theta","x_T","P","AEP_1d5opt")
elseif  1 == FlagThetaMin
    AEP_ThetaMinOpt = sum(P.*Weights)*8760;
    save("SteadyStatesShakti5MW_ThetaMinOpt.mat","v_0","Omega","M_g","theta","x_T","P","AEP_ThetaMinOpt")
else
    AEP_classic = sum(P.*Weights)*8760;
    save("SteadyStatesShakti5MW_classic.mat","v_0","Omega","M_g","theta","x_T","P","AEP_classic")
end 
%% 6. Plot
figure('Name','Omega')
hold on;grid on;box on;
plot(v_0,radPs2rpm(Omega),'.')
xlabel('v_0 [m/s]')
ylabel('\Omega [rpm]')

figure('Name','theta')
hold on;grid on;box on;
plot(v_0,rad2deg(theta),'.')
xlabel('v_0 [m/s]')
ylabel('\theta [deg]')

figure('Name','M_g')
hold on;grid on;box on;
plot(v_0,M_g,'.')
xlabel('v_0 [m/s]')
ylabel('M_g [Nm]')

figure('Name','x_T')
hold on;grid on;box on;
plot(v_0,x_T,'.')
xlabel('v_0 [m/s]')
ylabel('x_T [m]')

figure('Name','P')
hold on;grid on;box on;
plot(v_0,P/1e6,'.')
xlabel('v_0 [m/s]')
ylabel('P [MW]')

figure('Name','Torque Controller')
hold on;grid on;box on;
plot(radPs2rpm(Omega),M_g/1e3,'.-')
xlabel('Omega [rpm]')
ylabel('M_g [kNm]')

figure
hold on;grid on;box on
title('power coefficient')
contour(rad2deg(Parameter.Turbine.SS.theta),Parameter.Turbine.SS.lambda,max(Parameter.Turbine.SS.c_P,-0.1),[0,0.1:.1:0.4,0.45,0.465],'ShowText','on')
plot(rad2deg(theta),lambda,'k.')
plot(0.5,8.63784852687146,'-o','MarkerFaceColor','red','MarkerEdgeColor','red')
xlim([0 30])
xlabel('pitch [deg]')
ylabel('lambda [-]')
legend('','\theta_{min} = 0 deg','\theta_{min} = \theta_{min-opt} = 0.5 deg')

%%
figure('Name','P')
hold on;grid on;box on;
load("SteadyStatesShakti5MW_classic.mat")
plot(v_0,P,'.')
load("SteadyStatesShakti5MW_classic_IECrho.mat");
plot(v_0,P,'.')
xlabel('v_0 [m/s]')
ylabel('P [W]')
legend('\rho 1.12 [kg/m^3]','\rho 1.225 [kg/m^3]')
