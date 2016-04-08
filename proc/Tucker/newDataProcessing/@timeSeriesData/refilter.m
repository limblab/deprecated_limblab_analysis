function refilter(tsd)
    %this is a method of the timeSeriesData class and should be saved in
    %the @timeSeriesData folder
    %
    %tsd.refilter()
    %filters the data in tsd.data using the filter in tsd.filterConfig to
    %define the filter properties and the final sample rate. refilter takes
    %no inputs and returns no outputs.
    
    labels=tsd.data.Properties.VariableNames;
    units=tsd.data.Properties.VariableUnits;
    descriptions=tsd.data.Properties.VariableDescriptions;
    %get all the non-logical columns
    mask=~table2array(varfun(@islogical,tsd(1,:)));
    %refilter the non logical columns:
    aData=decimateData(tsd.data{:,mask},tsd.fdFilterConfig);
    %convert analog data into a table
    aData=array2table(aData,'VariableNames',labels(mask));
    aData.Properties.VariableUnits=units(mask);
    aData.Properties.VariableDescriptions=descriptions(mask);
    aData.Properties.Description=tsd.data.Properties.Description;
    %get logical values on the same time-series as the refiltered
    %data:
    lData=interp1(aData(1,:),tsd.data(:,~mask),tsd.data.t,'nearest');

    %if one of our coulmns is the 'good' logical column then expand
    %the range of 'bad' windows to handle filter ringing:
    ind=find(strcmp(labels(~mask),'good'),1);
    if ~isempty(ind)
        %extend 'bad' regions by 4x the period of the cutoff
        %frequency to reduce the impact of ringing artifacts:
        %get the number of points equal to 4x the cutoff period:
        wnd=ceil((4/tsd.filterConfig.cutoff)/mode(diff(lData(:,1))));
        %find the 'bad' windows
        chng=diff(tsd.data{:,ind});
        numInd=length(tsd.data{:,ind});
        badStarts=find(chng==1);
        badEnds=find(chng==-1);
        if badEnds(1)<badStarts(1)
            badStarts=[1,badStarts];
        end
        if length(badStarts)>length(badEnds)
            badEnds(end+1)=numInd;
        end
        %expand the bad windows
        badStarts=badStarts-wnd;
        badStarts(badStarts<1)=1;
        badEnds=badEnds+wnd;
        badEnds(badEnds>numInd)=numInd;
        %build a new 'good' vector by pushing 'false' into the new
        %window regions
        for i=1:length(badStarts)
            tsd.data{badStarts(i):badEnds(i)}=false;
        end
    end
    %convert digital data into a table:
    lData=array2table(lData,'VariableNames',labels(~mask));
    lData.Properties.VariableUnits=units(~mask);
    lData.Properties.VariableDescriptions=descriptions(~mask);
    lData.Properties.Description=tsd.data.Properties.Description;

    %use set to put the newly filtered data into the tsd:            
    set(tsd,'data',[aData,lData]);           
    evntData=loggingListenerEventData('refilter',tsd.filterConfig);
    notify(tsd,'refiltered',evntData)
end