% Function: VSControlNREL5MW 
% Wrapper for Variable Speed Control of NREL Feedback Controller
% for NREL5MW reference wind turbine (Nonlinear State Feedback).
% For use within OmegaDot for StaticCalculations.
% 
% --------------------------------
% Usage:
% -------------
% M_g = VSControlNREL5MW(Omega_g,theta,Parameter)
% -------------
% Input:
% -------------
% Omega_g   - generator speed
% theta     - pitch angle
% Parameter - Struct with VSC Parameter
% -------------
% Output:
% -------------
% M_g       - Generator Torque
% -------------
% Needs:
% -------------
%
% -------------
% Modified:
% -------------
% 
% -------------
% ToDo:
% -------------
% * Copy from Simulink Block:
%   Might be better integerated to have only one source. However, first try
%   produced problems when compiling Simulink.
% -------------
% Created:
% David Schlipf on 04-Feb-2017
% (c) Universitaet Stuttgart
% ----------------------------------
function M_g = VSControlNREL5MW(Omega_g,theta,Parameter)

% inputs to Simulink
SwitchR3        = theta>Parameter.VSC.theta_fine;
Omega_g_1To1_5  = Parameter.VSC.Omega_g_1To1_5;
Omega_g_1_5To2  = Parameter.VSC.Omega_g_1_5To2;
Omega_g_2To2_5  = Parameter.VSC.Omega_g_2To2_5;
Omega_g_2_5To3  = Parameter.VSC.Omega_g_2_5To3;  
a_1_5           = Parameter.VSC.a_1_5;           
b_1_5           = Parameter.VSC.b_1_5;
k               = Parameter.VSC.k;
a_2_5           = Parameter.VSC.a_2_5;
b_2_5           = Parameter.VSC.b_2_5;
M_g_rated       = Parameter.VSC.M_g_rated;
P_a_rated       = M_g_rated*Parameter.CPC.Omega_g_rated;%Parameter.VSC.P_a_rated; Adjusted by fle (12.11.24)
Mode            = Parameter.VSC.Mode;

% call function from Simulink Block
M_g = BaselineVSControl(Omega_g,SwitchR3,...  	% signals
    Omega_g_1To1_5,Omega_g_1_5To2,Omega_g_2To2_5,Omega_g_2_5To3,... % region limits
    a_1_5,b_1_5,...                                     % Region 1.5 parameters
    k,...                                               % Region   2 parameters
    a_2_5,b_2_5,...                                     % Region 2.5 parameters
    M_g_rated,P_a_rated,Mode);                          % Region   3 parameters

end

function M_g = BaselineVSControl(Omega_g,SwitchR3,...  	% signals
    Omega_g_1To1_5,Omega_g_1_5To2,Omega_g_2To2_5,Omega_g_2_5To3,... % region limits
    a_1_5,b_1_5,...                                     % Region 1.5 parameters
    k,...                                               % Region   2 parameters
    a_2_5,b_2_5,...                                     % Region 2.5 parameters
    M_g_rated,P_a_rated,Mode)                           % Region   3 parameters

if  Mode == 1   % Power constant
    M_g_3 = P_a_rated/Omega_g;
else            % Torque constant
    M_g_3 = M_g_rated;
end

if      Omega_g_2_5To3  <   Omega_g     % Region 3
    M_g     = M_g_3;

elseif  Omega_g_2To2_5  <   Omega_g     % Region 2.5
    M_g_2_5 = a_2_5 * Omega_g + b_2_5;
    M_g     = SwitchR3*M_g_3+(1-SwitchR3)*M_g_2_5;

elseif  Omega_g_1_5To2  <   Omega_g     % Region 2
    M_g_2   = k * Omega_g^2;
    M_g     = SwitchR3*M_g_3+(1-SwitchR3)*M_g_2;  
    
elseif  Omega_g_1To1_5  <   Omega_g     % Region 1.5
    M_g = a_1_5 * Omega_g + b_1_5;

else                                    % Region 1 
    M_g = 0;    
end

end