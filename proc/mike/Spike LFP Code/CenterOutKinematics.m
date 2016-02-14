%% NOTES
% be careful with file length for r value across entire signal. Stuff at the end of the file may be garbage
% 150 feature brain and hand control
% 1D control
% Old hand control with ortho task and (maybe other tasks)
% smooth signals BC and HC
% R values of velocity
% do we need the same modifications to xrecon length (ie shifting spike and LFP signals)
% for hand control as used for brain control - there is no way to tell
% except that it doesn't make sense that it would because the input is not
% predicting x and y velocity(so there shouldn't be any delay in signals)
% Lost a trial somewhere


% sgolay smooth method (default 2) compare to ones already done
% Old (random walk) HC and BC - just do ???forgot what i was going to put
% get a sample of other channels (further away channels)
% Why is hand control lower than brain control?
% Is one signal silent and the other modulating? during HC
% look at hand control within the same day
% look at R between velocity

function [r, r_std] = CenterOutKinematics(out_struct,H,LFPinds,Sigdirection,SigGain, handbc, plotIt,smoothsize, spikeInds)        
close all

% [r, r_std] = CenterOutKinematics(out_struct,H,LFPinds,[2 1],[1 1],.001,1,15,spikeInds); % hand control
% [r, r_std] = CenterOutKinematics(out_struct,H,LFPinds,[2 1],[1 1],.05,1,15,spikeInds); % brain control


% reconstruct Input signal of LFP 

% for a 2-feature decoder that uses 2 different LFP bands
% LFPinds{1}: [channel1 bandStart bandEnd]
% LFPinds{2}: [channel2 bandStart bandEnd]
% Always put LFP in x direction in first cell 2 and LFP in y direction in
% cell 2

% for a 2-feature decoder that uses 1 LFP band and 1 Spike band
% spikeInds{1}: [channel unit]
% 
% SigDirection = [direction of signal 1 (LFP 1), direction of signal 2 (LFP2 or spike)]  = [x,y] =
% [1,2] or [2,1] x = 1 y =2
% SigGain = [Sig 1 Gain, Sig 2 Gain];
%handbc  = hand control or brain control file. Enter sampling rate. .001
%for hand .05 for brain
% if plotIt = 1 plot paths, if plotIt = 0 skit plot paths
% smoothsize = set smooth span
if nargin < 7
    spikeInds = [];
end


% LFP
numlags=1;
wsz=256;
smoothfeats=0;
binsize=0.05;
fpAssignScript
LFPInput=[];
fp = fp(:,fptimes>=1.0);
fptimes(fptimes<1.0)=[];
numfp=size(fp,1);
bs=binsize*samprate;    %This assumes binsize is in seconds.
numbins=floor(length(fptimes)/bs);   %Number of bins total

tic
% Calculate LMP
win=repmat(hanning(wsz),1,numfp); %Put in matrix for multiplication compatibility
tfmat=zeros(wsz,numfp,numbins,'single');
% Notch filter for 60 Hz noise
[b,a]=butter(2,[58 62]/(samprate/2),'stop');
fpf=filtfilt(b,a,double(fp)')';  %fpf is channels X samples
clear fp
for i=1:numbins
    try
        tmp=fpf(:,(bs*(i-1)+1:(bs*(i-1)+wsz)))';    %Make tmp samples X channels
        LMP(:,i)=mean(tmp',2);
        tmp=win.*tmp;
        tfmat(:,:,i)=fft(tmp,wsz);      %tfmat is freqs X chans X bins
        clear tmp
    catch                                                                               %#ok<CTCH>
        break
    end
end

clear fpf
freqs=linspace(0,samprate/2,wsz/2+1);
freqs=freqs(2:end); %remove DC freq(c/w timefreq.m)
fprintf(1,'first frequency bin at %.3f Hz\n',freqs(1))
assignin('base','freqs',freqs)
Pmat=tfmat(2:length(freqs)+1,:,:).*conj(tfmat(2:length(freqs)+1,:,:))*0.75;   %0.75 factor comes from newtimef (correction for hanning window)
% for testing, when freqs=freqs(2:end) is commented out, above.
% Pmat=tfmat(1:length(freqs)+1,:,:).*conj(tfmat(1:length(freqs)+1,:,:))*0.75;   %0.75 factor comes from newtimef (correction for hanning window)
assignin('base','Pmat',Pmat)
Pmean=mean(Pmat,3); %take mean over all times
PA=10.*(log10(Pmat)-repmat(log10(Pmean),[1,1,numbins]));
assignin('base','PA',PA)
clear Pmat

for masterLFPindex=1:length(LFPinds)  
    if LFPinds{masterLFPindex}(3)==0
        LFPInput=[LFPInput, LMP(LFPinds{masterLFPindex}(1),:)'];
    else        
        LFPInput=[LFPInput, squeeze(mean(PA((freqs>LFPinds{masterLFPindex}(2)) & ...
            (freqs<LFPinds{masterLFPindex}(3)),LFPinds{masterLFPindex}(1),:),1))];
    end    
    if smoothfeats > 0
        disp('filter LFPInput')
        LFPInput=filter(ones(1,smoothfeats)/smoothfeats,1,LFPInput);
        LFPInput(1:smoothfeats,:)=[];
    end       
end

length(LFPInput)

% Spike
x = [];
xrecon = [];
x(:,Sigdirection(1)) = LFPInput(:,1); 
if isempty(spikeInds) == 1
x(:,Sigdirection(2)) = LFPInput(:,2);
end

% Add in spike code

starttime=0;
stoptime=out_struct.meta.duration;
MinFiringRate=0; %0.5;
if isempty(spikeInds) == 0
disp('Converting BDF structure to binned data, please wait...');
binnedData = convertBDF2binned('out_struct',binsize,starttime,stoptime,5,0,MinFiringRate);
spikechannelstr = ['ee' num2str(spikeInds{1}(1,1)) 'u' num2str(spikeInds{1}(1,2))];
spikeguideInd = find(strcmp(cellstr(binnedData.spikeguide),spikechannelstr) == 1);
if isempty(spikeguideInd)
disp('Error - spike channel unavilable in binnedData.spikeguide')
end
spikebinneddata= binnedData.spikeratedata(:,spikeguideInd);
if length(spikebinneddata) > length(LFPInput)
disp('Error - Spike binned data is bigger than LFPInput - cannot reduce size of Input to spikebinneddata')
end
x = x(1:length(spikebinneddata),:); % need to make spikebinneddata the same size as LFPInput
x(:, Sigdirection(2)) = spikebinneddata;
end




figure(3) 
hold on
velxy = [];
velxy(:,1) = out_struct.vel(:,2);
velxy(:,2) = out_struct.vel(:,3);
if handbc == .001 %down sample velocity for  hand control
    plot(velxy(1:50:end,1),'r') %predicted velocity
else
   % plot(velxy(:,1)/max(velxy(:,1)),'r')
  %  plot(velxy(:,2)/max(velxy(:,2)),'g')
  plot(velxy(:,1),'r')
end

if isempty(spikeInds) == 0 && Sigdirection(2) == 1 % plot spike for x direction
%    xrecon(:,1) = x(16:end,1);
  xrecon(:,1) = x(:,1);
    plot(xrecon(:,1),'g')
%     plot(smooth(xrecon(:,1),5)*H(1,1),'b') % this does not shorten spike input
    plot(((xrecon(5:end,1)*H(5,1)+xrecon(4:end-1,1)*H(4,1)+xrecon(3:end-2,1)*H(3,1)+xrecon(2:end-3,1)*H(2,1)+xrecon(1:end-4,1)*H(1,1)))*SigGain(2),'b')   % this shortens spike input by 5 
    title('Spike Input (green) Spike Reconstructed(blue) Predicted velocity (red) in X')
else % plot LFP for x direction
%     xrecon(:,1) = zeros(length(xrecon), 1); 
%     xrecon(6:end,1) = x(1:end-20,1);
xrecon(:,1) = x(:,1);
    plot(xrecon(:,1),'g')
    plot(xrecon(:,1)*max(abs(H(:,1)))*SigGain(1),'b')
    title('LFP Input (green) LFP Reconstructed(blue) Predicted velocity (red) in X')
end

figure(4)
hold on 
if handbc == .001 %down sample velocity for  hand control
    plot(velxy(1:50:end,2),'r')
else
    plot(velxy(:,2),'r')
end

if isempty(spikeInds) == 0 && Sigdirection(2) == 2 % plot spike for y direction
%     xrecon(:,2) = x(16:end,2);
  xrecon(:,2) = x(:,2);
    plot(xrecon(:,2),'g')
    plot((xrecon(5:end,2)*H(5,2)+xrecon(4:end-1,2)*H(4,2)+xrecon(3:end-2,2)*H(3,2)+xrecon(2:end-3,2)*H(2,2)+xrecon(1:end-4,2)*H(1,2))*SigGain(2),'b')    
    title('Spike Input (green) Spike Reconstructed(blue) Predicted velocity (red) in Y')
else %plot LFP for y direction   
%    xrecon(:,2) = zeros(length(xrecon), 1);
%    xrecon(6:end,2) = x(1:end-20,2);
xrecon(:,2) = x(:,2);
    plot(xrecon(:,2),'g')
    plot(xrecon(:,2)*max(abs(H(:,2)))*SigGain(2),'b')
title('LFP Input (green) LFP Reconstructed(blue) Predicted velocity (red) in Y')
end

length(out_struct.pos)
length(xrecon)

%smooth input and plot
figure(2)
hold on
xrecon(:,1) = xrecon(:,1)/max(xrecon(:,1));
xrecon(:,2) = xrecon(:,2)/max(xrecon(:,2));
plot(xrecon(:,1),'r')
plot(xrecon(:,2),'b')
xrecon(:,1) = smooth(xrecon(:,1),smoothsize,'sgolay');
xrecon(:,2) = smooth(xrecon(:,2),smoothsize,'sgolay');
plot(xrecon(:,1),'m')
plot(xrecon(:,2),'c')
title('normalized smoothed input')






%% Plot Target Locations- ignore for now bc need something here for handcontrol because target locations are
%different than brain control. 

% sparse out movement data and input signal for each trial 
FirstTrialInds=find(out_struct.words(:,2)==17);
FirstTrialInds(end) = []; % remove last trial in case trial is cut off or short

if plotIt
figure(1)
h = fill([-2,-2,2,2],[12,8,8,12],'r');
set(h,'FaceAlpha',.3)
% hold on
p = fill([8,8,12,12],[2,-2,-2,2],'r');
set(p,'FaceAlpha',.3)
m = fill([2,2,-2,-2],[2,-2,-2,2],'r');
set(m,'FaceAlpha',.3)
axis square
% set(gca,'xlim',[-15,15])
% set(gca,'ylim',[-12,12])
ppos = plot(0,0);
hold on 
end

j = 1;
jX =1;
jY =1; 
jnegX =1;
jnegY =1;
TrialPathY ={};
TrialPathX ={};
TrialInputY ={};
TrialInputX ={};
TrialPathnegY ={};
TrialPathnegX ={};
TrialInputnegY ={};
TrialInputnegX ={};
TrialStartIndexPos = [];
TrialEndIndexPos = [];
TrialStartIndexIn = [];
TrialEndIndexIn = [];
for i = 1:length(FirstTrialInds)-1
    
    if out_struct.words(FirstTrialInds(i)+4,2) > 30 && out_struct.words(FirstTrialInds(i)+4,2) < 40 %out_struct.words(FirstTrialInds(i)+4,2) == 32 %%skip unrewarded trials
  
% [out_struct.words(FirstTrialInds(i),2) out_struct.words(FirstTrialInds(i)+1,2) out_struct.words(FirstTrialInds(i)+2,2) out_struct.words(FirstTrialInds(i)+3,2) out_struct.words(FirstTrialInds(i)+4,2)]
    

        TimeStart = vpa(out_struct.words(FirstTrialInds(i)+2,1),3); %words 64-65 indicate outer target on 
        TimeEnd = vpa(out_struct.words(FirstTrialInds(i)+4,1),3);
        
        if (handbc == .001) %handcontrol file
        TrialStartIndexPos(j) = round((TimeStart - 1)/.001);
        TrialEndIndexPos(j) = round((TimeEnd - 1)/.001);
        TrialStartIndexIn(j) = round((TimeStart - 1)/.05);
        TrialEndIndexIn(j) = round((TimeEnd - 1)/.05);
%         (TrialEndIndexPos-TrialStartIndexPos)/50
%         TrialEndIndexIn-TrialStartIndexIn
        else 
        TrialStartIndexPos(j) = round((TimeStart - 1)/.05);
        TrialEndIndexPos(j) = round((TimeEnd - 1)/.05);
        TrialStartIndexIn(j) = round((TimeStart - 1)/.05);
        TrialEndIndexIn(j) = round((TimeEnd - 1)/.05);
        end
        
        if TrialEndIndexPos(j) > length(out_struct.pos);  %% can probably add in TrialEndIndexIn > length(Input) as another check. 
            continue
        else
        TrialPath{j} = out_struct.pos(TrialStartIndexPos(j):TrialEndIndexPos(j),:);
        TrialInput{j} = xrecon(TrialStartIndexIn(j):TrialEndIndexIn(j),:);
        end
        
%         clear Time* TrialStartIndex TrialEndIndex
        
%         if round(out_struct.targets.corners(i,2)) == 8
          if round(out_struct.words(FirstTrialInds(i)+2,2)) == 64 || round(out_struct.words(FirstTrialInds(i)+2,2)) == 66 %down == 66 % words 64 = target position UP
                                %if 1D in Y change this to 64 and 65 and
                                %put dummy values in x
             if plotIt
                 figure(1)
                plot(TrialPath{j}(:,2),TrialPath{j}(:,3),'b') % use to plot all trials
             end
                TrialPathY{jY} = out_struct.pos(TrialStartIndexPos(j):TrialEndIndexPos(j),:);
                TrialInputY{jY} = xrecon(TrialStartIndexIn(j):TrialEndIndexIn(j),:);
                jY = jY+1;
%           set(ppos,'Xdata',TrialPath{j}(:,2),'Ydata',TrialPath{j}(:,3),'Color','b') %use to scan though trials
          elseif round(out_struct.words(FirstTrialInds(i)+2,2)) == 65 || round(out_struct.words(FirstTrialInds(i)+2,2)) == 67 % words 65 = target position RIGHT or = 67 to the LEFT
                                %if 1D in X change this to 64 and 65
                                %put dummy values in y
             if plotIt
                 figure(1)
                plot(TrialPath{j}(:,2),TrialPath{j}(:,3),'r') % use to plot all trials
             end
             
                TrialPathX{jX} = out_struct.pos(TrialStartIndexPos(j):TrialEndIndexPos(j),:);
                TrialInputX{jX} = xrecon(TrialStartIndexIn(j):TrialEndIndexIn(j),:);
                jX = jX+1;
%           set(ppos,'Xdata',TrialPath{j}(:,2),'Ydata',TrialPath{j}(:,3),'Color','k') %use to scan though trials

           elseif round(out_struct.words(FirstTrialInds(i)+2,2)) == 66 % words 65 = target position RIGHT or = 67 presumably to the LEFT
                
                if plotIt
                 figure(1)
                plot(TrialPath{j}(:,2),TrialPath{j}(:,3),'c') % use to plot all trials
                end
                
                TrialPathnegY{jnegY} = out_struct.pos(TrialStartIndexPos(j):TrialEndIndexPos(j),:);
                TrialInputnegY{jnegY} = xrecon(TrialStartIndexIn(j):TrialEndIndexIn(j),:);
                jnegY = jnegY+1;
%           set(ppos,'Xdata',TrialPath{j}(:,2),'Ydata',TrialPath{j}(:,3),'Color','k') %use to scan though trials
           elseif round(out_struct.words(FirstTrialInds(i)+2,2)) == 67 % words 65 = target position RIGHT or = 67 presumably to the LEFT
                if plotIt
                 figure(1)
                plot(TrialPath{j}(:,2),TrialPath{j}(:,3),'m') % use to plot all trials
                end
                
                TrialPathnegX{jnegX} = out_struct.pos(TrialStartIndexPos(j):TrialEndIndexPos(j),:);
                TrialInputnegX{jnegX} = xrecon(TrialStartIndexIn(j):TrialEndIndexIn(j),:);
                jnegX = jnegX+1;
%           set(ppos,'Xdata',TrialPath{j}(:,2),'Ydata',TrialPath{j}(:,3),'Color','k') %use to scan though trials
          end          
          
          
          
%         figure(2)
%             plot(TrialInput{j}(:,1),TrialInput{j}(:,2),'k.') % use to plot all trials
%         hold on
%         pause(2) % use to plot all trials


        j = j+1;
    else
        %fprintf('Trial Excluded\n')
        
    end
end
fprintf('Number of Trials = %3.0f \n', j-1)
fprintf('Number of Trials = %3.0f \n', jX-1)
fprintf('Number of Trials = %3.0f \n', jY-1)
%% Average correlation coefficient across all trials 
for j = 1:length(TrialPath)
    [rtrialpath(j),p] = corr(TrialPath{j}(:,2),TrialPath{j}(:,3));
    [rtrialinput(j),p] = corr(TrialInput{j}(:,1),TrialInput{j}(:,2));
end
fprintf('Average R across trials - Predicted Position = %6.4f +- %4.2f \n',mean(rtrialpath) ,std(rtrialpath))
fprintf('Average R across trials - Input Signals = %6.4f +- %4.2f \n',mean(rtrialinput) ,std(rtrialinput))
%% Correlation across all trials concatenated
TrialPathCat=cat(1,TrialPath{:});
[rtrialpathcat,p] = corr(TrialPathCat(:,2),TrialPathCat(:,3));
fprintf('Average R across trials - Predicted Position Concatenated = %6.4f \n',rtrialpathcat)
TrialInputCat=cat(1,TrialInput{:});
[rtrialinputcat,p] = corr(TrialInputCat(:,1),TrialInputCat(:,2));
fprintf('Average R across trials - Input Signals Concatenated = %6.4f \n',rtrialinputcat)
% figure; plot(TrialInputCat(:,1),TrialInputCat(:,2));
%% Average correlation coefficient across trials separated by direction.  
%
if isempty(TrialPathX) == 0
for j = 1:length(TrialPathX)
    [rtrialpathX(j),p] = corr(TrialPathX{j}(:,2),TrialPathX{j}(:,3));
    [rtrialinputX(j),p] = corr(TrialInputX{j}(:,1),TrialInputX{j}(:,2));
end
fprintf('Average R across trials - Predicted Position in X Direction = %6.4f +- %4.2f \n',mean(rtrialpathX) ,std(rtrialpathX))
fprintf('Average R across trials - Input Signals in X Direction = %6.4f +- %4.2f \n',mean(rtrialinputX) ,std(rtrialinputX))
TrialPathCatX=cat(1,TrialPathX{:});
[rtrialpathcatX,p] = corr(TrialPathCatX(:,2),TrialPathCatX(:,3));
fprintf('Average R across trials - Predicted Position Concatenated in X Direction = %6.4f \n',rtrialpathcatX)
TrialInputCatX=cat(1,TrialInputX{:});
[rtrialinputcatX,p] = corr(TrialInputCatX(:,1),TrialInputCatX(:,2));
fprintf('Average R across trials - Input Signals Concatenated in X Direction= %6.4f \n',rtrialinputcatX)
else
    rtrialpathX = NaN;
    rtrialinputX = NaN;
end
%
if isempty(TrialPathY) == 0
for j = 1:length(TrialPathY)
    [rtrialpathY(j),p] = corr(TrialPathY{j}(:,2),TrialPathY{j}(:,3));
    [rtrialinputY(j),p] = corr(TrialInputY{j}(:,1),TrialInputY{j}(:,2));
end    
fprintf('Average R across trials - Predicted Position in Y Direction = %6.4f +- %4.2f \n',mean(rtrialpathY) ,std(rtrialpathY))
fprintf('Average R across trials - Input Signals in Y Direction = %6.4f +- %4.2f \n',mean(rtrialinputY) ,std(rtrialinputY))
TrialPathCatY=cat(1,TrialPathY{:});
[rtrialpathcatY,p] = corr(TrialPathCatY(:,2),TrialPathCatY(:,3));
fprintf('Average R across trials - Predicted Position Concatenated in Y Direction = %6.4f \n',rtrialpathcatY)
TrialInputCatY=cat(1,TrialInputY{:});
[rtrialinputcatY,p] = corr(TrialInputCatY(:,1),TrialInputCatY(:,2));
fprintf('Average R across trials - Input Signals Concatenated in Y Direction= %6.4f \n',rtrialinputcatY)
else
    rtrialpathY = NaN;
    rtrialinputY = NaN;
end
% plot input 1 vs input 2
figure; TrialInputCat=cat(1,TrialInput{:});
plot(TrialInputCat(:,1),'r'); hold on
plot(TrialInputCat(:,2),'b');
title('Input 1 vs. Input 2 movement concatenated')
% plot(TrialInputCatX(:,1),TrialInputCatX(:,2),'r.'); hold on
% plot(TrialInputCatY(:,1),TrialInputCatY(:,2),'b.');
if isempty(TrialInputnegY) == 0
TrialInputCatnegY=cat(1,TrialInputnegY{:});
TrialInputCatnegX=cat(1,TrialInputnegX{:});
plot(TrialInputCatnegX(:,1),TrialInputCatnegX(:,2),'m.'); hold on
plot(TrialInputCatnegY(:,1),TrialInputCatnegY(:,2),'c.');
end

axis square
% axis([-80 80 -8 8])
%  plot([0 80], [0 0],'r')
% plot([0 0], [0 8],'b')

%% Calculate R accross entire file (technically from start of 1st trial to end of the last file - note: can't do this for random walk 
xreconreducesize = [xrecon(TrialStartIndexIn(1):TrialEndIndexIn(end),1) xrecon(TrialStartIndexIn(1):TrialEndIndexIn(end),2)];
TrialStartIndexIn(1)
TrialEndIndexIn(end)
figure; 
plot(xreconreducesize(:,1),'r'); hold on
plot(xreconreducesize(:,2),'b');
[rinput,p] = corr(xreconreducesize(:,1),xreconreducesize(:,2));
posXYreducesize(:,1) = out_struct.pos(TrialStartIndexPos(1):TrialEndIndexPos(end),2); 
posXYreducesize(:,2) = out_struct.pos(TrialStartIndexPos(1):TrialEndIndexPos(end),3); 
TrialStartIndexPos(1)
TrialEndIndexPos(end)
title('Input 1(r) and Input 2(b) normalized smooth reduced')
figure(7);
plot(posXYreducesize(:,1),'m'); hold on
plot(posXYreducesize(:,2),'c');
[rpath,p] = corr(posXYreducesize(:,1),posXYreducesize(:,2));
title('x(r) and y(b) reduced')


%% Calculate R across entire file for Random Walk - 
% use if you don't want to cut off the first part or last part of the file.
% 
figure; 
plot(xrecon(:,1),'r'); hold on
plot(xrecon(:,2),'b');
[rinput,p] = corr(xrecon(:,1),xrecon(:,2));
posXY(:,1) = out_struct.pos(:,2); 
posXY(:,2) = out_struct.pos(:,3); 
title('Input 1(r) and Input 2(b) normalized smooth reduced')
figure(7);
plot(posXY(:,1),'m'); hold on
plot(posXY(:,2),'c');
[rpath,p] = corr(posXY(:,1),posXY(:,2));
title('x(r) and y(b) reduced')



% For easier copy and paste into excel (copy from variable editor)
r = [rpath mean(rtrialpath) mean(rtrialpathX) mean(rtrialpathY) rinput mean(rtrialinput) mean(rtrialinputX) mean(rtrialinputY)];
r_std  = [0 std(rtrialpath) std(rtrialpathX) std(rtrialpathY) 0 std(rtrialinput) std(rtrialinputX) std(rtrialinputY)];