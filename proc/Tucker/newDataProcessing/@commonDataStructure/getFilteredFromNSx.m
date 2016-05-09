function [adata,t]=getFilteredFromNSx(cds,fc,achan_index)
    %this is a method function of the commonDataStructure class and must be
    %saved in the @commonDataStructure folder with the class definition
    %
    %[adata,t]=getFilteredFromNSx(filter_config,achan_index)
    %a filter_config object,and a list of analog channels achan_index. and 
    %Returns a matrix where each column corresponds to a channel in 
    %achan_index. the first column will be time. Data columns will be 
    %filtered and decimated using parameters specified in filter_config. 
    
    adata = [];%will preallocate below once we know how long the data is
    for c=1:length(achan_index)
        freq=cds.NSxInfo.NSx_sampling(achan_index(c));
        if freq==500
            a=double(cds.NS1.Data(cds.NSxInfo.NSx_idx(achan_index(c)),:))';
        elseif freq==1000
            a = double(cds.NS2.Data(cds.NSxInfo.NSx_idx(achan_index(c)),:))';
        elseif freq==2000
            a = double(cds.NS3.Data(cds.NSxInfo.NSx_idx(achan_index(c)),:))';
        elseif freq==10000
            a = double(cds.NS4.Data(cds.NSxInfo.NSx_idx(achan_index(c)),:))';
        elseif freq==30000
            a = double(cds.NS5.Data(cds.NSxInfo.NSx_idx(achan_index(c)),:))';
        end
        %recalculate time. allows force to be collected at
        %different frequencies on different channels at the
        %expense of execution speed
        t = (0:length(a)-1)' / cds.NSxInfo.NSx_sampling(achan_index(c));

        %decimate and filter the raw force signals so they are all at the
        %same frequency, no matter what the collection frequency was
        temp=decimateData([t a],fc);
        
        %allocate the adata matrix if it doesn't exist yet
        if isempty(adata)
            adata=zeros(size(temp,1),numel(achan_index));
        end
        adata(:,c)= temp(:,2);
    end
    t=temp(:,1);
end