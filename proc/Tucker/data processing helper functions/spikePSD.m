function [outData]=spikePSD(bdf,unit,varargin)
    %Computes the power spectral density of a single spike train.
    %basic format is:
    %dataStruct=spikePSD(bdf,unit)
    %By default spikePSD will use an fft to compute the power, however, the
    %function accepts additional arguments as key-value pairs.
    %dataStruct=spikePSD(bdf,unit,'key',value...)
    %the following keys are implemented:
    %'window'- the time range over which to compute the PSD. should be a 2
    %element vector containing the start and end times in order. the
    %default is the whole time range for the specified unit
    %'sampleRate'-forces a resolution for the spike traine, constraining
    %the frequency window of the PSD. High sample rates may cause slower
    %operation especailly with non-fft methods. The default is 1000hz
    %'estimator'-not used if fft is specified as method, or default method
    %is used. Specifies the power estimation kernel function. See help for
    %the spectrum class to see different estimator kernels. Default is 'welch'
    %'method'- specifies the method for computing the power. If fft is
    %selected spikePSD will compute the fft of the spike train and then
    %compute the power. For any other method, spikePSD will use the kernel
    %function specified in the estimatory variable in conjuction with the
    %selected method. Default is 'fft'. for more information see the help
    %for the spectrum class to see different methods.
    
    window=[];
    titleString=[];
    xlabelString=[];
    ylabelString=[];
    sampleRate=[];
    doFigure=[];
    figName=[];
    estimator=[];
    method=[];
    methodArgs=[];
    if ~isempty(varargin)
        for i=1:2:length(varargin)
            switch varargin{i}
                case 'window'
                    window=varargin{i+1};
                case 'sampleRate'
                    sampleRate=varargin{i+1};
                case 'estimator'
                    estimator=varargin{i+1};
                case 'method'
                    method=varargin{i+1};
                case 'methodArgs'
                    methodArgs=varargin{i+1};
                case 'doFigure'
                    doFigure=varargin{i+1};
                case 'titleString'
                    titleString=varargin{i+1};
                case 'xlabelString'
                    xlabelString=varargin{i+1};
                case 'ylabelString'
                    ylabelString=varargin{i+1};
                case 'name'
                    figName=varargin{i+1};
                otherwise
                    warning('spikePSD:unrecognized_input_flag',strcat(varargin{i},' is not a recognized input flag and will be ignored'))
            end
        end
    end
      
    if isempty(window)
        %select the whole data range. since spikes don't necessarily span
        %the same range as the kinematics use whichever is wider
        mx=max(     [max(bdf.units(unit).ts)    ,   max(bdf.pos(:,1))   ]   );
        mn=min(     [min(bdf.units(unit).ts)    ,   min(bdf.pos(:,1))   ]   );
        window=[mn,mx];
    end
    if isempty(sampleRate)
        sampleRate=1000;
    end
    if isempty(estimator)
        estimator='welch';
    end
    if isempty(method)
        method='fft';
    end
    if isempty(methodArgs)
        methodArgs(1).flag='Fs';
        methodArgs(1).value=sampleRate;
    else
        if isempty(find(strcmp('Fs',{methodArgs(:).flag}),1))
            methodArgs(1).flag='Fs';
            methodArgs(1).value=sampleRate;
        end
    end
    if isempty(doFigure)
        doFigure=true;
    end
    if isempty(titleString)
        titleString=strcat('Power vs frequency for unit ', num2str(unit));
    end
    if isempty(xlabelString)
        xlabelString='Frequency (hz)';
    end
    if isempty(figName)
        figName=strcat('unit_',num2str(unit),'_PSD');
    end
    if isempty(ylabelString)
        if strcmp(method,'fft')
            titleString=strcat('Power/Frequency (dB/Hz) for unit', num2str(unit));
        else
            ylabelString='Power';
        end
    end
    %build a vector of zeros and ones on the range
    mask=bdf.units(unit).ts>=window(1) & bdf.units(unit).ts<=window(2);
    t=bdf.units(unit).ts(mask);
    t=round((t-t(1))*sampleRate)+1;

    x=zeros(1,range(t)+1);
    x(t)=1;
    
    if strcmp(method,'fft')
        N = length(x);
        xdft = fft(x);
        xdft = xdft(1:N/2+1);
        psdx = (1/(sampleRate*N)).*abs(xdft).^2;
        psdx(2:end-1) = 2*psdx(2:end-1);
        freq = 0:sampleRate/length(x):sampleRate/2;
        outData.fft=xdft;
        outData.psd=psdx;
        outData.freq=freq;
        
        if doFigure
            fhandle=figure;
            plot(freq,10*log10(psdx)); grid on;
            title(titleString);
            xlabel(xlabelString); 
            ylabel(ylabelString);
            set(fhandle,'Name',figName)
            outData.figure=fhandle;
        end
    else
        %set the estimator method object
        eval(strcat('h=spectrum.',estimator,'();'));
        %set up the expression to call:
        args=[];
        for i=1:length(methodArgs)
            if isnumeric(methodArgs(i))
                args=strcat(args,',',char(39),methodArgs(i).flag,char(39),',',methodArgs(i).value);
            else
                args=strcat(args,',',char(39),methodArgs(i).flag,char(39),',',num2str(methodArgs(i).value));
            end
        end
        disp(strcat('power_est=',method,'(h,x',args,');'))
        eval(strcat('power_est=',method,'(h,x',args,');'));
        outData.psd=power_est.data;
        outData.freq=power_est.Frequencies;
        outData.power_est=power_est;
        if doFigure
            fhandle=figure;
            plot(power_est.Frequencies,power_est.Data)
            title(titleString)
            xlabel(xlabelString)
            ylabel(ylabelString)
            set(fhandle,'Name',figName)
            outData.figure=fhandle;
        end
    end
end

