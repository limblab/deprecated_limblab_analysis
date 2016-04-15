function NEVNSx=nev2NEVNSx(cds,fname)
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
    
    [folderPath,fileName,ext]=fileparts(fname);
    if ~strcmp('.nev',ext)
        %this is a cheat, it only catches when people try to use match
        %strings like they would with cerebus2NEVNSx
        error('nev2NEVNSx:badFilePath','the file name must be specified as a full file path including the file extension')
    end
    %get the path for files matching the filename
    NEVpath = dir([folderPath filesep fileName '*.nev']);
    NS1path = dir([folderPath filesep fileName '*.ns1']);
    NS2path = dir([folderPath filesep fileName '*.ns2']);
    NS3path = dir([folderPath filesep fileName '*.ns3']);
    NS4path = dir([folderPath filesep fileName '*.ns4']);
    NS5path = dir([folderPath filesep fileName '*.ns5']);
    
    %% populate cds.NEV
    if isempty(NEVpath)
        error('nev2NEVNSx:fileNotFound',['did not find a file with the path: ' fname])
    else
        set(cds,'NEV',openNEVLimblab('read', [folderPath filesep NEVpath.name],'nosave'));
    end
    
    %% populate the cds.NSx fields
    frequencies=[500 1000 2000 10000 30000];
    for i=1:length(NSxList)
        if ~isempty(NSxList{i})
            if ~isempty(cds.NEV.Data.SerialDigitalIO.TimeStampSec)
                %we know the analog data lags the digital data, so we need
                %to, load the analog data, compute the correct number of
                %points to align the data, add that many points worth of
                %zeros to each channel, and then push to the appropriate
                %field of the cds
                
                %load the NSx into a temporary variable:
                NSx=openNSxLimblab('read', [folderPath filesep NSxList{i}],'precision','short');
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
                set(cds,upper(NSxList{i}(end-3:end)),NSx)
            else %no digital data was collected
                % no padding, just load the NSx directly into the
                % appropriate field
                set(cds,upper(NSxList{i}(end-3:end)),openNSxLimblab('read', [folderPath filesep NSxList{i}],'precision','short'))
            end
        else
            %set the NSx field empty in case we are loading a second NEV.
            %This prevents re-loading data that was in one *.nev file but
            %not the other when NEVNSx2cds is called
            set(cds,upper(NSxList{i}(end-3:end)),[])
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