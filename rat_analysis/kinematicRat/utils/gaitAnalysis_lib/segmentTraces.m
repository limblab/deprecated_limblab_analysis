function dat_i = segmentTraces( fStrike, data , interpFlag)

    nSamp   = 100;
    
    % If interpFlag is true, the function fills the NaN with a linear
    % interpolation (and extrapolates if NaN are at the beginning or at the
    % end of the vector data). The default is interpFlag = false.
    if nargin<3
        flag = false;
    else
        flag = interpFlag;
    end

    nStride = length(fStrike);    
    dat_i   = NaN(nSamp,nStride-1);        
        
    for j=1:length(fStrike)-1
        dat_s       = data(fStrike(j):fStrike(j+1),1);
        len_s       = length(dat_s);
        tOld        = linspace(0,1,len_s);
        tNew        = linspace(0,1,nSamp);
        dat_i(:,j)  = interp1(tOld',dat_s,tNew');
        
        if flag
            tmp  = dat_i(:,j);
            nanx = isnan(tmp);
            % Interpolate only if just a few samples are missing
            %if length(nanx)<nSamp/10
                t             = 1:numel(tmp);
                dat_i(nanx,j) = interp1(t(~nanx), tmp(~nanx), t(nanx), ...
                                        'linear','extrap');
            %end
        end
            
            
    end
  
end

