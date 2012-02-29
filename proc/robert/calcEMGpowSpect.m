function [f,P05,P10]=calcEMGpowSpect(PathName)

if ~nargin
    PathName=pwd;
end
cd(PathName)
% cd('/Users/rdflint/work/Northwestern/data/analyses_outputs/EMG decoding/fp6 results unified fs')
D=dir(pwd);

files=find(cellfun(@isempty,regexp({D.name},'filtEMG'))==0);
files=files(sortCustomRegex({D(files).name},{'Chewie','Mini','Jaco','Thor'}));

fs=2000;
m=1;
for n=1:length(files)
    recordingName=regexp(D(files(n)).name,'.*(?=\.mat)','match','once');
    fprintf(1,'%s\n',recordingName)
    varName=[recordingName,'05Hz'];
    EMG5Hz{n}=load(D(files(n)).name,varName);
    EMG5Hz{n}=EMG5Hz{n}.(varName);
    varName=[recordingName,'10Hz'];
    EMG10Hz{n}=load(D(files(n)).name,varName);
    EMG10Hz{n}=EMG10Hz{n}.(varName);
    
    if nnz(cellfun(@isempty,regexp(regexprep(badEMGdays,'-',''), ...
            regexp(recordingName,'.*(?=sorted)','match','once')))==0)
        [~,badChannels]=badEMGdays;
        currBadChans=badChannels{find(cellfun(@isempty,regexp(regexprep(badEMGdays,'-',''), ...
            regexp(recordingName,'.*(?=sorted)','match','once')))==0,1)};
        EMG5Hz{n}(:,currBadChans)=[];
        EMG10Hz{n}(:,currBadChans)=[];
    end
    
    for k=1:size(EMG5Hz{n},2)
        numpts=size(EMG5Hz{n},1);
        
        Y=fft(EMG5Hz{n}(:,k));
        P=Y.*conj(Y)/numpts;
        f{m}=fs*(0:numpts/2)/numpts;
        if m>1 && length(f{m}) > length(f{m-1})
            % interpolate the power values so they can be averaged with the
            % others
            P05temp=P(2:length(f{m}));
            P05(:,m)=interp1(f{m}(2:end),P05temp,f{m-1}(2:end));
            % don't reset f{m} here because we'll need it later
        else
            P05(:,m)=P(2:length(f{m}));
        end
        
        Y = fft(EMG10Hz{n}(:,k));
        P=Y.*conj(Y)/numpts;
        if m>1 && length(f{m}) > length(f{m-1})
            P10temp=P(2:length(f{m}));
            P10(:,m)=interp1(f{m}(2:end),P10temp,f{m-1}(2:end));
            f{m}=f{m-1};
        else
            P10(:,m)=P(2:length(f{m}));
        end
        
        m=m+1;
%         sum(P(2:find(f<2,1,'last')))/sum(P(2:length(f)))
    end
end

% all rows of f should be the same!
% figure, plot(f(1,2:end),mean(P05(2:size(f,2)),2))
