
function [words,labels,rewind,rewtimes,ot,gotimes,goind] = words2COlist2(words)

labels = {'StartTrial','Reward','Abort','Fail','Incomplete','CTon','GoCue','OTon'};
%hexcodes = {'11','20','21','22','23','30','31','40'};
codes=[17 32 33 34 35 48 49]; %codes in decimal
%codes = hex2dec(hexcodes);

for i=1:length(codes)
    words(:,2+i)=0;
    idx = (words(:,2)==codes(i));
    words(idx,2+i)=1;
%     wevents{i}=words(idx,:);
end
%for OuterTargOn signals, need to use bitand
words(:,2+i+1)=0;
otidx=find(bitand(words(:,2),64));    %Find all outertarg on 
words(otidx,2+i+1)=bitand(words(otidx,2),15);         %bitanding with 15 gets the last hex digit, i.e. the Outer target number

rewind=find(words(:,4)); 
if rewind(1)<3
    rewind=rewind(2:end);
end
rewtimes=words(rewind,1);
ot=words(rewind-2,10);
goind=rewind-1;
gotimes=words(goind,1);