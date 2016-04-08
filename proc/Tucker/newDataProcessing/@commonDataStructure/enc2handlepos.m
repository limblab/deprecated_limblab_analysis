function [pos]=enc2handlepos(cds,dateTime,lab)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %this function computes the postition from encoder data assuming that 
    %the encoder data results from one of the robot systems.
    
    % set up robot arm lengths to use for position computation
    if lab==2 %If lab2 was used for data collection
        l1=24.0; l2=23.5;
    elseif lab==3 %If lab3 was used for data collection
        if datenum(dateTime) < datenum('10/05/2012')
            l1=24.75; l2=23.6;
        elseif datenum(dateTime) < datenum('17-Jul-2013')
          l1 = 24.765; l2 = 24.13;
        else
            l1 = 24.765; l2 = 23.8125;
        end
    elseif lab==6 %If lab6 was used for data collection
        if datenum(dateTime) < datenum('01-Jan-2015')
            l1=27; l2=36.8;
        else
            l1=46.8; l2=45;
        end
    else
        l1 = 25.0; l2 = 26.8;   %use lab1 robot arm lengths as default
    end 
    % convert encoder angles to x and y
    
    %pos=[x,y]
    pos=[(- l1 * sin( cds.enc.th1 ) + l2 * cos( -cds.enc.th2 )),  (- l1 * cos( cds.enc.th1 ) - l2 * sin( -cds.enc.th2 ))];
    evntData=loggingListenerEventData('enc2handlepos',[]);
    notify(cds,'ranOperation',evntData)
end