function [still,stats]=is_still(x,varargin)
    %[still,stats]=is_still(x)
    %[still,stats]=is_still(x,'key',value)
    %takes a vector 'x', and returns a vector 'still' of 0 and 1 values. 
    %still will be 1 when the values of x change by less than the tolerance 
    %from point to point.
    %key-value pairs:
    %'tolerance': minimum change between points in x that will be
    %   considered movement. Default is 1% of the standard deviation in the
    %   changes. This works well for detecting still spots in the speed of
    %   monkey reaching data, but may not work well for other vectors like 
    %   force
    %'window':# of points before and after still periods to include in the
    %   output vector. Default is 0.
    %'range':# of points that must be below the tolerance before the data
    %   will be flagged as still. default is 1000 (1s for 1khz kinematic 
    %   data).
    
    if ~isvector(x)
        error('is_still:InputNotVector',['is_still is only vetted for single vectors and the input is a ',num2str(size(x,1)),'x',num2str(size(x,2)), ' matrix'])
    end
    if isrow(x)
        x=reshape(x,numel(x),1);
    end
 
       
    tol=[];
    window=0; %will not pad the still range. Can be reset by supplemental inputs
    pts=1000; %will only accept still periods of 10 pts or more. can be reset by supplemental inputs
    if mod(length(varargin),2)>0
        error('is_still:BadArgList','Supplementary arguments must be in key-value pairs. the number of arguments MUST be even')
    else
        for i=1:2:length(varargin)-1
            if isnumeric(varargin{i})
                error('is_still:BadArg',['Supplementary input ',num2str(i),' is numeric and must be text. Check the order of your key-value pairs'])
            end
            switch varargin{i}
                case 'window'
                    window=varargin{i+1};
                case 'range'
                    pts=varargin{i+1};
                case 'tolerance'
                    tol=varargin{i+1};
                otherwise
                    error('is_still:BadArg',['is_still does not recognize the argument', varargin{i}])
            end
        end
    end
    temp=diff(x);
    if isempty(tol)
        %if the user did not select a tolerance, use 1% of the standard
        %deviation of the input signal
        tol=0.01*std(temp);
    end
    if min(temp)>tol
        warning('is_still:ToleranceMismatch',['The minimum step size in the input vector: ',num2str(min(temp)), ', is larger than the selected tolerance: ',num2str(tol)])
    end
    %get steps where the change was less than the tolerance
    s=abs(temp)<tol;
    %build a template vector to find still points
    mask=ones(1,pts);
    %convolve to find still periods. this works because s and mask only
    %take on values of 0 and 1
    temp=conv(double(s),mask)>=pts;
    %clip the tail that convolution produces and set the initial still
    %vector
    still=temp(1:end-pts+1);
    % get a list of transition points:
    trans=diff(still);
    %from moving to still:
    ups=find(trans>0);
    %still to moving:
    downs=find(trans<0);
    %pad the front of each still period to account for the slow rise due to convolution and the desired window 
    pad=pts-1+window;
    for i=1:length(ups)
        still(max(ups(i)-pad,1):ups(i))=1;
    end
    %pad the end of each still period with the window
    for i=1:length(downs)
        still(downs(i):min(downs(i)+window,length(still)))=1;
    end
    %pad the end so the output is the same length as the input and the
    %still period shifts to compensate for the shifts associated with diff
    still=[still(1);still];
    if nargout==2
        stats.still_range=[min(x(still)) max(x(still))];
        stats.still_mean=mean(x(still));
        stats.still_stdev=std(x(still));
        stats.data_range=[min(x),max(x)];
        stats.data_stdev=std(x);
        stats.tol=tol;
    end
end