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

WS = 'base'; %use structure in workspace

assignin(WS,'structname',filename);

if (evalin(WS,'exist(structname,''var'')'))
    fprintf('Using structure ''%s'' which was already in workspace\n',filename);
    datastruct = evalin(WS,filename);
    evalin(WS,'clear structname');
    return
end
evalin(WS,'clear structname');

% if not, check that it's a file
if ~(exist(filename,'file')) 
    fprintf('%s ain''t no file or structure I ever heard of\n',filename);
    return
end

% assign content of structure from file to output
datastruct  = load(filename);
field_names = fieldnames(datastruct);
for i=1:size(field_names,1)
    if isstruct(eval(['datastruct.' field_names{i,:}]))
        datastruct  = getfield(datastruct, field_names{i,:});
        break;
    end
end



