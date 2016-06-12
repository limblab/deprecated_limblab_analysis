function ret = change_amp_limits(current_array, amp_low_limit, amp_high_limit, direction)
%current_array should be a single muscle vector of amplitudes
%direction should be a directive of whether this should remove the
%amplitudes or add them; removal is 1 and add is 2 (because presumably that
%is the order in which those two processes occur)

%TODO: test this. 

if direction==1
    for i=1:length(current_array)
        if current_array(i)==amp_low_limit
            %uhh not sure about the placeholder to use here. .001 maybe?
            current_array(i) = .001; 
        elseif current_array(i)>amp_low_limit
            %do the reverse so that only the emg limits remain
            current_array(i) = (current_array(i)-amp_low_limit)/(amp_high_limit-amp_low_limit); 
        end
    end
    
elseif direction==2
    for i=1:length(current_array)
        if current_array(i)==.001
            current_array(i) = amp_low_limit; 
        elseif current_array(i)>.001
            current_array(i) = current_array(i)*(amp_high_limit-amp_low_limit)+amp_low_limit;
        end
    end
end

ret = current_array; 
            