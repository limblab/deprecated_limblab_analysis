function w = MG_Words()

w.Start = hex2dec('16');

w.End_Code = hex2dec('20');
w.Reward = hex2dec('20');
w.Abort = hex2dec('21');
w.Failure = hex2dec('22');
w.Incomplete = hex2dec('23');

w.Reach = hex2dec('70');

% end_words = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 1);
w.IsEndWord = @endwrd;
w.GetReachTgt = @tgt;

w.Touch_Pad = hex2dec('30');
w.Go_Cue = hex2dec('31');
w.Catch = hex2dec('32');

w.Pickup = hex2dec('90');

function r = endwrd(wrd)
    r = bitand(hex2dec('f0'), wrd) == w.End_Code;
end

function t = tgt(wrd)
    if bitand(hex2dec('f0'),wrd) == w.Reach
        t= bitand(hex2dec('0f'),wrd);
    else
        t=0;
    end
end

end