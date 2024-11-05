function [Parameter] = DefaultParameter_Storage(Parameter)
%DefaultParameter_Storage 
Parameter.Storage.Capacity = 20e6*3600; % [Ws]
Parameter.Storage.InitState = 0;
end