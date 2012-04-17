function varargout=FileParts(nameIn)

% syntax [pathstr,namestr,ext,[version?]]=FileParths(nameIn)
%
% the entire reason this exists is to make up for a retarded shortcoming of
% MATLAB, where they changed the number of outputs supported by
% fileparts.m, and then made the new function specifically not
% backwards-compatibile with the old function.  Idiots.
%
% call exactly as you would fileparts.m, using however many outputs you
% feel like using, up to 4.  The function will return however many are 
% requested (in order, so if you want a later one but not earlier 
% ones use ~ for earlier outputs).  If the current version of 
% fileparts.m doesn't support the 4th argument and you ask for it anyway, 
% it will be returned as NaN.

if verLessThan('matlab','7.11')
    switch nargout
        case 1
            [varargout{1},~,~,~]=fileparts(nameIn);
        case 2
            [varargout{1},varargout{2},~,~]=fileparts(nameIn);
        case 3            
            [varargout{1},varargout{2},varargout{3},~]=fileparts(nameIn);
        case 4
            [varargout{1},varargout{2},varargout{3},varargout{4}]=fileparts(nameIn);
    end
else
    switch nargout
        case 1
            [varargout{1},~,~]=fileparts(nameIn);
        case 2
            [varargout{1},varargout{2},~]=fileparts(nameIn);
        case 3            
            [varargout{1},varargout{2},varargout{3}]=fileparts(nameIn);
        case 4
            [varargout{1},varargout{2},varargout{3}]=fileparts(nameIn);
            varargout{4}=NaN;
    end
end
