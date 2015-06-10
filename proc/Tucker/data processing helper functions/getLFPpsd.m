function LFP=getLFPpsd(bdf,varargin)
    % LFP=getLFPpsd(bdf)
    % LFP=getLFPpsd(bdf,opts)
    %opts.chanlist= list of channel numbers to look for in
    %bdf.analog.channel
    %opts.window= data window for FFT computation. defaults to hamming 
    %window 0.25s of data
    %opts.output_res= resolution in s of the psd estimates. default is 1
    %estimate every 0.1s
    %opts.fbinsize= desired resolution in frequency domain of the 
    %spectrogram. defaults to 1hz

    
    SR=1/(bdf.analog.ts(2)-bdf.analog.ts(1));
    
    %default assumes all analog channels in bdf.analog are used
    chanlist=1:length(bdf.analog.channel);
    %default assumes a 0.25s hamming window
    window=round(SR/4);
    %default assumes a 100ms separation between estimates to produce an
    %estimation of PSD every 100ms
    noverlap=window-round(.1*SR);
    %default assumes the frequency resolution of interest is 1hz
    fbinsize=1;%in hz
    if ~isempty(varargin)
        if isfield(varargin{1},'chanlist')
            chanlist=varargin{1}.chanlist;
        end
        if isfield(varargin{1},'window')
            window=varargin{1}.window;
            if ~isfield(varargin{1},'noverlap')
                noverlap=window-round(.1*SR);
            end
        end
        if isfield(varargin{1},'output_res')
            noverlap=window-round(SR*varargin{1}.output_res);
        end
        if isfield(varargin{1},'fbinsize')
            fbinsize=varargin{1}.fbinsize;
        end
    end
    
    nfft=ceil(2*SR/fbinsize);
    
    chan_label=['chan' num2str(chanlist(1))];
        a_ind=find(strcmp(bdf.analog.channel,chan_label));
        if ~isempty(a_ind)
            [LFP.s{1},LFP.f,LFP.t,LFP.psd{1}]=spectrogram(bdf.analog.data(:,a_ind),window,noverlap,nfft,SR);
        else
            error('getLFPpsd:FirstChannelNotFound',['could not find an analog channel called',chan_label,'. skipping this label'])
        end
        
    if length(chanlist)>1
        for i=2:length(chanlist)
            chan_label=['chan' num2str(chanlist(i))];
            a_ind=find(strcmp(bdf.analog.channel,chan_label));
            if ~isempty(a_ind)
                [LFP.s{i},~,~,LFP.psd{i}]=spectrogram(bdf.analog.data(:,a_ind),window,noverlap,nfft,SR);
            else
                disp(['could not find an analog channel called: ',chan_label,'. skipping this label'])
            end
        end
    end
end