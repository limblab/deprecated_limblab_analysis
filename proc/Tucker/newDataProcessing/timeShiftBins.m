function [lagData, lagPts]=timeShiftBins(data,lags,varargin)
    %lagData=timeShiftBins(data,lags)
    %takes in a vector 'data' and returns a matrix where each column
    %contains a shifted version of the original vector. By default data is
    %shifted by a single index in each column, so:
    %lagData=timeShiftBins(data,[-2,3]) produces a 6 column matrix (5 
    %columns of lags, and the original un-shifted column). Columns in the
    %output are ordered sequentially, so in the above example the unshifted
    %column would be the 3rd column. By default timeShiftBins will crop the
    %resulting matrix to the same length as the original data.
    %
    %[lagData, lagPts]=timeShiftBins(data,lags)
    %returns both the lag matrix and a vector containing the number of
    %points each column is shifted.
    %
    %timeShiftBins also accepts key-value pairs to modify behavior of the
    %function. Currently implemented key-value pairs are:
    %'lagSteps':    the number of points between lags. can be used to 
    %               separate lags by multiples of the sample rate
    %'cropType':    can be a string or an integer. If a string, must be
    %               'noCrop','keepSize' or 'tightCrop'. If an integer must
    %               be 0, 1 or 2. 0 or 'noCrop' return an expanded matrix 
    %               padded with zero where no data was available for a lag. 
    %               1 or 'keepSize' returns a matrix of the same length as
    %               the input data, padded with zeros where no data was
    %               available for lags. This is default behavior. 2 or
    %               'tightCrop' truncates the start and end of the matrix
    %               to remove all rows where data was not available in any
    %               column.
    %
    
    %make sure data is a column vector
    if size(data,2)>1
        if size(data,1)>1
            error('timeShiftBins:dataNotVector','the input data must be a vector')
        else
            warning('timeShiftBins:rowVectorPassed','timeShiftBins works with column vectors. The row data input will be reshaped and returned in column format')
            data=reshape(data,numel(data),1);
        end
    end
    if ~isempty(varargin)
        for i=1:2:length(varargin)
            switch(varargin{i})
                case 'lagSteps'
                    lagSteps=varargin{i+1};
                case 'cropType'
                    switch varargin{i+1}
                        case 'noCrop'
                            cropType=0;
                        case 'keepSize'
                                cropType=1;
                        case 'tightCrop'
                                cropType=2;
                        otherwise
                            if isnumeric(varargin{i+1}) && varargin{i+1}<3 && varargin{i+1}>-1
                                cropType=varargin{i+1};
                            else
                                error('timeShiftBins:badCropType','cropType must either be one of the 3 valid strings, or an integer from 0:2 indicating what type of cropping to do on the output matrix')
                            end
                    end
                otherwise
                    if isnumeric(varargin{i})
                        error('timeShiftBins:numericKey',['timeShiftBins takes extra arguments as key-value pairs, and keys must be characters. ',num2str(varargin{i}),' is numeric, and not a valid key.'])
                    elseif ~ischar(varargin{i})
                        error('timeShiftBins:keyNotString','timeShiftBins takes extra arguments as key-value pairs, and keys must be characters. ' )
                    else
                        error('timeShiftBins:invalidKey',['the string: ',varargin{i}, 'is not a valid key' ])
                    end
            end
        end
    end
    if ~exist('lagSteps','var')
        lagSteps=1;
    end
    if ~exist('cropType','var')
        cropType=1;
    end
    %sanitize the lag inputs
    if numel(lags)==1
        lags=[lags,0];
    end
    if numel(lags)~=2
        error('timeShiftBins:badLagFormat','the lags input must be a 1 or 2 element vector')
    end
    if (lags(1)*lags(2))>0
        %error if the range of lags does not include 0, this would cause
        %problems in the trimming routines
        error('timeShiftBins:lagsExcludeZero','the range of the lags must include zero')
    end
    if ~isempty(find(mod(lags,1),1))
        %error if the lags are not integers
        %we have to do this wonky test because we don't want to force
        %people to cast their lags as integer data, so we test for integer
        %values in double typed data
        error('timeShiftBins:lagsNotInteger','the lags should be integer values of the number of positions from zero to take lags.')
    end
    
    numPts=numel(data);
    lagPts=[min(lags):lagSteps:max(lags)];
    
    if isempty(find(lagPts==0,1))
        %if the stepping forced by lagSteps skipped zero, put it back in
        lagPts=sort([lagPts,0]);
    end
    numlags=numel(lagPts);
    
    if max(lags)>max(lagPts)
        warning('timeShiftBins:lagLagStepMismatch',['The given lag range: [', num2str(lags),'] is not evenly divisible by the lagStep: ',num2str(lagSteps),' as a consequence the following lags will be used: [',num2str(lagSteps),']'])
    end
    lagData=nan(numel(data)+numlags-1,numlags);
    for i=1:numlags
        startInd=1+(i-1)*lagSteps;
        lagData(startInd:(startInd+numPts-1),i)=data;
    end
    
    switch cropType
        case 0
            %do nothing to crop the data
        case 1
%             leads=numel(find(lagPts<0));
%             lags=numel(find(lagPts>0));
            leads=abs(min(lagPts));
            lags=max(lagPts);
            lagData=lagData(leads+1:end-lags,:);
        case 2
            tmp=abs(min(lagPts))+max(lagPts);
            lagData=lagData(tmp+1:end-tmp,:);
        otherwise
            error('timeShiftBins:badTrimTypeValue','This should never happen: the trimType variable internal to the timeShiftBins function should only take on values of 0 1 or 2, somebody broke the code')
    end
    
end