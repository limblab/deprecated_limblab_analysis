%%
fid=fopen('/Volumes/data/Miller/Chewie_8I2/Filter files/07-25-2011/Chewie_Spike_LFP_07252011001poly3_150featsvel-decoderNoP_log.txt');

array=[];
while ~feof(fid)
	array=[array; sscanf(fgetl(fid),'%f \t%f \t%f \t%f \t%f \t%f \t%f')'];
end

fclose(fid);

