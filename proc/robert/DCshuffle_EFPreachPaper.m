function Cmat=DCshuffle_EFPreachPaper(str,resetRand)

% syntax Cmat=DCshuffle_EFPreachPaper(str,resetRand);
%
%       str is the file to load

if nargin>1 && resetRand==1
    disp('resetting seed on random number generator...')
    % reset random number generator
    s=RandStream.getDefaultStream;
    reset(s);
    % Reset randstream to ensure the same random sequence 
    % for trials each time this function is run
    RandStream.setDefaultStream(s);
    clear s ans
end

% load in desired info, set other values to defaults.
% str=['/Volumes/limblab/user_folders/Robert/data/monkey/Reach paper/Targpred/',...
%     'ChewieSpikeLFP010 discreteclass2nr4 anova lda analysis 7bins -0.2-0.5sec.mat'];
load(str,'eventsTable','FW','nfeat')
if exist('nfeat','var')~=1
    nfeat=4:2:(length(FW)+1)*2;
end
folds=10;           % a guess


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% shuffle the events table. %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eventsTable(:,2)=eventsTable(randperm(size(eventsTable,1)),2);

% First need to convert labels to '0,1,2,3,4 etc';
targs=unique(eventsTable(:,2));
ntargs=numel(targs);
%         prior=zeros(ntargs,1);
prior=ones(ntargs,1)/ntargs;
labels=eventsTable(:,2);
L=ones(size(labels));
for n=1:ntargs
    if exist('revflag','var')&& strcmpi(revflag,'r')
        L(labels==targs(n))=mod(n+1,ntargs)+1;  %For REVERSE task files, switch targets (rats)
        %NOTE: Old breadboard words went R,L,U,D for 6,22,38,54,
        %respectively.
    else
        L(labels==targs(n))=n;  %use 1-4
    end
    %             prior(n)=sum(labels==targs(n))/length(labels); %prior
    %             probability of entire data set
end
%If 1st target is 0 (for monkey data), add 1 to keep compatibility with lda classifier requirements
if ~all(L)
    L=L+1;  
end

% from feature selection section.  Rest of the lines are cut.
M=floor(length(eventsTable)/folds);

% from classification section.  
params=cell(numel(nfeat),folds);
ctrain=params;
posttrain=params;
posttest=params;
shufInds=randperm(length(L)); %Shuffled indices to help with sequential locations in MG
fprintf(1,'number of features ')
for i = 1:numel(nfeat)
    fprintf('%d,',nfeat(i))
    for j=1:folds
        testInds=false(length(L),1);
        testInds(shufInds(((j-1)*M+1):j*M)) = 1;
        trainInds = ~testInds;
        % Now train the classifier
        if isempty(params{i,j})
            [params{i,j},ctrain{i,j},posttrain{i,j}]=...
                lda(FW{i}(trainInds,:),L(trainInds),prior,'ml');            
        end
        %Now classify results
        [predout{i}(:,j),posttest{i,j}] = classify(params{i,j}, FW{i}(testInds,:));
        realout{i}(:,j)=L(testInds);
        cr(i,j) = sum((predout{i}(:,j) == realout{i}(:,j)))./length(predout{i}(:,j));
    end %for j
    MeanPA(i)=mean(cr(i,:));
    SDPA(i)=std(cr(i,:));
    % subtract 1 because confmat_mws is based on 0-(ntargs-1) scale
    [Cmat{i},p1off{i}]=confmat_mws(predout{i}-1,realout{i}-1); 
    drawnow
end %for i
fprintf(1,'\n')
% only keep Cmat associated with 40 features since that was what was in the
% paper
Cmat=Cmat{nfeat==40};
% assignin('base','cr',cr)
% assignin('base','predout',predout)
% assignin('base','realout',realout)
% disp('done')