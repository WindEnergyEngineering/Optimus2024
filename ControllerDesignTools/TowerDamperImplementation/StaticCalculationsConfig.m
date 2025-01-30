%% StaticCalculationsConfig
% Function: Config for StaticCalculations
%        
% 
%% Usage:
% Adjust CalculationName and run StaticCalculations
%
% Following needs to be declared in the corresponding case:
% - Parameter.Turbine
%   Parameter.Turbine.R
%   Parameter.Turbine.i
%   Parameter.Turbine.SS
%   Parameter.Turbine.J
% - Parameter.VSC
%   Everything, which is necessary for the VSC 
% - v_0: wind speeds to calculate the steady states
% - v_rated
%% Input:
%
% 
%% Output:
% 
%
%% Modified:
%
%
%
%% ToDo:
%
%
%% Created:
% David Schlipf on     19-Dec-2014
%
% (c) Universitaet Stuttgart

function [v_0,FlagPITorqueControl,FlagPS,Parameter] = StaticCalculationsConfig


CalculationName  = 'NREL5MW_FBSWE'; 

FlagPS           = 0; % Peak shaving 1 = on, 0 = off

switch CalculationName

    case {'NREL5MW_FBSWE'}        
        % Exercise 8.2a: adjusted by fle (12.11.24)
        
        % Default
        Parameter                       	= DefaultParameter_SLOW2DOF;
        Parameter                           = DefaultParameter_FBv1_ADv14(Parameter);           

        
        % NonlinearStateFeedback
     	Parameter.VSC.NonlinearStateFeedback    = @kOmegaSquare; %only used if OmegaDot has only 4 Inputs (e.g. Region 2): adjusted by fle (15.11.24)       
        FlagPITorqueControl         	= 1; % 0: only State Feedback, 1: PI controlled in region 1.5 and 2.5
        
        % Wind speeds
        v_0         = 3.5:.1:30; % [m/s]
        
        % Region wind speeds produced by HowToFindRegionWindSpeed.m
        % legend  = ["rated"    "1"     "1.5"       "2.5"];
        % v_regions = [ 9.5775    3.0345    6.3874    9.3838]; % [m/s] 3.4 Turbine works well
        v_regions = [9.3772    2.7049    6.0905    8.6992];     % [m/s] 5MW SHAKTI, C_p Version 5 Omega_g_rated = 428.5 rpm, Including eta_GB, from fle 26/11/24
%         v_regions = [10.5211    2.7049    5.9931    8.875];     % [m/s] 5MW SHAKTI, C_p Version 5 Omega_g_rated = 428.5 rpm, peak shaping
        
        % find v_rated
        v_0_min                         = 0;
        v_0_max                         = 30;        
        Omega                           = Parameter.CPC.Omega_g_rated/Parameter.Turbine.r_GB;
        theta                           = Parameter.CPC.theta_min;  
        M_g                             = Parameter.VSC.M_g_rated;
        Parameter.VSC.v_rated         	= v_regions(1); 

        % find v_1
        v_0_min                         = 0;
        v_0_max                         = 30;
        theta                           = Parameter.CPC.theta_min;
        k                               = Parameter.VSC.k;  
        Omega                           = Parameter.VSC.Omega_g_1d5/Parameter.Turbine.r_GB;
        M_g                             = 0;
        Parameter.VSC.v_1               = v_regions(2); % Davids value was 3.0 m/s here      
                                                    
        % find v_1d5
        v_0_min                         = 0;
        v_0_max                         = 30;
        theta                           = Parameter.CPC.theta_min;
        k                               = Parameter.VSC.k;  
        Omega                           = Parameter.VSC.Omega_g_1d5/Parameter.Turbine.r_GB;
        M_g                             = k*(Omega*Parameter.Turbine.r_GB)^2;
        Parameter.VSC.v_1d5             = v_regions(3);  
                                                   

        % find v_2d5
        v_0_min                         = 0;
        v_0_max                         = 30;
        theta                           = Parameter.CPC.theta_min;
        k                               = Parameter.VSC.k;  
        Omega                           = Parameter.CPC.Omega_g_rated/Parameter.Turbine.r_GB;
        M_g                             = k*(Omega*Parameter.Turbine.r_GB)^2;
        Parameter.VSC.v_2d5             = v_regions(4);
end

end
