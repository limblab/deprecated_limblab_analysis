%% Get BDFs for RW datasets
folder_pre = 'Y:\Han_13B1\Processed\experiment_2014120';
folder_post = '_RW\';

for i=2:5
    file_pre = [folder_pre num2str(i) folder_post];
    files = dir([file_pre 'Han*']);
    filename = follow_links([file_pre files(1).name]); %assumes only one file
    bdf = get_nev_mat_data(filename,6); %lab 6
    
    pos = bdf.pos;
    vel = bdf.vel;
    acc = bdf.acc;
    
    real_file = dir(filename);
    mkdir(file_pre,'BDFs');
    save([file_pre 'BDFs\Han_2014120' num2str(i) '_RW_move.mat'],'pos','vel','acc')
end