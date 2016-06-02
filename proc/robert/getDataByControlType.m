function [BatchList,datenames,daysPostDecoder]=getDataByControlType(animal,seedDates,controlType,Nth)

% syntax [BatchList,datenames,daysPostDecoder]=getDataByControlType(animal,seedDate,controlType,Nth);
%
% returns a list of data file names, representing files of the requested
% animal of the selected control type, for a range of dates.
%
%       INPUTS:
%               animal      - at present, 'Chewie', or 'Mini',
%                             case-insensitive.
%               seedDate    - 1 or 2 element vector of datenums.  If
%                             length(seedDate)==1, then seeDate(2)=today
%                             by default.
%               controlType - 'LFP', 'Spike', or 'hand'.  case-insensitive.
%               Nth         - which file in the chronological ranking is
%                             desired: 1 = first, 2 = second, etc.
%
%   example: getDataByControlType('Chewie',datenum('09-01-2011'),'hand',2)
%
% would get the 2nd hand control file from every day that can be
% found, starting with 09-01-2011 and continuing up to today.  Dates that
% didn't have a 2nd hand control file will be skipped over.

if nargout<3
    % don't do anything
end

if length(seedDates)==1
    seedDates(2)=today;
end

m=1;
for timeTravelIndex=seedDates(1):seedDates(2)
    try
        [BDFlist,datename_1]=findBDF_withControl(animal,datestr(timeTravelIndex,'mm-dd-yyyy'),controlType);
        % can be empty with no error, if there exists a day with that date,
        % but on that day there was none of the requested type of control.
        if ~isempty(BDFlist)
            BatchList{m}=BDFlist{Nth};
            datenames{m}=datename_1{Nth};
            daysPostDecoder(m)=timeTravelIndex-seedDates(1);
            m=m+1;
        end
    catch ME
        if ~isempty(regexp(ME.message,'file not found', 'once')) %|| ...
            %  ~isempty(regexp(ME.identifier,'MATLAB:nonExistentField', 'once'))
            % if it's a simple matter of the day not being there, no
            % need to quit over that.
            continue
        else
            % if there was some other kind of message, well we need to
            % know
            fprintf(2,'error on day %s\n',datestr(timeTravelIndex))
            rethrow(ME)
        end
    end
end

if nargout < 2
    datenames=[];
end