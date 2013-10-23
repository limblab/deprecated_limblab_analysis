% CO: center out day
% RT: random target day
% S: file has been sorted
% -: file is partially sorted

%%% Mr T
% Force field days
ff_goodDays = {'2013-08-19', ... % S CO
               '2013-08-20', ... % S RT
               '2013-08-21', ... % S CO - AD is split in two so use second but don't exclude trials
               '2013-08-22', ... % S RT
               '2013-08-23', ... % S CO
               '2013-08-30'};    % S RT

ff_iffyDays = {'2013-08-27', ... %   RT - poor work ethic, but might be good?
               '2013-08-28'};    %   CO - poor work ethic, adaptation period is a bit short
    
ff_badDays = {'2013-08-13', ...  % S CO - force field at 90 degrees
              '2013-08-14'};     % S RT - force field changed partway through

% Visual rotation days
vr_goodDays = {'2013-09-03', ... % S CO
               '2013-09-04', ... % S RT
               '2013-09-05', ... % S CO
               '2013-09-06', ... % S RT
               '2013-09-09', ... % S CO
               '2013-09-10'};    % S RT
           
vrff_goodDays = {'2013-09-24', ... % S RT
                 '2013-09-25', ... % S RT
                 '2013-09-27'};    % S RT
             
%%% Chewie
% Force field days
ff_goodDays = {};    % S RT

ff_iffyDays = {};    % S RT
    
ff_badDays = {};     % S RT

% Visual rotation days
vr_goodDays = {'2013-10-03'}; % S CO
           
vrff_goodDays = {};    % S RT
             
             