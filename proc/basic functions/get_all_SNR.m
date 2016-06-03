function SNR=get_all_SNR(bdf,varargin)
    %loops through bdf.units and computes the SNR for every unit in the bdf
    %can be flaggd to only work on sorted units, or to use a list of units
    %returns a dataset with columns for channel, unit, unit_amplitude,
    %noise_RMS, and SNR

    only_sorted=1;
    units=1:length(bdf.units);
    snippet=-10:49;
    
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
    unit_amp=-1*ones(length(units),1);
    noise_RMS=-1*ones(length(units),1);
    ratio=-1*ones(length(units),1);
    chan_unit=255*ones(length(units),2);
    for i=1:length(units)
        if bdf.units(units(i)).id(2)==255 || (bdf.units(units(i)).id(2)==0 & only_sorted)
            disp(['Skipping index: ',num2str(units(i)),', unit #:',num2str(bdf.units(units(i)).id(2)),' chan #:',num2str(bdf.units(units(i)).id(1))])
            continue
        end
        disp(['computing SNR for index: ',num2str(units(i)),', unit #:',num2str(bdf.units(units(i)).id(2)),' chan #:',num2str(bdf.units(units(i)).id(1))])
        [ratio(i),unit_amp(i),noise_RMS(i)]=get_unit_SNR(bdf,i,snippet);
        chan_unit(i,:)=bdf.units(units(i)).id;
    end
    mask=chan_unit(:,2)~=255;
    SNR=dataset({chan_unit(mask,1),'channel'},{chan_unit(mask,2),'unit'},{ratio(mask),'SNR'},{unit_amp(mask),'unit_amp'},{noise_RMS(mask),'noise_RMS'});
    
end