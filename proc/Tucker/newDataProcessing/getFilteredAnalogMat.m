function [adata,t]=getFilteredAnalogMat(NEVNSx,NSx_info,filterConfig,achan_index)
%[adata,t]=getFilteredAnalogMat(NEVNSx,NSx_info,filter_config,achan_index)
    %takes an NEVNSx object, an NSx_info object, a filter_config object,
    %and a list of analog channels achan_index. Returns a matrix where each
    %column corresponds to a channel in achan_index. the first column will
    %be time. Data columns will be filtered and decimated using parameters
    %specified in filter_config. 
    
    
    adata = [];%will preallocate below once we know how long the data is
    for c=1:length(achan_index)
        freq=NSx_info.NSx_sampling(achan_index(c));
        if freq==1000
            a = double(NEVNSx.NS2.Data(NSx_info.NSx_idx(achan_index(c)),:))';
        elseif freq==2000
            a = double(NEVNSx.NS3.Data(NSx_info.NSx_idx(achan_index(c)),:))';
        elseif freq==10000
            a = double(NEVNSx.NS4.Data(NSx_info.NSx_idx(achan_index(c)),:))';
        elseif freq==30000
            a = double(NEVNSx.NS5.Data(NSx_info.NSx_idx(achan_index(c)),:))';
        end
        %recalculate time. allows force to be collected at
        %different frequencies on different channels at the
        %expense of execution speed
        t = (0:length(a)-1)' / NSx_info.NSx_sampling(achan_index(c));

        %decimate and filter the raw force signals
        temp=decimateData([t a],filterConfig);
        %allocate the adata matrix if it doesn't exist yet
        if isempty(adata)
            adata=zeros(size(temp,1),numel(achan_index));
        end
        adata(:,c)= temp(:,2);
    end
    t=temp(:,1);
end