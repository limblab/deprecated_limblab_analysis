% CO: center out day
% RT: random target day
% FF: force field perturbation
% VR: visual rotation perturbation
% CS: control session
% BC: brain control session
% S(M/P): file has been sorted, M is M1, P is PMd
% ?: consider re-sorting...

sessionList = { ...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Mr T
%     'MrT','2013-08-19','FF','CO'; ...   %1  S(M+P) - 0.15 1.48 CCW
%     'MrT','2013-08-20','FF','RT'; ...   %2  S(M+P) - 0.15 1.48 CCW
%     'MrT','2013-08-21','FF','CO'; ...   %3  S(M+P) - 0.15 1.48 CCW - AD is split in two. This was stitched together.
%     'MrT','2013-08-22','FF','RT'; ...   %4  S(M+P) - 0.15 1.48 CCW
%     'MrT','2013-08-23','FF','CO'; ...   %5  S(M+P) - 0.15 1.48 CCW
%     'MrT','2013-08-30','FF','RT'; ...   %6  S(M+P) - 0.15 1.48 CCW
%     'MrT','2013-09-03','VR','CO'; ...   %7  S(M+P) - 30 CCW
%     'MrT','2013-09-04','VR','RT'; ...   %8  S(M+P) - 30 CCW
%     'MrT','2013-09-05','VR','CO'; ...   %9  S(M+P) - 30 CCW
%     'MrT','2013-09-06','VR','RT'; ...   %10 S(M+P) - 30 CCW
%     'MrT','2013-09-09','VR','CO'; ...   %11 S(M+P) - 30 CCW
%     'MrT','2013-09-10','VR','RT'; ...   %12 S(M+P) - 30 CCW
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Chewie
% % %     'Chewie','2013-10-03','VR','CO'; ... %1  S(M) - 30 CCW
% % %     'Chewie','2013-10-09','VR','RT'; ... %2  S(M) - 30 CCW
% % %     'Chewie','2013-10-10','VR','RT'; ... %3  S(M) ? - 30 CCW
% % %     'Chewie','2013-10-11','VR','RT'; ... %4  S(M) ? - 30 CCW
    'Chewie','2013-10-22','FF','CO'; ... %5  S(M) - 0.15 1.48 CCW
    'Chewie','2013-10-23','FF','CO'; ... %6  S(M) - 0.15 1.48 CCW
% % %     'Chewie','2013-10-28','FF','RT'; ... %7  S(M) ? - 0.15 1.48 CCW
% % %     'Chewie','2013-10-29','FF','RT'; ... %8  S(M) ? - 0.15 1.48 CCW
    'Chewie','2013-10-31','FF','CO'; ... %9  S(M) - 0.15 1.48 CCW
    'Chewie','2013-11-01','FF','CO'; ... %10 S(M) - 0.15 1.48 CCW
    'Chewie','2013-12-03','FF','CO'; ... %11 S(M) - 0.15 1.48 CCW
    'Chewie','2013-12-04','FF','CO'; ... %12 S(M) - 0.15 1.48 CCW
% % %     'Chewie','2013-12-09','FF','RT'; ... %13 S(M) ? - 0.15 1.48 CCW
% % %     'Chewie','2013-12-10','FF','RT'; ... %14 S(M) ? - 0.15 1.48 CCW
% % %     'Chewie','2013-12-12','VR','RT'; ... %15 S(M) ? - 30 CCW
% % %     'Chewie','2013-12-13','VR','RT'; ... %16 S(M) ? - 30 CCW
% % %     'Chewie','2013-12-17','FF','RT'; ... %17 S(M) ? - 0.15 1.48 CCW
% % %     'Chewie','2013-12-18','FF','RT'; ... %18 S(M) ? - 0.15 1.48 CCW
% % %     'Chewie','2013-12-19','VR','CO'; ... %19 S(M) ? - 30 CCW
% % %     'Chewie','2013-12-20','VR','CO'; ... %20 S(M) ? - 30 CCW
%     'Chewie','2015-03-09','CS','CO'; ... %21 S(M) ?
%     'Chewie','2015-03-11','CS','CO'; ... %22 S(M) ?
%     'Chewie','2015-03-12','CS','CO'; ... %23 S(M) ?
%     'Chewie','2015-03-13','CS','CO'; ... %24 S(M) ?
% % %     'Chewie','2015-03-16','CS','RT'; ... %25 S(M) ?
% % %     'Chewie','2015-03-17','CS','RT'; ... %26 S(M) ?
% % %     'Chewie','2015-03-18','CS','RT'; ... %27 S(M) ?
%     'Chewie','2015-03-19','CS','CO'; ... %28 S(M) ?
% % %     'Chewie','2015-03-20','CS','RT'; ... %29 S(M) ?
    'Chewie','2015-06-29','FF','CO'; ... %30 S(M) - 0.15 1.48 CW - SHORT WASHOUT
    'Chewie','2015-06-30','FF','CO'; ... %31 S(M) - 0.15 1.48 CW
    'Chewie','2015-07-01','FF','CO'; ... %32 S(M) - 0.15 1.48 CCW
    'Chewie','2015-07-03','FF','CO'; ... %33 S(M) - 0.15 1.48 CCW
    'Chewie','2015-07-06','FF','CO'; ... %34 S(M) - 0.15 1.48 CW
    'Chewie','2015-07-07','FF','CO'; ... %35 S(M) - 0.15 1.48 CW
    'Chewie','2015-07-08','FF','CO'; ... %36 S(M) - 0.15 1.48 CW
% % %     'Chewie','2015-07-09','VR','CO'; ... %37 S(M) ? - 30 CW
% % %     'Chewie','2015-07-10','VR','CO'; ... %38 S(M) ? - 30 CW
% % %     'Chewie','2015-07-13','VR','CO'; ... %39 S(M) ? - 30 CW
% % %     'Chewie','2015-07-14','VR','CO'; ... %40 S(M) ? - 30 CCW
% % %     'Chewie','2015-07-15','VR','CO'; ... %41 S(M) ? - 30 CCW
% % %     'Chewie','2015-07-16','VR','CO'; ... %42 S(M) ? - 30 CCW
% % %     'Chewie','2015-11-09','GR','CO'; ... %43 S(M) - 30 CCW in 120 trials
% % %     'Chewie','2015-11-10','GR','CO'; ... %44 S(M) - 30 CCW in 120 trials
% % %     'Chewie','2015-11-12','GR','CO'; ... %45 S(M) - 30 CW in 120 trials
% % %     'Chewie','2015-11-13','GR','CO'; ... %46 S(M) - 30 CCW in 240 trials
% % %     'Chewie','2015-11-16','GR','CO'; ... %47 S(M) - 30 CCW in 240 trials
% % %     'Chewie','2015-11-17','GR','CO'; ... %48 S(M) - 30 CCW in 240 trials
% % %     'Chewie','2015-11-18','GR','CO'; ... %49 S(M) - 30 CCW in 240 trials. Smaller target size.
% % %     'Chewie','2015-11-19','VR','CO'; ... %50 S(M) - 60 CCW
% % %     'Chewie','2015-11-20','GR','CO'; ... %51 S(M) - 30 CCW in 400 trials
% % %     'Chewie','2015-12-01','VR','CO'; ... %52 S(M) - 45 CCW
% % %     'Chewie','2015-12-03','VR','CO'; ... %53 S(M) - 60 CCW
% % %     'Chewie','2015-12-04','VR','CO'; ... %54 S(M) - 45 CCW
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Mihili
% % %     'Mihili','2014-01-14','VR','RT'; ...    %1  S(M+P) ? - 30 CCW
% % %     'Mihili','2014-01-15','VR','RT'; ...    %2  S(M+P) ? - 30 CCW
% % %     'Mihili','2014-01-16','VR','RT'; ...    %3  S(M+P) ? - 30 CCW
% % %     'Mihili','2014-02-14','FF','RT'; ...    %5  S(M+P) ? - 0.15 1.48 CCW
    'Mihili','2014-02-17','FF','CO'; ...    %6  S(M+P) P? - 0.15 1.48 CCW
    'Mihili','2014-02-18','FF','CO'; ...    %7  S(M+P) P? - 0.15 1.48 CCW
% % %     'Mihili','2014-02-21','FF','RT'; ...    %9  S(M+P) ? - 0.15 1.48 CCW
% % %     'Mihili','2014-02-24','FF','RT'; ...    %10 S(M+P) ? - 0.15 1.48 CCW
% % %     'Mihili','2014-03-03','VR','CO'; ...    %12 S(M+P) ? - 30 CCW
% % %     'Mihili','2014-03-04','VR','CO'; ...    %13 S(M+P) ? - 30 CCW
% % %     'Mihili','2014-03-06','VR','CO'; ...    %14 S(M+P) ? - 30 CCW
    'Mihili','2014-03-07','FF','CO'; ...    %15 S(M+P) P? - 0.15 1.48 CCW
%     'Mihili','2014-06-26','CS','CO'; ...    %16 S(M+P) ?
%     'Mihili','2014-06-27','CS','CO'; ...    %17 S(M+P) ?
%     'Mihili','2014-09-29','CS','CO'; ...    %18 S(M+P) ?
%     'Mihili','2014-12-03','CS','CO'; ...    %19 S(M)   ?
%     'Mihili','2015-05-11','CS','CO'; ...    %21 S(M+P) ?
%     'Mihili','2015-05-12','CS','CO'; ...    %22 S(M+P) ?
    'Mihili','2015-06-10','FF','CO'; ...    %23 S(M+P) P? - 0.15 1.48 CW - SHORT WASHOUT
    'Mihili','2015-06-11','FF','CO'; ...    %24 S(M+P) P? - 0.15 1.48 CCW - SHORT WASHOUT
    'Mihili','2015-06-15','FF','CO'; ...    %26 S(M+P) P? - 0.15 1.48 CW - SOMETHING SEEMED WEIRD IN PMd POPULATION BUT M1 IS GOOD... LOOK INTO THIS, MATT
    'Mihili','2015-06-16','FF','CO'; ...    %27 S(M+P) P? - 0.15 1.48 CW
% % %     'Mihili','2015-06-23','VR','CO'; ...    %29 S(M+P) ? - 30 CW
% % %     'Mihili','2015-06-25','VR','CO'; ...    %30 S(M+P) ? - 30 CW
% % %     'Mihili','2015-06-26','VR','CO'; ...    %31 S(M+P) ? - 30 CW
    'Mihili','2014-02-03','FF','CO'; ...    %4  S(M+P) ? - A fairly garbage session because he didn't complete reaches to a target
    'Mihili','2015-06-17','FF','CO'; ...    %28 S(M+P) ? - A fairly garbage session because he didn't complete reaches to a target
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Jaco
%     'Jaco','2016-04-05','FF','CO'; ... %1 S(M) - 0.15 1.48 CCW
%     'Jaco','2016-04-06','FF','CO'; ... %2 S(M) - 0.15 1.48 CCW
%     'Jaco','2016-04-07','FF','CO'; ... %3 S(M) - 0.15 1.48 CW - short-ish washout
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    }; %end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bad and questionable data
% Brain control from first implant
%     'Mihili','2015-07-03','BC','CO'; ...    %32 S(M-P) not the best session
%     'Mihili','2015-07-06','BC','CO'; ...    %33 S(M-P) not the best session
%     'Mihili','2015-07-08','BC','CO'; ...    %34 S(-P)
%     'Mihili','2015-07-10','BC','CO'; ...    %35 S(-P)
%     'Mihili','2015-07-13','BC','CO'; ...    %36
%     'Mihili','2015-07-14','BC','CO'; ...    %37
%     'Mihili','2015-07-15','BC','CO'; ...    %38
%     'Mihili','2015-07-16','BC','CO'; ...    %39
% 
% mihili_missingTargets - THESE ALL HAD ZERO SUCCESSES TO AT LEAST ONE TARGET DIRECTION FOR MOST OF FORCE. MIGHT BE USEABLE FOR SOMETHING AS OTHERWISE GOOD
% %     'Mihili','2014-02-03','FF','CO'; ...    %4  S(M-P) ? - A fairly garbage session because he didn't complete reaches to a target
% %    'Mihili','2015-12-11','FF','CO'; ...    %20 S(M-P) ? - SOMETHING SEEMS STREANGE IN BEHAVIOR. NO WASHOUT
% %     'Mihili','2015-06-12','FF','CO'; ...    %25 S(M-P) ? - SHORT WASHOUT, and a fairly garbage session because he didn't complete reaches to a target
% %     'Mihili','2015-06-17','FF','CO'; ...    %28 S(M-P) ? - A fairly garbage session because he didn't complete reaches to a target
%
% %%% Some early days. Either bad adaptation or incomplete data. Might be useful for BL though.
% mihili_good_but_different_days = 'Mihili','2014-02-24-VR','VR','RT'; ... %11 S(M-P) ? - 30 CCW - Did both perturbations
%    'Mihili','2014-02-18-VR','VR','CO'; ... %8  S(M-P) ? - 30 CCW - Did both perturbations
%
% mihili_earlyDays = {'Mihili','2013-12-02','FF','RT'; ... S(M-P)
%                     'Mihili','2013-12-07','FF','RT'; ... S(M-P)
%                     'Mihili','2013-12-08','FF','RT'; ... S(M-P)
%                     'Mihili','2013-12-12','FF','CO'; ...
% 
% mihili_iffyDays = {'Mihili','2014-01-17','VR','RT'; ... % Poor work ethic in washout, so it's really long... might be useable if needed
%     'Mihili','2014-01-20','VR','CO'};    % Adaptation period is half as short as it should be. Maybe not a total waste though
% 
% %%% ALSO A FEW PARTIAL DAYS WITH NO WASHOUT
% mihili_partialDays = {'Mihili','2014-02-11','FF','CO'; ...
%     'Mihili','2014-02-22','FF','RT'; ...
%     'Mihili','2014-02-25','VR','CO'; ...
%     'Mihili','2014-02-27','VR','CO'; ...
%     'Mihili','2014-02-28','VR','CO'; ...
%     'Mihili','2015-06-24','VR','CO'; ...
% note: 12/12 and 12/13 were the first two FF days for
% Mihili... might be worth looking at, even though they
% don't have complete data
% 
% mrt_ff_iffyDays = {'2013-08-27', ... %   RT - poor work ethic, but might be good?
%                    '2013-08-28'};    %   CO - poor work ethic, adaptation period is a bit short
% mrt_ff_badDays = {'2013-08-13', ...  % S CO - force field at 90 degrees
%                    '2013-08-14'};     % S RT - force field changed partway through
% mrt_different_but_good_days = 'MrT','2013-09-24','VRFF','RT'; ... %13 S(P) ? x - 30 CCW
%     'MrT','2013-09-25','VRFF','RT'; ... %14 S(P) ? x - 30 CCW
%     'MrT','2013-09-27','VRFF','RT'; ... %15 S(P) ? x - 30 CCW
%     'MrT','2013-10-11','VR','RT'; ...   %16 S(P) ? x - 45 CCW
%
% chewie_iffyDays = {'2013-10-17', ... % S ? RT 0.13 force mag
%                    '2013-10-18'};    %   RT 0.1 force mag
%
%
% jaco_stim_recording_days
%     'Jaco','2016-01-27','CS','CO'; ...
%     'Jaco','2016-01-28','CS','CO'; ...
%     'Jaco','2016-01-29','CS','CO'; ...
%     'Jaco','2016-02-02','CS','CO'; ...
%     'Jaco','2016-02-03','CS','CO'; ...
%     'Jaco','2016-02-04','CS','CO'; ...
%       'Jaco','2016-02-15','CS','CO'; ...
%       'Jaco','2016-02-17','CS','CO'; ...
% 'Jaco','2016-02-18','CS','CO'; ...