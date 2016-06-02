function [SNR,spike_amp,noise_RMS]=get_unit_SNR(bdf,unit, varargin)
    %computes the SNR for each unit on the bdf. The BDF must have analog
    %data for each channel in the units vector, and waveforms for every 
    %snippet in order to find the SNR

    if ~isempty(varargin)
        snippet=varargin{1};
    else
        snippet=-10:49;
    end
    data_length=length(bdf.analog.ts);
    %find corresponding analog data
    chan_label=['chan' num2str(bdf.units(unit).id(1))];
    a_ind=find(strcmp(bdf.analog.channel,chan_label));
    %get approximate analog indices from timestamps in bdf.units:
    SR=(1/(bdf.analog.ts(2)-bdf.analog.ts(1)));
    %find last complete spike in the analog data:
    i=length(bdf.units(unit).ts);
    while round((bdf.units(unit).ts(i)-bdf.analog.ts(1))*SR+max(snippet))>data_length
        i=i-1;
    end
    %get a list of the indices corresponding to each spike
    i_list=round((bdf.units(unit).ts(1:i)-bdf.analog.ts(1))*SR);
    i_mat=repmat(i_list,1,length(snippet));
    i_mat=bsxfun(@plus,i_mat,snippet);
    i_list=reshape(i_mat,size(i_mat,1)*size(i_mat,2),1);%make the index matrix a column vector
    i_list=i_list(i_list<data_length);
    mask=false(data_length,1);
    mask(i_list)=true;%mask should now select the elements of the analog data that only include the unit activity
    
    %%%%%% spikes have different shapes and amplitudes but similar variance
    %%%%%% to background, at least in S1, so the following code doesn't
    %%%%%% work
    %get the spike variance from the full vector
    %unit_var=var(bdf.analog.data{a_ind}(mask));
    %get the noise variance from the full vector
    %noise_var=var(bdf.analog.data{a_ind}(~mask));
    %get the ratio
    %SNR=unit_var/noise_var;
    %%%%%%
    %%%%%% instead we will use the mean amplitude of the spike compared to
    %%%%%% the RMS amplitude of the noise
    peaks=max(reshape(bdf.analog.data{a_ind}(i_list),length(snippet),length(bdf.units(unit).ts(1:i))),[],1);
    valleys=min(reshape(bdf.analog.data{a_ind}(i_list),length(snippet),length(bdf.units(unit).ts(1:i))),[],1);
    spike_amp=abs(mean(peaks-valleys));
    noise_RMS=sqrt(mean(bdf.analog.data{a_ind}(~mask).^2));
    SNR=spike_amp/noise_RMS;
end