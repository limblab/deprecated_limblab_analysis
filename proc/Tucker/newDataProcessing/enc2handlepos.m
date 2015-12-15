function pos=enc2handlepos(cds)
    %if you don't want to pay attention to the file separation times, then
    %feed [0 duration] in as FileSepTime
    enc=cds.enc{:,:};
    % account for mangled encoder timestamps (non-monotonic) and 1s lag
    % before data collection
    idx=skip_resets(enc(:,1));
    if ~isempty(idx)
        idx=max(idx,find(enc(:,1)>1,1,'first'));
    else
        idx=find(enc(:,1)>1,1,'first');
    end
    enc(isnan(enc(:,2))) = enc(find(~isnan(enc(:,2)),1,'first')); % when datafile started before encoders were zeroed. carried from old calc_from_raw
    enc(isnan(enc(:,3))) = enc(find(~isnan(enc(:,3)),1,'first'));
    
    enc=[enc(idx:end,1),enc(idx:end,2:3)*2*pi/18000];
    [enc]=decimateData(enc,cds.kinFilterConfig); 
    
    % convert encoder angles to x and y
    if cds.meta.lab==2 %If lab2 was used for data collection
        l1=24.0; l2=23.5;
    elseif cds.meta.lab==3 %If lab3 was used for data collection
        if datenum(out_struct.meta.datetime) < datenum('10/05/2012')
            l1=24.75; l2=23.6;
        elseif datenum(out_struct.meta.datetime) < datenum('17-Jul-2013')
          l1 = 24.765; l2 = 24.13;
        else
            l1 = 24.765; l2 = 23.8125;
        end
    elseif cds.meta.lab==6 %If lab6 was used for data collection
        if datenum(cds.meta.datetime) < datenum('01-Jan-2015')
            l1=27; l2=36.8;
        else
            l1=46.8; l2=45;
        end
    else
        l1 = 25.0; l2 = 26.8;   %use lab1 robot arm lengths as default
    end 

    x = - l1 * sin( enc(:,2) ) + l2 * cos( -enc(:,3) );
    y = - l1 * cos( enc(:,2) ) - l2 * sin( -enc(:,3) );
    pos=table(enc(:,1),x,y,'VariableNames',{'t','x','y'});
end