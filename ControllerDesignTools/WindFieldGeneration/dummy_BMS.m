function [current_state, y] = dummy_BMS(P_error, E_storage, Capacity, Initial_state)
% state machine Battery management system
init        = 0;
standby     = 1;
charge      = 2;
discharge   = 3;

state = Initial_state;
nextstate = state;
y = 0;
switch state
    case init
        nextstate = standby;
        y = 0;

    case standby
        
        if (P_error > 0) && (E_storage < Capacity)
            nextstate = charge;
        elseif (P_error < 0) && (E_storage > 0)
            nextstate = discharge;
        else
            nextstate = standby;
        end
        y = 0;

    case charge
        if (P_error > 0) && (E_storage < Capacity)
            y = P_error;
            nextstate = charge;
        elseif (P_error < 0) && (E_storage > 0)
            nextstate = discharge;
        else
            nextstate = standby;
        end
        y = P_error;

    case discharge
        if (P_error < 0) && (E_storage > 0)
            y = P_error;
            nextstate = discharge;
        elseif (P_error > 0) && (E_storage < Capacity)
            nextstate = charge;
        else
            nextstate = standby;
        end
        y = P_error;

    otherwise
        disp('Error');
end
state = nextstate;
current_state = state;
end


% % persistent state
% % 
% if isempty(Initial_state)
%     state = init;
% else
%     state = Initial_state;
% end