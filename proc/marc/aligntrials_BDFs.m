
%This function chops bdf.raw.analog and spike time vectors into trials for
%center out task

samp_fact=1000/samprate;
if ~exist('preoffset','var')
    preoffset=2500;
end
if ~exist('premove','var')
    premove=preoffset;
end
if ~exist('avelength','var')
    avelength=2*preoffset;
end

[words,labels,rewind,rewtimes,ot,gotimes,goind] = words2COlist2(bdf.raw.words);

%Now calculate movement onset
[movetimes,rewind,rewtimes]=moveonsetfromBDF(bdf.vel,gotimes,rewtimes,rewind,words,0.05,1.0);
ot2=words(rewind-2,10);  %reassign this because rewind may have changed in moveonset_cb
eventsTable=[rewtimes ot2];
ntrials=length(eventsTable);

start_time = bdf.raw.enc(1,1);
last_enc_time = bdf.raw.enc(end,1);
stop_time = floor(last_enc_time) - 1;
analog_time_base = (start_time*samprate:stop_time*samprate)/samprate;
alignvect=movetimes;
ind=1;
alind=find(analog_time_base<alignvect(1), 1, 'last' );
if isempty(alind)
    alind=-1;
end
%%
while ((alind-floor(preoffset/samp_fact))<=samprate*analog_time_base(1))
    alignvect=alignvect(2:end);              %Don't use the first ind stimuli if too close to the start of the file.
    %     nmove=nmove-1;
    rewtimes=rewtimes(2:end);
    eventsTable=eventsTable(2:end,:);
    movetimes=movetimes(2:end);
    
    ntrials=ntrials-1;
    alind=find(analog_time_base<alignvect(ind), 1, 'last' );
    ind=ind+1;
end
numfp=length(bdf.raw.analog.data);
ntrials=length(rewtimes);
fpmat=zeros(ceil(avelength/samp_fact)+1,ntrials,numfp);

%%
spikestr=struct;
for j=1:ntrials
    alind=find(analog_time_base<=alignvect(j),1,'last');
    for k=1:numfp
        fpmat(:,j,k)=bdf.raw.analog.data{k}((alind-floor(preoffset/samp_fact)):(alind+ceil((avelength-preoffset)/samp_fact)));
        spikestr(j,k).times=bdf.units(k).ts(bdf.units(k).ts>(alignvect(j)-floor(preoffset/samprate)) &...
            (bdf.units(k).ts<(alignvect(j)+ceil((avelength-preoffset)/samprate))))-alignvect(j);
    end
    
end



