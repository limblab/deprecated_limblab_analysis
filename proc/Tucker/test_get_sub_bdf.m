%test script for get_sub_bdf

%bdf must already be loaded into workspace
%will return a bdf containing only the data from go cue to end of trial

%clear old variables:
clear timestamps
clear temp
clear tempend
clear word_go
clear go_cues
clear word_end
clear end_words


%get list of go cues
word_go = hex2dec('31');
go_cues = bdf.words(bdf.words(:,2) == word_go, 1);
%exclude timestamps before 1s since getcerebusdata excludes kinematics
%before 1s
go_cues=go_cues(go_cues>1);
%get list of end words
word_end = hex2dec('20');
end_words = bdf.words( bitand(hex2dec('f0'),bdf.words(:,2)) == word_end, 1);
%compose list of complete trials
timestamps=[];
for i=1:length(go_cues)-1
    temp=find((go_cues(i)<end_words & end_words<go_cues(i+1)),1,'first');
    tempend=end_words(temp);
    if ~isempty(tempend)
        timestamps=[timestamps;go_cues(i),tempend];
    end
end
temp=find(go_cues(end)<end_words,1,'first');
tempend=end_words(temp);
if ~isempty(tempend)
    timestamps=[timestamps;go_cues(end),tempend];
end
%get sub-bdf using found times
[sub_bdf]=get_sub_bdf(bdf,timestamps);
