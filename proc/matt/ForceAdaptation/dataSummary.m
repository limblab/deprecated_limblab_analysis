% CO: center out day
% RT: random target day
% S: file has been sorted

% Force field days
ff_goodDays = {'2013-08-19', ... % S CO
               '2013-08-20', ... %   RT
               '2013-08-21', ... %   CO - AD is split in two so use second but don't exclude trials
               '2013-08-22', ... % S RT
               '2013-08-23', ... % S CO
               '2013-08-30'};    %   RT

ff_iffyDays = {'2013-08-27', ... % RT - poor work ethic, but might be good?
               '2013-08-28'};    % CO - poor work ethic, adaptation period is a bit short
    
ff_badDays = {'2013-08-13', ...  % S CO - force field at 90 degrees
              '2013-08-14'};     % S RT - force field changed partway through

% Visual rotation days
vr_goodDays = {'2013-09-03', ... % S CO
               '2013-09-04', ... % S RT
               '2013-09-05', ... % CO
               '2013-09-06', ... % S RT
               '2013-09-09', ... % CO
               '2013-09-10'};    % RT