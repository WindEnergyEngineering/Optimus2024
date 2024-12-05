function [A,B,C,D] = LinearizeSLOW2DOF(theta_OP,Omega_OP,v_0_OP,Parameter)
% David Schlipf
% (c) Universitaet Stuttgart and sowento GmbH

% internal variables
J               = Parameter.Turbine.J;
R               = Parameter.Turbine.R;
r_GB            = Parameter.Turbine.r_GB;
rho             = Parameter.General.rho;
m_Te          	= Parameter.Turbine.m_Te;
k_Te           	= Parameter.Turbine.k_Te;
c_Te         	= Parameter.Turbine.c_Te;
M_g_rated       = Parameter.VSC.M_g_rated;
Omega_g_rated   = Parameter.CPC.Omega_g_rated;

% gradients
dtheta          = diff(Parameter.Turbine.SS.theta(1:2));
dlambda         = diff(Parameter.Turbine.SS.lambda(1:2));
lambda_OP       = Omega_OP*R/v_0_OP;

% power coefficient
cP_Tmin1        = interp2(Parameter.Turbine.SS.theta, Parameter.Turbine.SS.lambda, Parameter.Turbine.SS.c_P, theta_OP-dtheta,     lambda_OP, 'linear', 0.0); %Zero outside domain for zero pitch
cP_Tplus1       = interp2(Parameter.Turbine.SS.theta, Parameter.Turbine.SS.lambda, Parameter.Turbine.SS.c_P, theta_OP+dtheta,     lambda_OP);
cP_Lmin1        = interp2(Parameter.Turbine.SS.theta, Parameter.Turbine.SS.lambda, Parameter.Turbine.SS.c_P, theta_OP,            lambda_OP-dlambda);
cP_Lplus1       = interp2(Parameter.Turbine.SS.theta, Parameter.Turbine.SS.lambda, Parameter.Turbine.SS.c_P, theta_OP,            lambda_OP+dlambda);
cP_0            = interp2(Parameter.Turbine.SS.theta, Parameter.Turbine.SS.lambda, Parameter.Turbine.SS.c_P, theta_OP,            lambda_OP);
dcP_dtheta      = (cP_Tplus1 - cP_Tmin1)/(2*dtheta);
dcP_dlambda     = (cP_Lplus1 - cP_Lmin1)/(2*dlambda);

% thrust coefficient
cT_Tmin1        = interp2(Parameter.Turbine.SS.theta, Parameter.Turbine.SS.lambda, Parameter.Turbine.SS.c_T, theta_OP-dtheta,     lambda_OP, 'linear', 0.0); %Zero outside domain for zero pitch
cT_Tplus1       = interp2(Parameter.Turbine.SS.theta, Parameter.Turbine.SS.lambda, Parameter.Turbine.SS.c_T, theta_OP+dtheta,     lambda_OP);
cT_Lmin1        = interp2(Parameter.Turbine.SS.theta, Parameter.Turbine.SS.lambda, Parameter.Turbine.SS.c_T, theta_OP,            lambda_OP-dlambda);
cT_Lplus1       = interp2(Parameter.Turbine.SS.theta, Parameter.Turbine.SS.lambda, Parameter.Turbine.SS.c_T, theta_OP,            lambda_OP+dlambda);
cT_0            = interp2(Parameter.Turbine.SS.theta, Parameter.Turbine.SS.lambda, Parameter.Turbine.SS.c_T, theta_OP,            lambda_OP);
dcT_dtheta      = (cT_Tplus1 - cT_Tmin1)/(2*dtheta);
dcT_dlambda     = (cT_Lplus1 - cT_Lmin1)/(2*dlambda);


% helpers       
f               = 1/2*rho*pi*R^2;
dlambda_dvrel   = -1/v_0_OP^2*Omega_OP*R;
dlambda_dOmega  = R/v_0_OP;
dcP_dvrel       = dcP_dlambda*dlambda_dvrel;
dcP_dOmega      = dcP_dlambda*dlambda_dOmega;
dcT_dvrel       = dcT_dlambda*dlambda_dvrel;
dcT_dOmega      = dcT_dlambda*dlambda_dOmega;
dvrel_dv0       = 1;
dvrel_dxTdot    = -1;

% derivatives of Ma = f*v^3*cP(vrel,theta,Omega)/Omega with vrel=v_0-x_Tdot
dMa_dtheta      = f*v_0_OP^3/Omega_OP*dcP_dtheta;
dMa_dvrel       = f*v_0_OP^3/Omega_OP*dcP_dvrel  + f*cP_0/Omega_OP*3*v_0_OP^2;
dMa_dOmega      = f*v_0_OP^3/Omega_OP*dcP_dOmega + f*v_0_OP^3*cP_0*(-1/Omega_OP^2);
dMa_dxTdot      = dMa_dvrel*dvrel_dxTdot;
dMa_dv0         = dMa_dvrel*dvrel_dv0;

% derivatives of Fa = f*v^2*cT(vrel,theta,Omega) with vrel=v_0-x_Tdot
dFa_dtheta      = f*v_0_OP^2*dcT_dtheta;
dFa_dvrel       = f*v_0_OP^2*dcT_dvrel  + f*cT_0*2*v_0_OP;
dFa_dOmega      = f*v_0_OP^2*dcT_dOmega;
dFa_dxTdot      = dFa_dvrel*dvrel_dxTdot;
dFa_dv0         = dFa_dvrel*dvrel_dv0;

% torque control
dMg_dOmega      = -M_g_rated*Omega_g_rated/r_GB/(Omega_OP)^2;

% x_1 = Omega
% x_2 = x_T
% x_3 = x_T_dot
% u_1 = theta
% u_2 = v_0
% y_1 = Omega_g
% y_2 = x_T_dot

b11             = dMa_dtheta/J;
b12             = dMa_dv0/J;
a11             = (dMa_dOmega-dMg_dOmega*r_GB)/J;
a13             = dMa_dxTdot/J;
c11             = r_GB;
c23             = 1;
b31             = dFa_dtheta/m_Te;
b32             = dFa_dv0   /m_Te;
a31             = dFa_dOmega/m_Te;
a32             =                   -k_Te/m_Te;
a33             = dFa_dxTdot/m_Te   -c_Te/m_Te;

% Outputs
A               = [ a11   0 a13
                      0   0   1 
                    a31 a32 a33];
                
B               = [b11 b12
                     0   0 
                   b31 b32];
               
C               = [c11   0   0
                    0    0  c23];

D               = [0  0
                   0  0];

end

