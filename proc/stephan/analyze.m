
%% load paths

% addpath(genpath('D:\My Documents\Uni\Master\Delft\stage\inhoud\s1_analysis\')) % this adds s1_analysis and all subfolders to matlab search path.

run('D:\My Documents\Uni\Master\Delft\stage\inhoud\s1_analysis\load_paths')

% \\citadel.physiology.northwestern.edu\data\Kramer_10I1\BumpDirection

%% files: 
% get_cerebus_data(filename (and path), labnumber) (needs files in same folder, is in s1_analysis\bdf)
% bc_psychometric_curve (needs more files in s1_analysis\proc\brian)
% 
% get_plexon_data; makes bdf of .plx file.

%% make bdf
% file_behav = 'D:\My Documents\Uni\Master\Delft\stage\inhoud\data\Kramer_bump_direction_005.nev';
% data_nev = get_cerebus_data(file_behav,3);

% bc_psychometric_curve(data);
% todo: make plot of psychometric curve give labels; dl -> lower -> x
% lower bump

% file_neuro = '\\citadel.physiology.northwestern.edu\data\Mini_7H1\Nick Datafiles\SD\05-09-2012\Mini_Spike_LFPL_05092012004.plx';
file_neuro = 'D:\My Documents\Uni\Master\Delft\stage\inhoud\data\Kramer_RW_neural_001-ns_01.nev';
data = get_cerebus_data(file_neuro,3);

% file_neuro = 'D:\My Documents\Uni\Master\Delft\stage\inhoud\data\Mini_Spike_LFPL_04102012001.plx';
% data_plx = get_plexon_data(file_neuro); % this crashes, apparently due to
% plexon and matlab 2010 glitch

%%
% data_plx =
% load('\\citadel.physiology.northwestern.edu\data\Chewie_8I2\BDFs\09-07-2012\Chewie_Spike_LFP_09072012007')
% % dosn't work

% load('\\citadel.physiology.northwestern.edu\data\Mini_7H1\bdf\09-06-2012\Mini_Spike_LFPL_09062012006')
% % comes in out_struct
% load('D:\My Documents\Uni\Master\Delft\stage\inhoud\data\Tiki_RW_008') % comes in bdf

% once in bdf format:
[pds, errs, moddepth] = glm_pds(data,1); 
 % for this to work the file trains2bin_mex.c should be compiled
 % In command window; type:
 % mex trains2bin_mex 
 % you have to have current folder where that file is.


 
 %% shuffle timestamps and pos/vel vectors, see if same pds come out
 
%  bdf2 = out_struct;
%  shuffle = randperm(length(bdf2.pos));
%  bdf2.pos = bdf2.pos(shuffle,:)
%  bdf2.vel = bdf2.vel(shuffle,:)
[pds1, errs1, moddepth1] = glm_pds_S(out_struct); 

% conclusion: pds exactly the same.
 
 %% need to find from PD's most similar. and pref also most similar with opposites.
 num_elecs = 12; % number of electrodes in array, left to right.
%  pds_unwrp = unwrap(pds); % unwrap doesn't work here
 pd_round = round(pds*10)/10; % round to first decimal
%  pd_round(:,2) = 1:length(pd_round); % this puts a second column next to
%  the first column, the second containing the row number
% u1 = unit_list(out_struct); % gets two columns back, first with channel
% numbers, second with unit sort code on that channel
% pd_round(:,2) = u1(:,1); % puts corresponding channel number next to PD

 pd_matrix = vec2mat(pd_round,num_elecs); % makes a matrix out of the vector
 pd_matrix_helper = fliplr(pd_matrix); % flips so that we can have elements in matrix corresponding to 2D array orientation (at least if the output from glm_pds is what I assume it is; PDs for each channel)
 for i=2:2:length(pd_matrix(:,1))
     pd_matrix(i,:)=pd_matrix_helper(i,:);
 end
 
 %% plotting
 figure, surface(pd_matrix);
 h_axes = get(gcf,'CurrentAxes');
 set(h_axes,'YTickLabel',{'A','B','C','D','E','F','G'}) % set one axis to have letters instead of number as labels
%  set(gcf,'CurrentAxes',axes_handle) % gcf : get current figure handle (if latest figure is figure 2, than gcf = 2. if >>figure(1) then gcf = 1;
%  set(gca,'XTickLabel',{'A','B','C','D','E','F','G'})
 
 % idee: vector reshape / permute / vec2mat sodat dit 'n matrix is waar in
 % die elemente in die matrix so langs mekaar lê soos die electrodes
 % waarmee mens record. Dan kan jy surface plot doen, of uit daai matrix
 % die elemente selecteer wat meeste similar PD's het.
 

%% polar, jbfill; crappy with large errors

u1 = unit_list(out_struct); % gets two columns back, first with channel
% ID numbers, second with unit sort code on that channel

r = 0.01:0.01:1;
angle = repmat(pds(31),1,length(r));
err_up = angle+repmat(errs(31),1,length(r));
err_down = angle-repmat(errs(31),1,length(r));

figure, h1 = polar(angle,r);
hold on
h2 = polar(err_up,r);
h3 = polar(err_down,r);
set(h1,'linewidth',3);
[x1,y1]=pol2cart(err_up,r);
[x2,y2]=pol2cart(err_down,r);
jbfill(x1,y1,y2,'b','b',1,0.2);
title(sprintf(['Elec ' u1(31,1)]))

%% polar, fill, try out.

u1 = unit_list(out_struct); % gets two columns back, first with channel
% ID numbers, second with unit sort code on that channel

r = 0.01:0.01:1;
angle = repmat(pds(31),1,length(r));
err_up = angle+repmat(errs(31),1,length(r));
err_down = angle-repmat(errs(31),1,length(r));

figure, h1 = polar(angle,r);
hold on
h2 = polar(err_up,r);
h3 = polar(err_down,r);
set(h1,'linewidth',3);
[x1,y1]=pol2cart(angle,r);
[x2,y2]=pol2cart(err_up,r);
[x3,y3]=pol2cart(err_down,r);
x_fill = [x2(end), x1(end), x3(end), 0];
y_fill = [y2(end), y1(end), y3(end), 0];
% fill(x_fill,y_fill,'r');
patch(x_fill,y_fill,'b','facealpha',0.3);
title(sprintf(['Elec ' num2str(u1(31,1))]))

%% polar, fill, color, try out.

u1 = unit_list(out_struct); % gets two columns back, first with channel
% ID numbers, second with unit sort code on that channel

r = 0.01:0.01:1;
angle = repmat(pds(31),1,length(r));
err_up = angle+repmat(errs(31),1,length(r));
err_down = angle-repmat(errs(31),1,length(r));

% linspace(min(moddepth),max(moddepth),10)

% if moddepth(31)
% 
% if pds(31)<pi/2
%     color = [1 0 0];

figure, h1 = polar(angle,r);
hold on
h2 = polar(err_up,r);
h3 = polar(err_down,r);
set(h1,'linewidth',3);
set(h1,'color',color)
[x1,y1]=pol2cart(angle,r);
[x2,y2]=pol2cart(err_up,r);
[x3,y3]=pol2cart(err_down,r);
x_fill = [x2(end), x1(end), x3(end), 0];
y_fill = [y2(end), y1(end), y3(end), 0];
% fill(x_fill,y_fill,'r');
patch(x_fill,y_fill,'b','facealpha',0.3);
title(sprintf(['Elec ' num2str(u1(31,1))]))

%% polarhg, doesn't work very well.

r = 0.01:0.01:1;
angle = repmat(pds(50),1,length(r));
err_up = angle+repmat(errs(50),1,length(r));
err_down = angle-repmat(errs(50),1,length(r));

figure, h1 = polarhg(angle,r,'tstep',15);
hold on
h2 = polarhg(err_up,r,'tstep',15);
h3 = polarhg(err_down,r,'tstep',15);
set(h1,'linewidth',3);
[x1,y1]=pol2cart(err_up,r);
[x2,y2]=pol2cart(err_down,r);
jbfill(x1,y1,y2,'b','b',1,0.2);


%% histograms of PDs, confidence intervals and moddulation depths
figure('name','95% CI'); 
hist(abs(errs*180/pi)*1.96*2,30)
xlabel('degrees')
ylabel('PD counts')
title('Histogram of 95% confidence intervals on PDs')
figure('name','PDs')
hist(pds*180/pi,30)
xlabel('degrees')
ylabel('PD counts')
title('Histogram of PDs')
figure('name','modulation depth')
hist(moddepth,30)
xlabel('sqrt(a^2+b^2) where a and b are the GLM weights on x and y velocity')
ylabel('PD counts')
title('Histogram of PD modulation depth')

%% PD map plot. 
% This plots polar plots showing the PDs and errorbounds in the location of their respective channels

r = 0.01:0.01:1;
chan_list = randperm(96); % electrode mapping example: list of channel IDs sorted to their location. I assume channel ID's from unit_list match these. also that array is 8x12
% num_elecs = 12; % number of electrodes in array, left to right.
% chan_mat = vec2mat(chan_list,num_elecs); % matrix of channels
% chan_mat_helper = fliplr(chan_mat); % flips so that we can have elements in matrix corresponding to 2D array orientation (at least if the output from glm_pds is what I assume it is; PDs for each channel)
% for i=2:2:length(chan_mat(:,1)) % reorganizes matrix so that it is ordered the way I think it is, 1st row left-right, 2nd right-left etc.
%      chan_mat(i,:)=chan_mat_helper(i,:);
% end

u1 = unit_list(bdf,1); % gets two columns back, first with channel
% numbers, second with unit sort code on that channel

figure
for iPD = 1:length(u1(:,1))
    angle = repmat(pds(iPD),1,length(r)); % vector size (1,length(r)) of elements equal to each preferred direction
    err_up = angle+repmat(errs(iPD),1,length(r)); % upper error bound
    err_down = angle-repmat(errs(iPD),1,length(r)); % lower error bound
    
    subplot(8,12,find(chan_list == u1(iPD,1),1,'first')) % put the plot in the correct location relative to position in array ( [ 1 2 3;..
                                                                                                                               % 4 5 6 ]; )
    h1 = polar(angle,r);
    hold on
    h2 = polar(err_up,r);
    h3 = polar(err_down,r);
    set(h1,'linewidth',3);
    [x1,y1]=pol2cart(angle,r); 
    [x2,y2]=pol2cart(err_up,r);
    [x3,y3]=pol2cart(err_down,r);
    
%     jbfill(x1,y1,y2,'b','b',1,0.5);
x_fill = [x2(end), x1(end), x3(end), 0];
y_fill = [y2(end), y1(end), y3(end), 0];

% fill(x_fill,y_fill,'r');
patch(x_fill,y_fill,'b','facealpha',0.3);
    title(['Elec ' num2str(u1(iPD,1))])
end

 
% for iFig = 1:length(u1)
%     figure
    
 
 
 
 
 
 
 