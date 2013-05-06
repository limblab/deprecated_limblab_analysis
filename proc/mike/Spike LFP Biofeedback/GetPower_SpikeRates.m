function [PA, yLFP, PosLFP, x, ySpike, PosSpike] = GetPower_SpikeRates(sig, signal, numfp,binsize, folds,numlags,numsides,samprate,fp,fptimes,analog_times,fnam,varargin)
% Function solely to calculate power and spike rate, adopted from original
% predictions code.  Also Outputs interpolated pos and vel for spikes and LFPs

tic
if length(varargin)>0
    wsz=varargin{1};
    if length(varargin)>1
        nfeat=varargin{2};
        if length(varargin)>2
            PolynomialOrder=varargin{3};    %for Wiener Nonlinear cascade
            if length(varargin)>3
                Use_Thresh=varargin{4};
                if length(varargin)>4
                    if ~isempty(varargin{5})
                        H=varargin{5};
                        if length(varargin)>5
                            words=varargin{6};
                            if length(varargin)>6
                                emgsamplerate=varargin{7};
                                if length(varargin)>7
                                    lambda=varargin{8};
                                    if length(varargin)>8
                                        smoothfeats=varargin{9};
                                        if length(varargin)>9
                                            bdf = varargin{10};
                                            if length(varargin)>10
                                                binsize = varargin{11};
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    else
                        words=varargin{6};
                        if length(varargin)>6
                            emgsamplerate=varargin{7};
                            if length(varargin)>7
                                lambda=varargin{8};
                                if length(varargin)>8
                                    smoothfeats=varargin{9};
                                    if length(varargin)>9
                                        bdf = varargin{10};
                                        if length(varargin)>10
                                            binsize = varargin{11};
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            else
                Use_Thresh=0;
            end
        else
            PolynomialOrder=0;
            Use_Thresh=0;
        end
        %         words=varargin{3};
    end
end
if ~exist('smoothfeats','var')
    smoothfeats=0;  %default to no smoothing
end


if (strcmpi(signal,'vel') || (strcmpi(signal,'pos')) || (strcmpi(signal,'acc')))
    y=sig(:,2:3);
    PosLFP = bdf.pos(:,2:3);
else
    y=sig;
end
samp_fact=1000/samprate;
%% Adjust the size of fp to make sure same number of samples as analog
%% signals

disp('fp adjust')
toc
tic
bs=binsize*samprate;    %This assumes binsize is in seconds.
numbins=floor(length(fptimes)/bs);   %Number of bins total
binsamprate=floor(1/binsize);   %sample rate due to binning (for MIMO input)
if ~exist('wsz','var')
    wsz=256;    %FFT window size
end

