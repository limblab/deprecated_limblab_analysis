function [SNR,unit_var,noise_var]=get_unit_SNR(bdf,unit, varargin)
    %computes the SNR for each unit on the bdf. The BDF must have analog
    %data for each channel in the units vector, and waveforms for every 
    %snippet in order to find the SNR

    if ~isempty(varargin)
        snippet=varargin{1};
    else
        snippet=-10:49;
    end
    %find corresponding analog data
    chan_label=['chan' num2str(bdf.units(unit).id(1))];
    a_ind=find(strcmp(bdf.analog.channel,chan_label));
    %get approximate analog indices from timestamps in bdf.units:
    SR=(1/(bdf.analog.ts(2)-bdf.analog.ts(1)));
    i_list=round((bdf.units(unit).ts-bdf.analog.ts(1))*SR);
    i_mat=repmat(i_list,1,length(snippet));
    i_mat=bsxfun(@plus,i_mat,snippet);
    i_list=reshape(i_mat,size(i_mat,1)*size(i_mat,2),1);%make the index matrix a column vector
    mask=false(length(bdf.analog.ts),1);
    mask(i_list)=true;%mask should now select the elements of the analog data that only include the unit activity
    %get the spike variance from the full vector
    unit_var=var(bdf.analog.data{a_ind}(mask));
    %get the noise variance from the full vector
    noise_var=var(bdf.analog.data{a_ind}(~mask));
    %get the ratio
    SNR=unit_var/noise_var;
end