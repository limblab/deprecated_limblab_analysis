classdef firingRateData < timeSeriesData
    %sub-class inheriting from timeSeriesData so that FR specific methods
    % may be added. See also the timeSeriesData
    % class definition for inherited properties and methods
    properties(SetAccess = protected, GetAccess=public, SetObservable = true)
        meta
    end
    methods (Static = true)
        %constructor
        function frd=firingRateData()
            m.method='noData';
            m.offset=0;
            m.lagSteps=0;
            m.cropType='noData';
            m.sampleRate=20;
            m.kernelWidth=.05;
            set(frd,'meta',m)
        end
        %callback function
    end
    methods
        %setter methods
        %firing rate dat acurrently inherits set methods for data and fc 
        %from the dataTable class
        function set.meta(frd,meta)
            if ~isfield(meta,'offset') || ~isnumeric(meta.offset)
                error('meta:misconfiguredOffset','firingRateData.meta must contain an offset field with a number indicating the offset in ms. This is used to time shift data to manually account for latency')
            elseif ~isfield(meta,'method') || ~ischar(meta.method)
                error('meta:misconfiguredMethod','firingRateData.meta must contain a method field with a string describing the method used to compute the FR')
            elseif ~isfield(meta,'lagSteps') || ~isnumeric(meta.lagSteps)
                error('meta:misconfiguredLagSteps','firingRateData.meta must contain a lagSteps field with a number indicating the number of time points between successive lags')
            elseif ~isfield(meta, 'cropType') || ~ischar(meta.cropType)
                error('meta:misconfiguredCropType','firingRateData.meta must contain a cropType field with a string describing the type of cropping that was applied to generate the FR matrix')
            elseif ~isfield(meta,'sampleRate') || ~isnumeric(meta.sampleRate)
                error('meta:misconfiguredSampleRate','firingRateData.meta must contain a sampleRate field with a number indicating the sampling rate of the FR table')
            elseif ~isfield(meta,'kernelWidth') || ~isnumeric(meta.kernelWidth)
                error('meta:misconfiguredKerenelWidth','firingRateData.meta must contain a kernelWidth field with a number indicating the width of the kernel used for computing FR with gaussian convolution')
            else
                frd.meta=meta;
            end
            if meta.sampleRate~=1/meta.kernelWidth
                warning('meta:rateKernelMismatch','Commonly the kernel width is the same as one sample period. You have entered data where the kernel and SR do not match. Please ensure that the entered parameters will behave as you intended')
            end
        end
    end
    methods (Static = false)
        %general methods
        updateMeta(frd,meta)
        reCrop(frd,croptype)
    end
end