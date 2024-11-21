% Function: OmegaDot calculates the Residum for the rotor motion.
%
%
% --------------------------------
% Usage:
% -------------
% Residual=OmegaDot(Omega,theta,v_0i,Parameter) for CPC Design
% or 
% Residual=OmegaDot(Omega,theta,M_g,v_0i,Parameter) for VSC Design
% -------------
% Input:
% -------------
%
% -------------
% Output:
% -------------
%
% -------------
% Needs:
% -------------
%
% -------------
% Modified:
% -------------
% * DS on 03-Sep-2015
%   - Change of interface for VSC Dssign
% * DS on 22-Nov-2021
%   - remove gearbox efficiency
% -------------
% ToDo:
% -------------
%
% -------------
% Created:
% David Schlipf on 01-Jan-2014
% (c) Universitaet Stuttgart
% ----------------------------------
function [Residual,M_g]   = OmegaDot(varargin)

% Default
switch nargin
    case 4 % using BaselineVSControl
        Omega       = varargin{1};
        theta       = varargin{2};        
        v_0         = varargin{3};
        Parameter   = varargin{4};
                
        Omega_g     = Omega*Parameter.Turbine.r_GB;
        M_g         = Parameter.VSC.NonlinearStateFeedback(Omega_g,theta,Parameter);
    
    case 5 % no VS Control
        Omega       = varargin{1};
        theta       = varargin{2};
        M_g         = varargin{3};
        v_0         = varargin{4};        
        Parameter   = varargin{5}; 
        
end

M_a         = AerodynamicTorque(Omega,theta,v_0,Parameter);

Residual    = 1/Parameter.Turbine.J*...
    ( M_a - M_g*Parameter.Turbine.r_GB);  
end

function M_a = AerodynamicTorque(Omega,theta,v_0,Parameter)
    lambda      = Omega*Parameter.Turbine.R/(v_0);
    c_P         = interp2(Parameter.Turbine.SS.theta,Parameter.Turbine.SS.lambda,Parameter.Turbine.SS.c_P,theta,lambda,'linear',0);
    M_a         = (1/2*pi*Parameter.Turbine.R^3*Parameter.General.rho*c_P/lambda*(v_0)^2);
end