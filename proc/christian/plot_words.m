function plot_words(datastruct, words)
% words is an array of 1xN word values in decimal
%datastruct is a BDF Structure



%default word names, values and color for BD task
WordsNames = { 'Start' 'Touch Pad' 'Go Cue' 'Catch' 'Pick up' 'Reward' 'Abort' 'Fail' 'Incomplete' 'Empty Rack'};
WordsValues= [   25   ;     48    ;   49   ;   50  ;    144  ;   32   ;   33  ;  34  ;     35     ;     36      ];
colors =     {   'k:'      'c:'        'b:'   'm:'      'c:'   'g:'      'r:'   'r:'       'r:'        'r:'};


%extracts the words from structure to an array
numWords=length(WordsValues);
Words_ts = zeros(length(datastruct.words),numWords);
for n=1:numWords
    templen=length(datastruct.words(datastruct.words(:,2)==WordsValues(n)));
    Words_ts(1:templen,n) = datastruct.words(datastruct.words(:,2)==WordsValues(n),1);
end

%which of them do we want to plot if present
Words_to_plot=[];
for i=1:length(words)
    if ~isempty(nonzeros(Words_ts(:,i)))
        Words_to_plot = [Words_to_plot; find(WordsValues==words(i))];
    end
end
Words_to_plot = sort(Words_to_plot);

%numWords is now set to the number of words we will plot:
numWords = length(Words_to_plot);


%and plot 'em!
marker=[-2000 2000];
hold on;
for i=1:numWords
    tmpWords_ts=[nonzeros(Words_ts(:,Words_to_plot(i))) nonzeros(Words_ts(:,Words_to_plot(i)))];
    tmpmarker=[];
    for j=1:size(tmpWords_ts,1)
        tmpmarker(j,:)=marker;
    end
        words_handles(1:size(tmpWords_ts,1),i)=plot(tmpWords_ts',tmpmarker',colors{Words_to_plot(i)});
end

outh = [words_handles(1,1:numWords)'];
outm = [WordsNames(Words_to_plot)];

[leghw,objh,outh,outm]=legend(outh,outm,'Location','Northwest');

% legh(1) = leghw;
end