%MRS modified 12/13/11
% Using binsize ms bins
if fptimes(end)~= analog_times(end,1)
    stop_time = min(analog_times(end,1),fptimes(end));
    fptimesadj = analog_times(1):1/samprate:stop_time;
    
    %          fptimes=1:samp_fact:length(fp);
    if fptimes(end)>stop_time   %If fp is longer than stop_time( need this because of
        % get_plexon_data silly way of labeling time vector)
        fpadj=interp1(fptimes,fp',fptimesadj);
        fp=fpadj';
        %         clear fpadj
        numbins=floor(length(fptimes)/bs);
    end
end

t = analog_times(1):binsize:analog_times(end);


while ((numbins-1)*bs+wsz)>length(fp)
    numbins=numbins-1;  %if wsz is much bigger than bs, may be too close to end of file
end

%Align numbins correctly
if length(t)>numbins
    t=t(1:numbins);
end
%     y = [interp1(bdf.vel(:,1), y(:,1), t); interp1(bdf.vel(:,1), y(:,2), t)]';
% if size(y,2)>1
if t(1)<analog_times(1)
    t(1)=analog_times(1);   %Do this to avoid NaNs when interpolating
end

y = interp1(analog_times, y, t);% This should work for all numbers of outputs
% as long as they are in columns of y
PosLFP = interp1(analog_times, PosLFP, t);

if size(y,1)==1
    y=y(:); %make sure it's a column vector
end
% else
%     y=interp1(analog_times, y(:,1), t)';    %Must be a column vector
% end
% filter out inactive regions
% Find active regions
if exist('words','var') && ~isempty(words)
    q = find_active_regions_words(words,analog_times);
else
    q=ones(1,length(analog_times));   % Temp kludge b/c find_active_regions gives
    % too long of a vector back
end

q = interp1(analog_times, q, t);

disp('2nd part:assign t,y,q')
toc
%LMP=zeros(numfp,length(y));

tic
%% Calculate LMP
win=repmat(hanning(wsz),1,numfp); %Put in matrix for multiplication compatibility
tfmat=zeros(wsz,numfp,numbins,'single');
%% Notch filter for 60 Hz noise
[b,a]=butter(2,[58 62]/(samprate/2),'stop');
fpf=filtfilt(b,a,fp')';  %fpf is channels X samples
clear fp
itemp=1:10;
firstind=find(bs*itemp>wsz,1,'first');
for i=1:numbins
    ishift=i-firstind+1;
    if ishift<=0
        continue
    elseif ishift == 1
        LMP=zeros(numfp,length(y)-firstind+1);
    end
    %     LMP(:,i)=mean(fpf(:,bs*(i-1)+1:bs*i),2);
    tmp=fpf(:,(bs*i-wsz+1:bs*i))';    %Make tmp samples X channels
    LMP(:,ishift)=mean(tmp',2);
    %     tmp=tmp-repmat(mean(tmp,1),wsz,1);
    %     tmp=detrend(tmp);
    tmp=win.*tmp;
    tfmat(:,:,ishift)=fft(tmp,wsz);      %tfmat is freqs X chans X bins
    clear tmp tftmp
end
%Now need to clean up tfmat to account for cutting off the firstind bins
tfmat(:,:,(ishift+1:end))=[];
numbins=numbins-firstind+1;

% t=t(1:numbins-firstind+1);
t=t(1:numbins);
y(ishift+1:end,:)=[];
PosLFP(ishift+1:end,:)=[];
yLFP = y;

q(:,ishift+1:end)=[];
clear fpf
freqs=linspace(0,samprate/2,wsz/2+1);
freqs=freqs(2:end); %remove DC freq(c/w timefreq.m)
tvect=(firstind:numbins)*(bs)-bs/2;

disp('3rd part: calculate FFTs')
toc
tic
%% Calculate bandpower
% remove DC component of frequency vector
Pmat=tfmat(2:length(freqs)+1,:,:).*conj(tfmat(2:length(freqs)+1,:,:))*0.75;
%0.75 factor comes from newtimef (correction for hanning window)

% Pmean=mean(Pmat,3); %take mean over all times
% instead of taking the mean over all times, calculate a running average
% (more similar to how BrainReader does it).  To use filter, must rearrange
% so that time is the first dimension
% Pmean=shiftdim(Pmat,2);
% now shift back to original dimensions
Pmean=mean(Pmat,3); %take mean over all times
PA=10.*(log10(Pmat)-repmat(log10(Pmean),[1,1,numbins]));
clear Pmat

%% Calculate spike rates
cells = unit_list(bdf);

binsamprate=floor(1/binsize);
% Using binsize ms bins

if strcmpi(signal,'vel') ||  strcmpi(signal, 'pos') ||  strcmpi(signal, 'acc')
    t = bdf.vel(1,1):binsize:bdf.vel(end,1);
end


y = bdf.vel(:,2:3);
PosSpike = bdf.pos(:,2:3);


ySpike = [interp1(bdf.vel(:,1), y(:,1), t); interp1(bdf.vel(:,1), y(:,2), t)]';
PosSpike = [interp1(bdf.vel(:,1), PosSpike(:,1), t); interp1(bdf.vel(:,1), PosSpike(:,2), t)]';
y = [interp1(bdf.vel(:,1), y(:,1), t); interp1(bdf.vel(:,1), y(:,2), t)]';

x = zeros(length(y), length(cells));
for i = 1:length(cells)
    if cells(i,1) ~= 0
        ts = get_unit(bdf, cells(i, 1), cells(i, 2));
        b = train2bins(ts, t);
        x(:,i) = b;
    else
        x(:,i) = zeros(length(y),1);
    end
end



end
