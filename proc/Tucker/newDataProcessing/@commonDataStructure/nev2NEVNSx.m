function nev2NEVNSx(cds,fname)
    %this is a method function for the commonDataStructure class and should
    %be saved in the @commonDataStructure folder
    %
    %NEVNSx=nev2NEVNSx(fname)
    %loads data from the nev specified by the path in fname, and from
    %associated .nsx files with the same name. This code is derived from
    %cerebus2NEVNSx, but will NOT merge files, or look for keywords to pick
    %sorted files when the path to the unsorted file is given. fname must
    %be the FULL path and file name including extension
    %
    %this method is inteneded to be used internally during cds object
    %initiation, not called to generate NEVNSx objects in general.
    
    [folderPath,fileName,~]=fileparts(fname);
    
    %get the path for files matching the filename
    NEVpath = dir([folderPath filesep fileName '*.nev']);
    NSxList{1} = dir([folderPath filesep fileName '.ns1']);
    NSxList{2} = dir([folderPath filesep fileName '.ns2']);
    NSxList{3} = dir([folderPath filesep fileName '.ns3']);
    NSxList{4} = dir([folderPath filesep fileName '.ns4']);
    NSxList{5} = dir([folderPath filesep fileName '.ns5']);
    frequencies=[500 1000 2000 10000 30000];%vector of frequencies in the order that the NSx entries appear in NSxList
    
    %% populate cds.NEV
    if isempty(NEVpath)
        error('nev2NEVNSx:fileNotFound',['did not find a file with the path: ' fname])
    else
        if numel(NEVpath)>1
            %check to see if we have a sorted file with no digital:
            NEVpath=dir([folderPath filesep fileName '_nodigital*.nev']);
            digitalPath=dir([folderPath filesep fileName '_nospikes.mat']);
            if ~isempty(NEVpath) && ~isempty(digitalPath)
                    spikeNEV=openNEVLimblab('read', [folderPath filesep NEVpath.name],'nosave');
                    oldNEV=load([folderpath filesep digitalPath.name]);
                    oldNEVName=fieldnames(oldNEV);
                    oldNEV.(oldNEVName{1}).Data.Spikes=spikeNEV.Data.Spikes;
            else
                warning('nev2NEVNSx:multipleNEVFiles',['Found multiple files that start with the name given, but could not find files matching the pattern: ',fname,'_nodigital*.nev + ',fname,'_nospikes.mat'])
                disp(['continuing by loading the NEV that is an exact match for: ',fname,'.nev'])
                NEVpath = dir([folderPath filesep fileName '.nev']);
            end
        else
            set(cds,'NEV',openNEVLimblab('read', [folderPath filesep NEVpath.name],'nosave'));
        end
    end
    if ~exist('spikeNEV','var')
        %if we didn't load the NEV specially to merge digital data, load
        %the nev directly into the cds:
        set(cds,'NEV',openNEVLimblab('read', [folderPath filesep NEVpath.name],'nosave'));
    end
    %% populate the cds.NSx fields
    for i=1:length(NSxList)
        fieldName=['NS',num2str(i)];
        if ~isempty(NSxList{i})
            if ~isempty(cds.NEV.Data.SerialDigitalIO.TimeStampSec)
                %we know the analog data lags the digital data, so we need
                %to, load the analog data, compute the correct number of
                %points to align the data, add that many points worth of
                %zeros to each channel, and then push to the appropriate
                %field of the cds
                
                %load the NSx into a temporary variable:
                NSx=openNSxLimblab('read', [folderPath filesep NSxList{i}.name],'precision','short');
                %get the last timepoint in the digital data:
                digitalLength = cds.NEV.Data.SerialDigitalIO.TimeStampSec(end);
                %compute the pad by comparing the actual number of points
                %to the expected number if the file is the same length as
                %the digital data
                num_zeros = fix(digitalLength*frequencies(i)-size(NSx.Data,2));
                %pad data in our temporary object
                NSx.Data = [zeros(size(NSx.Data,1),num_zeros) NSx.Data];
                %update the metadata associated with the padding:
                NSx.MetaTags.DataPoints = NSx.MetaTags.DataPoints + num_zeros;
                NSx.MetaTags.DataDurationSec = NSx.MetaTags.DataPoints/frequencies(i);
                %insert into the cds
                set(cds,upper(fieldName),NSx)
            else %no digital data was collected
                % no padding, just load the NSx directly into the
                % appropriate field
                set(cds,upper(fieldName),openNSxLimblab('read', [folderPath filesep NSxList{i}.name],'precision','short'))
            end
        else
            %set the NSx field empty in case we are currently loading a
            % second NEV. This prevents re-loading data that was in one 
            %*.nev file but not the other when NEVNSx2cds is called
            set(cds,upper(fieldName),[])
        end
    end
    
    %%   now get info we will need to parse the NEVNSx data:
    NSxInfo.NSx_labels = {};
    NSxInfo.NSx_sampling = [];
    NSxInfo.NSx_idx = [];
    if ~isempty(cds.NS1)
        NSxInfo.NSx_labels = {NSxInfo.NSx_labels{:} cds.NS1.ElectrodesInfo.Label}';
        NSxInfo.NSx_sampling = [NSxInfo.NSx_sampling repmat(500,1,size(cds.NS1.ElectrodesInfo,2))];
        NSxInfo.NSx_idx = [NSxInfo.NSx_idx 1:size(cds.NS1.ElectrodesInfo,2)];
    end
    if ~isempty(cds.NS2)
        NSxInfo.NSx_labels = {NSxInfo.NSx_labels{:} cds.NS2.ElectrodesInfo.Label}';
        NSxInfo.NSx_sampling = [NSxInfo.NSx_sampling repmat(1000,1,size(cds.NS2.ElectrodesInfo,2))];
        NSxInfo.NSx_idx = [NSxInfo.NSx_idx 1:size(cds.NS2.ElectrodesInfo,2)];
    end
    if ~isempty(cds.NS3)
        NSxInfo.NSx_labels = {NSxInfo.NSx_labels{:} cds.NS3.ElectrodesInfo.Label};
        NSxInfo.NSx_sampling = [NSxInfo.NSx_sampling repmat(2000,1,size(cds.NS3.ElectrodesInfo,2))];
        NSxInfo.NSx_idx = [NSxInfo.NSx_idx 1:size(cds.NS3.ElectrodesInfo,2)];
    end
    if ~isempty(cds.NS4)
        NSxInfo.NSx_labels = {NSxInfo.NSx_labels{:} cds.NS4.ElectrodesInfo.Label}';
        NSxInfo.NSx_sampling = [NSxInfo.NSx_sampling repmat(10000,1,size(cds.NS4.ElectrodesInfo,2))];
        NSxInfo.NSx_idx = [NSxInfo.NSx_idx 1:size(cds.NS4.ElectrodesInfo,2)];
    end
    if ~isempty(cds.NS5)
        NSxInfo.NSx_labels = {NSxInfo.NSx_labels{:} cds.NS5.ElectrodesInfo.Label}';
        NSxInfo.NSx_sampling = [NSxInfo.NSx_sampling repmat(30000,1,size(cds.NS5.ElectrodesInfo,2))];
        NSxInfo.NSx_idx = [NSxInfo.NSx_idx 1:size(cds.NS5.ElectrodesInfo,2)];
    end
    %sanitize labels
    NSxInfo.NSx_labels = NSxInfo.NSx_labels(~cellfun('isempty',NSxInfo.NSx_labels));
    NSxInfo.NSx_labels = deblank(NSxInfo.NSx_labels);
    %apply aliases to labels:
    if ~isempty(cds.aliasList)
        for i=1:size(cds.aliasList,1)
            NSxInfo.NSx_labels(~cellfun('isempty',strfind(NSxInfo.NSx_labels,cds.aliasList{i,1})))=cds.aliasList(i,2);
        end
    end
    % check that we don't have a data stream using the reserved name
    % 'good'
    if ~isempty(find(strcmp('good',NSxInfo.NSx_labels),1));
        error('NEVNSx2cds:goodIsAReservedName','the cds and experiment code uses the label good as a flag for kinematic data, and treats this label specially when refiltering. This label is reserved to avoid unintended behaviro when refiltering other data sreams. Please use the alias function to re-name the good channel of input data')
    end
    
    set(cds,'NSxInfo',NSxInfo)
    
end