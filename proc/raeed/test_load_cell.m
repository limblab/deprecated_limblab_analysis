%%
bdf = get_nev_mat_data('X:\data\Test data\lab6\Load_cell_20160316_posX_',6);

%%
figure
plot(out_struct.force(:,2),out_struct.force(:,3))
axis equal

%%
figure
plot(out_struct.force(:,2))

%%
figure
plot(out_struct.force(:,3))