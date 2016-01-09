function enc2handlepos(cds)
    %this function takes a cds, computes the postition from encoder data
    %assuming that the 
    
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

    x = - l1 * sin( cds.enc.th1 ) + l2 * cos( -cds.enc.th2 );
    y = - l1 * cos( cds.enc.th1 ) - l2 * sin( -cds.enc.th2 );
    pos=table(cds.enc(:,1),x,y,'VariableNames',{'t','x','y'});
    %configure labels on pos
    pos.Properties.VariableUnits={'s','cm','cm'};
    pos.Properties.VariableDescriptions={'time','x position in room coordinates. ','y position in room coordinates',};
    pos.Properties.Description='Robot Handle position';

    set(cds,'pos',pos)
    cds.addOperation(mfilename('fullpath'));
end