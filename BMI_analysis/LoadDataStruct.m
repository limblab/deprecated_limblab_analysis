function datastruct = LoadDataStruct(filename,varargin)
% loads a mat file
% usage: datastruct = loaddatastruct(filename)
%       filename   : string of the mat file to be loaded
%       datastruct : the loaded structure
%       varargin   : obsolete "type" argument, just for compatibility
       

%default values:
datastruct = struct([]);
if (nargin==0)
    disp('Please provide a string arguments containing the name');
    disp('of a data structure in workspace or name and full path of a .mat file');
    return
end

WS = 'base'; %workspace

assignin(WS,'structname',filename);

if (evalin(WS,'exist(structname,''var'')'))
    disp(sprintf('Using structure ''%s'' which was already in workspace',filename));
    datastruct = evalin(WS,filename);
    evalin(WS,'clear structname');
    return
end

evalin(WS,'clear structname');

if ~(exist(filename,'file')) % hope it's a file
    disp(sprintf('%s ain''t no file or structure I ever heard of',filename));
    return
end % if file exists

datastruct  = load(filename);
field_names = fieldnames(datastruct);
for i=1:size(field_names,1)
    if isstruct(eval(['datastruct.' field_names{i,:}]))
        datastruct  = getfield(datastruct, field_names{i,:});
        break;
    end
end
% 
% switch type
%     case 'bdf'
%         datastruct = datastruct.out_struct;
%         disp(datastruct.meta);
%     case 'binned'
%         datastruct = datastruct.binnedData;
%     case 'filter'
%         datastruct = datastruct.filter;
%     case 'OLpred'
%         datastruct = datastruct.OLPredData;
%     case 'RTpred'
%         datastruct = datastruct.RTPredData;
%     otherwise
%         disp(sprintf('unknown file type: %s', type));
end



