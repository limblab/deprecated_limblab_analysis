function ret = emg2amp(emg_array, emglow_limit, emghigh_limit, amplow_limit, amphigh_limit)

    ret = zeros(1, length(emg_array)); 
    for i=1:length(emg_array)
        if emg_array(i)<emglow_limit
            ret(i)=0; %if the emg is minimal, don't stimulate at all (this may
            %be necessary to change later for support of opposing muscles
        elseif emg_array(i)>emghigh_limit
            ret(i)=amphigh_limit; %don't do a higher amperage stim than the threshold
        else
            ret(i)=amplow_limit+emg_array(i)*(amphigh_limit-amplow_limit)/(emghigh_limit-emglow_limit); %same as format from monkey FES
            if ret(i)>amphigh_limit
                ret(i)=amphigh_limit; 
            end
        end
    end

end