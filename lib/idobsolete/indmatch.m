function [indn,errflag,flagmea,flagall,flagnoise,flagboth] = ...
    indmatch(ind,names,nn,nameflag,lam)
%INDMATCH
% Help function to SUBSREF and SUBNDECO to decode input indices.

%   Copyright 1986-2010 The MathWorks, Inc.

errflag = struct('identifier','','message','');
indn = [];
flagnoise = 0;
flagmea = 0;
flagall = 0;
flagboth = 0;
%% case 1
if isa(ind,'double')
    indn = ind;
    if isempty(indn)
        if strcmpi(nameflag,'input')
            flagnoise = 1;
        else
            errflag.identifier = 'Ident:general:indmatch1';
            errflag.message = ['No matching ',lower(nameflag),' channels found.'];
        end
    end
    if any(indn>nn)||(~isempty(indn)&&any(indn<1))
        errflag.identifier = 'Ident:general:indmatch2';
        errflag.message = [nameflag,' channel index outside model''s range.'];
    end
    return
end
if strcmp(ind,':'),
    indn=1:nn;
    return
end
if ischar(ind)
    ind = {ind};
end
indtemp =[];
for kk = 1:length(ind)
    tf = strmatch(ind{kk},names,'exact');
    indtemp =[indtemp,tf];
end
if ~isempty(indtemp)
    indn = indtemp;
    return
end
if strcmpi(nameflag,'input') % test for 'measured', 'noise' and 'allx9'
    ind = ind{1};
    nt = idchnona(ind);
    if strcmpi(nt,'noise')
        indn=[];
        flagnoise = 1;
    elseif strcmpi(nt,'measured')
        indn=1:nn;
        flagmea = 1;
    elseif strcmp(ind,'allx9')||strcmp(ind,'all') % all allowed for compatibility
        indn=1:nn;
        if norm(lam)>0,flagall = 1;end
    elseif strcmp(ind,'bothx9')
        indn=1:nn;
        if norm(lam)>0,flagboth = 1;end
    end
end

if isempty(indn) && ~flagnoise
    errflag.identifier = 'Ident:general:indmatch1';
    errflag.message = ['No matching ',nameflag,' channels found.'];
end
