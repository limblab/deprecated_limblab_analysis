
connection = cbmex('open',1);
if ~connection
    error('Connection to Central Failed');
end

n_neurons  = 96;
duration   = 20;
binsize    = 0.05;
n_bins     = round(duration/binsize);
spikes = zeros(96,n_bins);

Redo       = 'Redo';
while(strcmp(Redo,'Redo'))
    
    h = waitbar(0,'Collecting Neural Data');
    cbmex('trialconfig',1,'nocontinuous');
    
    buf_t = tic;
    for i = 1:n_bins
        if toc(buf_t)>=binsize
            cylcle_t = toc(buf_t);
            ts_cell_array = cbmex('trialdata',1);
            buf_t = tic;
            %number of spikes per chan
            for n = 1:params.n_neurons
                spikes(n,i) = length(ts_cell_array{n,2});
            end
            waitbar(i/duration,h);
        end
    end
    close(h);
    
    [missing_spikes,missing_pct] = compare_with_fake_monkeys(spikes,binsize);
    
    if missing_spikes<0
        Redo = questdlg(sprintf('An error as occured\nCould not count spikes'),'Blame Chris','OK','Redo','OK');
    else
        Redo = questdlg(sprintf('%d missing spikes\n (%.3f%%)',missing_spikes,missing_pct),'Test Result','OK','Redo','OK');
    end
end
clearxpc;
