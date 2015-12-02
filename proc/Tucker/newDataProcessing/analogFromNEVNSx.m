function analogFromNEVNSx(cds,NEVNSx,NSxInfo)
%takes a cds handle and an NEVNSx object and populates the analog cell
%array of the cds. Does not return anything
    %establish lists for force, emg, lfp
    forceList = [find(~cellfun('isempty',strfind(lower(NSxInfo.NSx_labels),'force_'))),...
                find(~cellfun('isempty',strfind(lower(NSxInfo.NSx_labels),'ForceHandle')))];
    lfpList=find(~cellfun('isempty',strfind(lower(NSxInfo.NSx_labels),'chan')));
    emgList=find(~cellfun('isempty',strfind(lower(NSxInfo.NSx_labels),'emg_')));
    %get lists of the analog data for each frequency & remove those we have already handled
    analogList=setxor(1:length(NSxInfo.NSx_labels),emgList);
    analogList=setxor(analogList,forceList);
    analogList=setxor(analogList,lfpList);
    if ~isempty(analogList)
        frequencies=unique(NSxInfo.NSx_sampling);
        for i=1:length(frequencies)
            %find the channels that area actually at this frequency:
            subset=find(NSxInfo.NSx_sampling(analogList)==frequencies(i));
            %append data in the subset into a single matrix:
            for c=1:numel(subset)
                a=[];
                switch frequencies(i)
                    case 1000
                        if isempty(a)
                            %initialize a to the correct size
                            a=zeros(size(NEVNSx.NS2.Data(NSxInfo.NSx_idx(analogList(subset(c))),:),2),numel(subset));
                        end
                        a(:,c)=double(NEVNSx.NS2.Data(NSxInfo.NSx_idx(analogList(subset(c))),:))';
                    case 2000
                        if isempty(a)
                            %initialize a to the correct size
                            a=zeros(size(NEVNSx.NS3.Data(NSxInfo.NSx_idx(analogList(subset(c))),:),2),numel(subset));
                        end
                        a(:,c)=double(NEVNSx.NS3.Data(NSxInfo.NSx_idx(analogList(subset(c))),:))';
                    case 10000
                        if isempty(a)
                            %initialize a to the correct size
                            a=zeros(size(NEVNSx.NS4.Data(NSxInfo.NSx_idx(analogList(subset(c))),:),2),numel(subset));
                        end
                        a(:,c)=double(NEVNSx.NS4.Data(NSxInfo.NSx_idx(analogList(subset(c))),:))';
                    case 30000
                        if isempty(a)
                            %initialize a to the correct size
                            a=zeros(size(NEVNSx.NS5.Data(NSxInfo.NSx_idx(analogList(subset(c))),:),2),numel(subset));
                        end
                        a(:,c)=double(NEVNSx.NS5.Data(NSxInfo.NSx_idx(analogList(subset(c))),:))';
                end
            end
            %get a time vector t for this sampling frequency
            t = ([0:length(a(:,1))-1]' / frequencies(i));
            %convert the matrix of data into a table:
            analogData{i}=array2table([t,a],'VariableNames',[{'t'},NSxInfo.NSx_labels(analogList(subset))]);
            analogData{i}.Properties.VariableDescriptions=[{'time'},repmat({'analog data'},1,numel(subset))];
            analogData{i}.Properties.Description=['table of analog data with collection frequency of: ', num2str(frequencies(i))];
        end
        %push the cell array of analog data tables into the cds:
        cds.setField('analog',analogData)
    else
        cds.setField('analog',{})
    end
    cds.addOperation(mfilename('fullpath'))
end