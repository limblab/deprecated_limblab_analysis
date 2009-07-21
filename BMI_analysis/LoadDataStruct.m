function datastruct = LoadDataStruct(filename,type)
% loads a bdf mat file
% usage: datastruct = loaddatastruct(filename)
%       filename : the name of the mat file to be loaded
%       type : 'bdf' | 'binned' | 'pred' | 'filter'
%       datastruct output: holder for the loaded bdf structure
       

%default values:
datastruct = struct([]);
if (nargin~=2)
    disp('Please provide two string arguments containing the name and type');
    disp(' of a data structure in workspace or name of a .mat file');
    disp('usage:');
    disp('DataStruct=loaddatastruct(''myfile'')    % load data struct from ''myfile''');
    disp('Type = ''bdf'' | ''binned'' | ''pred'' | ''filter''');
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

datastruct = load(filename);

switch type
    case 'bdf'
        datastruct = datastruct.out_struct;
        disp(datastruct.meta);
    case 'binned'
        datastruct = datastruct.binnedData;
    case 'filter'
        datastruct = datastruct.filter;
    case 'OLpred'
        datastruct = datastruct.OLPredData;
    case 'RTpred'
        datastruct = datastruct.RTPredData;
    otherwise
        disp(sprintf('unknown file type: %s', type));
end



