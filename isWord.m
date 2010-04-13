function r = isWord(word, type)

w.Start = hex2dec('10');

w.End_Code = hex2dec('20');
w.Reward = hex2dec('20');
w.Abort = hex2dec('21');
w.Failure = hex2dec('22');
w.Incomplete = hex2dec('23');

% end_words = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 1);
w.Touch_Pad = hex2dec('30');
w.Go_Cue = hex2dec('31');
w.Catch = hex2dec('32');

w.Pickup = hex2dec('90');

switch lower(type)
    case 'starttrial'
        r = bitand(hex2dec('f0'),word(:,2)) == w.Start;
    case 'Go'
        r = word(:,2) == w.Go_Cue;
    case 'reward'
        r = w.Reward == word;
    case 'endtrial'
        r = bitand(hex2dec('f0'),word(:,2)) == w.End_Code;
    otherwise
        error('Unrecognized word type');
end
