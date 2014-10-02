function [tuned,varargout]=isTuned(data,varargin)
    %uses an ANOVA to test whether a unit is tuned. Assumes data of the
    %following format:
    %data=[FR;TimeWindow;Angle]
    %in this case TimeWindow and Angle are both categorical variables
    %(integers). Time window is a flag that indicates which segment of the
    %trial the FR estimate came from. This is intented so that FR samples
    %may be taken in reference periods to provide baseline firing rate for
    %a simple comparison such as pre-movement vs peak velocity, the
    %TimeWindow variable would be a column vector containing either 0 or 1
    %Angle is a flag containing a marker for the direction of that trial
    %the integer angle of the target in a center out task would be ideal
    %here. Randomly directed reaches might be binned around specific angles
    %to produce this vector for less structured data sets
    %always returns a boolean variable flagging whether the unit is tuned
    %with angle. May also return the following fields:
    %[tuned,StatData,model,dataset]=isTuned(data)
    %statData is the full ouptut from the matlab function anova(...)
    %model is the full model formed by calling Linearmodel.fit on the
    %dataset
    %dataset is the data reformatted in a dataset array. Note, dataset
    %arrays are depreciated

    ConfLevel =[];

    for i=1:2:length(varargin)
        switch varargin{i}
            case 'ConfLevel'
                ConfLevel=varargin{i+1};
            otherwise
                warning('ISTUNED:UNRECOGNIZEDFLAG',strcat(varargin{i},' is not a recognized flag for the isTuned function. This key-value pair will be ignored'))
        end
    end
    if isempty(ConfLevel)
        ConfLevel=.05;
    end
  
    FiringRate=data(:,1);
    TimeWindow=data(:,2);
    Angle=data(:,3);
    ds=dataset(FiringRate);
    ds.Angle=ordinal(Angle);
    ds.TimeWindow=ordinal(TimeWindow);
    
    mdl=LinearModel.fit(ds,'interactions','ResponseVar','FiringRate');
    StatData=anova(mdl);
    tuned=(double(StatData('Angle','pValue'))<ConfLevel) || (double(StatData('Angle:TimeWindow','pValue'))<ConfLevel);
    modulated=(double(StatData('TimeWindow','pValue'))<ConfLevel);
    if (tuned & ~modulated)
        warning('ISTUNED:TUNEDBUTNOTMODULATED','The given data set does not modulated across the TimeWindow conditions. The baseline data appears to modulate with direction, indicating that the baseline is poorly selected')
    end
    if nargout >1
        varargout{1}=StatData;
    end
    if nargout >2
        varargout{2}=mdl;
    end
    if nargout >3
        varargout{2}=ds;
    end
end