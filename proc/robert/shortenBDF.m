function bdfOut=shortenBDF(out_struct,newEndTime)

% skip over units for now
% out_struct.raw.analog.channels - no change
% out_struct.raw.analog.ts - no change
for n=1:length(out_struct.raw.analog.data)
    equivalentTimeVector=out_struct.raw.analog.ts{n}(1):1/out_struct.raw.analog.adfreq(n): ...
        length(out_struct.raw.analog.data{n})/out_struct.raw.analog.adfreq(n);
    out_struct.raw.analog.data{n}(equivalentTimeVector>newEndTime)=[];
end
% out_struct.raw.analog.adfreq - no change
out_struct.raw.enc(out_struct.raw.enc(:,1)>newEndTime,:)=[];
for n=1:length(out_struct.raw.events.timestamps)
    out_struct.raw.events.timestamps{n}(out_struct.raw.events.timestamps{n}>newEndTime)=[];
end
out_struct.raw.words(out_struct.raw.words(:,1)>newEndTime,:)=[];
out_struct.words(out_struct.words(:,1)>newEndTime,:)=[];
out_struct.databursts(cat(1,out_struct.databursts{:,1})>newEndTime,:)=[];
out_struct.pos(out_struct.pos(:,1)>newEndTime,:)=[];
out_struct.vel(out_struct.vel(:,1)>newEndTime,:)=[];
out_struct.acc(out_struct.acc(:,1)>newEndTime,:)=[];
out_struct.targets.centers(out_struct.targets.centers(:,1)>newEndTime,:)=[];

bdfOut=out_struct;