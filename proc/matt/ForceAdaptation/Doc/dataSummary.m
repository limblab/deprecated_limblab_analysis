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
            'MrT','2013-09-27','VRFF','RT'}; ... % S x
            %'MrT','2013-10-11','VR','RT'};      % S x - 45 degree visual rotation};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Chewie 
chewie_data = {'Chewie','2013-10-03','VR','CO'; ... %1  S ?
               'Chewie','2013-10-09','VR','RT'; ... %2  S x
               'Chewie','2013-10-10','VR','RT'; ... %3  S ? 
               'Chewie','2013-10-11','VR','RT'; ... %4  S x
               'Chewie','2013-10-22','FF','CO'; ... %5  S ?
               'Chewie','2013-10-23','FF','CO'; ... %6  S ?
               'Chewie','2013-10-28','FF','RT'; ... %7  S x
               'Chewie','2013-10-29','FF','RT'; ... %8  S x
               'Chewie','2013-10-31','FF','CO'; ... %9  S ?
               'Chewie','2013-11-01','FF','CO'; ... %10 S ?
               'Chewie','2013-12-03','FF','CO'; ... %11 S
               'Chewie','2013-12-04','FF','CO'; ... %12 S
               'Chewie','2013-12-09','FF','RT'; ... %13 S
               'Chewie','2013-12-10','FF','RT'; ... %14 S
               'Chewie','2013-12-12','VR','RT'; ... %15 S
               'Chewie','2013-12-13','VR','RT'; ... %16 S
               'Chewie','2013-12-17','FF','RT'; ... %17 S
               'Chewie','2013-12-18','FF','RT'; ... %18 S
               'Chewie','2013-12-19','VR','CO'; ... %19 S
               'Chewie','2013-12-20','VR','CO'};    %20 S
           
chewie_control_data = {'Chewie','2015-03-09','VR','CO';
                       'Chewie','2015-03-11','VR','CO';
                       'Chewie','2015-03-12','VR','CO';
                       'Chewie','2015-03-13','VR','CO';
                       'Chewie','2015-03-16','VR','RT';
                       'Chewie','2015-03-17','VR','RT';
                       'Chewie','2015-03-18','VR','RT';
                       'Chewie','2015-03-19','VR','CO';
                       'Chewie','2015-03-20','VR','RT'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mihili  
mihili_data = {'Mihili','2014-01-14','VR','RT'; ...    %1  S(M-P)
               'Mihili','2014-01-15','VR','RT'; ...    %2  S(M-P)
               'Mihili','2014-01-16','VR','RT'; ...    %3  S(M-P)
               'Mihili','2014-02-03','FF','CO'; ...    %4  S(M-P)
               'Mihili','2014-02-14','FF','RT'; ...    %5  S(M-P)
               'Mihili','2014-02-17','FF','CO'; ...    %6  S(M-P)
               'Mihili','2014-02-18','FF','CO'; ...    %7  S(M-P) - Did both perturbations
               'Mihili','2014-02-18-VR','VR','CO'; ... %8  S(M-P) - Did both perturbations
               'Mihili','2014-02-21','FF','RT'; ...    %9  S(M-P)
               'Mihili','2014-02-24','FF','RT'; ...    %10 S(M-P) - Did both perturbations
               'Mihili','2014-02-24-VR','VR','RT'; ... %11 S(M-P) - Did both perturbations
               'Mihili','2014-03-03','VR','CO'; ...    %12 S(M-P)
               'Mihili','2014-03-04','VR','CO'; ...    %13 S(M-P)
               'Mihili','2014-03-06','VR','CO'; ...    %14 S(M-P)
               'Mihili','2014-03-07','FF','CO'};       %15 S(M-P)
        
mihili_iffyDays = {'Mihili','2014-01-17','VR','RT'; ... % Poor work ethic in washout, so it's really long... might be useable if needed
                   'Mihili','2014-01-20','VR','CO'};    % Adaptation period is half as short as it should be. Maybe not a total waste though
               %%% ALSO A FEW PARTIAL DAYS WITH NO WASHOUT
mihili_partialDays = {'Mihili','2014-02-11','FF','CO'; ...
                      'Mihili','2014-02-22','FF','RT'; ...
                      'Mihili','2014-02-25','VR','CO'; ...
                      'Mihili','2014-02-27','VR','CO'; ...
                      'Mihili','2014-02-28','VR','CO'};
                  % note: 12/12 and 12/13 were the first two FF days for
                  % Mihili... might be worth looking at, even though they
                  % don't have complete data
                   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bad data
% mrt_ff_iffyDays = {'2013-08-27', ... %   RT - poor work ethic, but might be good?
%                    '2013-08-28'};    %   CO - poor work ethic, adaptation period is a bit short
%     
% mrt_ff_badDays = {'2013-08-13', ...  % S CO - force field at 90 degrees
%                    '2013-08-14'};     % S RT - force field changed partway through
% 
% chewie_iffyDays = {'2013-10-17', ... % S RT 0.13 force mag
%                    '2013-10-18'};    %   RT 0.1 force mag