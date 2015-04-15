function SNR=get_all_SNR(bdf,varargin)
    %loops through bdf.units and computes the SNR for every unit in the bdf
    %can be flaggd to only work on sorted units, or to use a list of units
    %returns a dataset with columns for channel, unit, unit_variance,
    %noise_variance, and SNR
    
    only_sorted=1;
    units=1:length(bdf.units);
    
    if length(varargin)>0;
        if isfield(varargin{1},'only_sorted')
            only_sorted=varargin{1}.only_sorted;
        end
        if isfield(varargin{1},'units')
            units=varargin{1}.units;
        end
        if isfield(varargin{1},'window')
            snippet=varargin{1}.window;
        end
    end
    unit_var=-1*ones(length(units),1);
    noise_var=-1*ones(length(units),1);
    ratio=-1*ones(length(units),1);
    chan_unit=255*ones(length(units),2);
    for i=1:length(units)
        if bdf.units(units(i)).id(2)==255 || (bdf.units(units(i)).id(2)==0 & only_sorted)
            continue
        end
        [ratio(i),unit_var(i),noise_var(i)]=get_unit_SNR(bdf,i,snippet);
        chan_unit(i,:)=bdf.units(units(i)).id;
    end
    mask=chan_unit(:,2)~=255;
    SNR=dataset({chan_unit(mask,1),'channel'},{chan_unit(mask,2),'unit'},{ratio(mask),'SNR'},{unit_var(mask),'unit_var'},{noise_var(mask),'noise_var'});
    
end