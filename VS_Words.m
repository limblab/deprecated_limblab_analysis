function w = VS_Words()

w.Start = hex2dec('1B');

w.End_Code = hex2dec('20');
w.Reward = hex2dec('20');
w.Abort = hex2dec('21');
w.Failure = hex2dec('22');
w.Incomplete = hex2dec('23');

w.CT_On  = hex2dec('30');
w.CT_Hold= hex2dec('A0');

w.Movement = hex2dec('80');

w.OT_On  = hex2dec('40');
w.OT_Hold= hex2dec('A1');

% end_words = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 1);
w.IsEndWord = @endwrd;
w.GetTgt = @tgt;
w.GetGdt = @gdt;


function r = endwrd(wrd)
    r = bitand(hex2dec('f0'), wrd) == w.End_Code;
end

function t = tgt(wrd)
    if bitand(hex2dec('f0'),wrd) == w.OT_On
        t= bitand(hex2dec('0f'),wrd);
    else
        t=-1;
    end
end

end

