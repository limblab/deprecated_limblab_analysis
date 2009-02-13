% $Id$
% Evaluates what cells in BDF have proprioceptive responses

x_chan_id = find(strcmp(bdf.raw.analog.channels, 'GoniometerX'));
y_chan_id = find(strcmp(bdf.raw.analog.channels, 'GoniometerY'));

last_analog_time = bdf.raw.analog.ts{1}(1) + ...
            length(bdf.raw.analog.data{1}) / bdf.raw.analog.adfreq(1);
stop_time = floor(last_analog_time);

start_index = bdf.raw.analog.ts{x_chan_id}(1);
idx = (1:stop_time*1000);
x = bdf.raw.analog.data{x_chan_id}(idx);
y = bdf.raw.analog.data{y_chan_id}(idx);

for i = 1:length(bdf.units)
    disp(sprintf('i = %d of %d', i, length(bdf.units)));
    
    s = bdf.units(i).ts - start_index;
    s = s( s > 0 );
    s = s( s < stop_time );
    
    b = train2bins(s, 0.001:0.001:stop_time)';
    [r_x]    = stxcorr(x, b, 30000, 15000, 300);
    [r_y, c] = stxcorr(y, b, 30000, 15000, 300);
    c = c./1000;
    
    figure;
    plot(c,r_x,'b-',c,r_y,'r-');
    title(sprintf('Unit %d-%d', bdf.units(i).id(1), bdf.units(i).id(2)));    
end


