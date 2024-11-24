function [Parameter] = DefaultParameter_SLOW2DOF
% DS on 11-Jun-2020

%% General          
Parameter.General.rho               = 1.12;         	% [kg/m^3]  air density, from requirments list

%% Turbine
Parameter.Turbine.SS             	= load('PowerAndThrustCoefficients_SHAKTI_v5.mat','c_P','c_T','theta','lambda'); % from simulations

Parameter.Turbine.i               	= 1/53.25;          % [-]       gearbox ratio, from ElastoDyn.dat:1/GBRatio, from Shakti(german) 20/11/24 fle  
Parameter.Turbine.r_GB              = 1/Parameter.Turbine.i;
Parameter.Turbine.R              	= 178/2;            % [m]       Rotor radius, from ElastoDyn.dat: TipRad, from Shakti(Carlo table) 20/11/24 fle  

% drive-train dynamics
J_G                               	= 500;              % [kgm^2]	Generator Inertia About High-Speed Shaft, from ElastoDyn.dat: GenIner 
J_R                                	= 35799464;         % [kgm^2]	Rotor Inertia About High-Speed Shaft, from ED.sum file
Parameter.Turbine.J                	= J_R+J_G/Parameter.Turbine.i^2;
Parameter.Turbine.eta_gb            = 0.955;            % [-]       Gearbox efficiency, from ElastoDyn.dat: GBoxEff

% fore-aft tower dynamics  
d_s                                 = 0.01;             % [-]       Structural Damping ratio from ElastoDyn_Tower.dat
f_0TwFADOF1                         = 0.305;            % [Hz]      Undamped tower fore-aft eigenfrequency, from Bortolotti2019
Parameter.Turbine.x_T0           	= -0.0880;          % [m]       static tower top displacement, from steady states
Parameter.Turbine.k_Te            	= 1.81e+06;         % [kg/s^2]  tower equivalent bending stiffness, from steady states
Parameter.Turbine.m_Te          	= Parameter.Turbine.k_Te/(f_0TwFADOF1*2*pi)^2;     	% [kg]      tower equivalent modal mass
Parameter.Turbine.c_Te            	= 2*Parameter.Turbine.m_Te*d_s*f_0TwFADOF1*2*pi;    % [kg/s]	tower structual damping (sigma=C_T/(2M_T)=D*w_0, w_0=f_0*2*pi, [Gasch] p.294)
Parameter.Turbine.HubHeight         = 108.44;           % [m]       TowerHt+Twr2Shft+OverHang*sind(ShftTilt)

%% Generator
Parameter.Generator.eta_el      	= 0.98;             % [-]       Generator efficiency, from ServoDyn.dat: GenEff

end