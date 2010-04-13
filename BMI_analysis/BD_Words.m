function w = BD_Words()

w.Start = hex2dec('19');

w.End_Code = hex2dec('20');
w.Reward = hex2dec('20');
w.Abort = hex2dec('21');
w.Failure = hex2dec('22');
w.Incomplete = hex2dec('23');
w.Empty_Tray = hex2dec('24');

w.Touch_Pad = hex2dec('30');
w.Go_Cue = hex2dec('31');
w.Catch = hex2dec('32');

w.Gadget_On = hex2dec('40');

w.Reach = hex2dec('70');

w.Mvmt_Onset = hex2dec('80');

w.Pickup = hex2dec('90');

% end_words = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 1);
w.IsEndWord = @endwrd;
w.GetTgt = @tgt;
w.GetGdt = @gdt;


function r = endwrd(wrd)
    r = bitand(hex2dec('f0'), wrd) == w.End_Code;
end

function t = tgt(wrd)
    if bitand(hex2dec('f0'),wrd) == w.Reach
        t= bitand(hex2dec('0f'),wrd);
    else
        t=-1;
    end
end

function g = gdt(wrd)
    if bitand(hex2dec('f0'),wrd) == w.Gadget_On
        g= bitand(hex2dec('0f'),wrd);
    else
        g=-1;
    end
end



end

