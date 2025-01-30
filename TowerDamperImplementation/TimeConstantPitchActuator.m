function T_PA = TimeConstantPitchActuator(Parameter)

omega                           = Parameter.PitchActuator.omega;
xi                              = Parameter.PitchActuator.xi;

num = omega^2;
den = [1 (2*xi*omega) (omega^2)];

sys = tf(num,den);
[y,tOut] = step(sys);
y_target = 0.63;
T_PA = interp1(y,tOut,y_target);
end