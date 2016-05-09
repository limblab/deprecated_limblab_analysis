function [lagData, lagPts, t]=timeShiftBins(ex,data,lags,varargin)
    %timeShiftBins is a method of the experiment class and should be saved
    %in the @experiment folder with the other class methods.
    %
    %This method is intended to be called only by calcFiringRate in order
    %to generate lagged firing rate data.
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
    %[lagData, lagPts, t]=timeShiftBins(data,lags)
    %additionally returns a 'time' vector indicating the time of the bins.
    %If no time is passed into the function (see below), then the output
    %will be based on indexes; i.e., the indexes for data would be
    %1:length(data(:,1))
    %
    %timeShiftBins also accepts key-value pairs to modify behavior of the
    %function. Currently implemented key-value pairs are:
    %'lagSteps':    the number of points between lags. can be used to 
    %               separate lags by multiples of the sample rate
    %'time':        a vector of time. Passing time will do nothing unless a
    %               third output is selected. If a third output is selected
    %               the passed time vector will be pruned or expanded to
    %               match the data length after cropType is accounted for.
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
                case 'time'
                    t=varargin{i+1};
                    if numel(t)~=numel(data)
                        error('timeShiftBins:badTimeVector','time must be a vector with the same number of elements as data')
                    end
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
    
    if nargout==3
        %deal with time:
        %if we don't have time, generate a vector of indexes:
        if ~exist('t','var')
            t=[1:length(data(:,1))]';
        elseif isrow(t)
            t=t';
        end
        %get the time step of whatever time we have now
        dt=mode(diff(t));
        %now expand or crop time to match the result of cropType
        switch cropType
            case 0
                if min(lags)<0
                    pre=dt*([min(lagPts):-1]' )+t(1);
                else
                    pre=[];
                end
                if max(lags)>0
                    post=dt*[1:max(lagPts)]'+max(t);
                    %post=dt*[1:abs(min(lagPts))]'+max(t);
                else
                    post=[];
                end
                
                %expand t to handle the extra points
                t=[pre;t;post];
            case 1
    %             %do nothing to t
            case 2
                %crop t to match cropped lagData:
                t=t(max(lagPts)+1:end-abs(min(lagPts)));
            otherwise
                error('timeShiftBins:badTrimTypeValue','This should never happen: the trimType variable internal to the timeShiftBins function should only take on values of 0 1 or 2, somebody broke the code')
        end
        %ensure the dimension of t matches the dimension of data
        if  isrow(data)
            t=t';
        end
    end
end