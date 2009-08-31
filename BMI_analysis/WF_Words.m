function w = WF_Words()

w.Start = hex2dec('17');

w.End_Code = hex2dec('20');
w.Reward = hex2dec('20');
w.Abort = hex2dec('21');
w.Failure = hex2dec('22');
w.Incomplete = hex2dec('23');

% end_words = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 1);
w.IsEndWord = @tmp;

w.Touch_Pad = hex2dec('30');
w.Go_Cue = hex2dec('31');
w.Catch = hex2dec('32');

w.Pickup = hex2dec('90');

function r = tmp(wrd)
    r = bitand(hex2dec('f0'), wrd) == w.End_Code;
end

end
