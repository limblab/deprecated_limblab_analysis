% CO: center out day
% RT: random target day
% S: file has been sorted
% -: file is partially sorted
% x: consider re-sorting....
% ?: consider considering re-sorting...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Mr T
mrt_data = {'MrT','2013-08-19','FF','CO'; ...   % S x
            'MrT','2013-08-20','FF','RT'; ...   % S x
            'MrT','2013-08-21','FF','CO'; ...   % S x - AD is split in two so use second but don't exclude trials
            'MrT','2013-08-22','FF','RT'; ...   % S x
            'MrT','2013-08-23','FF','CO'; ...   % S x
            'MrT','2013-08-30','FF','RT'; ...   % S x
            'MrT','2013-09-03','VR','CO'; ...   % S x
            'MrT','2013-09-04','VR','RT'; ...   % S x
            'MrT','2013-09-05','VR','CO'; ...   % S x
            'MrT','2013-09-06','VR','RT'; ...   % S x
            'MrT','2013-09-09','VR','CO'; ...   % S x
            'MrT','2013-09-10','VR','RT'; ...   % S x
            'MrT','2013-09-24','VRFF','RT'; ... % S x
            'MrT','2013-09-25','VRFF','RT'; ... % S x
            'MrT','2013-09-27','VRFF','RT'; ... % S x
            'MrT','2013-10-11','VR','RT'};      % S x - 45 degree visual rotation};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Chewie
% Visual rotation days
vr_goodDays = {'Chewie','2013-10-03','VR','CO' ... % S ?
               'Chewie','2013-10-09','VR','RT' ... % S x
               'Chewie','2013-10-10','VR','CO' ... % S ?
               'Chewie','2013-10-11','VR','RT' ... % S x
               'Chewie','2013-12-12','VR','RT' ... % S
               'Chewie','2013-12-13','VR','RT' ... % S
               'Chewie','2013-12-19','VR','CO' ... % 
               'Chewie','2013-12-20','VR','CO'};   % 

% Force field days
ff_goodDays = {'Chewie','2013-10-22','FF','CO' ... % S ?
               'Chewie','2013-10-23','FF','CO' ... % S ?
               'Chewie','2013-10-28','FF','RT' ... % S x
               'Chewie','2013-10-29','FF','RT' ... % S x
               'Chewie','2013-10-31','FF','CO' ... % S ?
               'Chewie','2013-11-01','FF','CO' ... % S ?
               'Chewie','2013-12-03','FF','CO' ... % S
               'Chewie','2013-12-04','FF','CO' ... % S
               'Chewie','2013-12-09','FF','RT' ... % S
               'Chewie','2013-12-10','FF','RT' ... % S
               'Chewie','2013-12-17','FF','RT' ... % 
               'Chewie','2013-12-18','FF','RT'};   % 
               

           
           
ff_iffyDays = {'2013-10-17', ... % S RT 0.13 force mag
              '2013-10-18'};    % S RT 0.1 force mag

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mihili
% Force field days
ff_goodDays = {};

% Visual rotation days
vr_goodDays = {};

        

% Bad data
mrt_ff_iffyDays = {'2013-08-27', ... %   RT - poor work ethic, but might be good?
               '2013-08-28'};    %   CO - poor work ethic, adaptation period is a bit short
    
mrt_ff_badDays = {'2013-08-13', ...  % S CO - force field at 90 degrees
              '2013-08-14'};     % S RT - force field changed partway through
