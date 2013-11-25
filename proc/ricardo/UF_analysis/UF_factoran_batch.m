% 
% Mini_2013-11-25_UF_
UF_struct = UF_struct_25;
factor_offset = .03; 
interesting_idx = UF_struct.bump_indexes{2};
UF_struct.colors_field = [0 0 1; 1 0 0];
UF_factoran(UF_struct,interesting_idx,factor_offset,0)

% % Nice separation
% % Mini_2013-11-05_UF_
% UF_struct = UF_struct_05;
% factor_offset = .03; 
% interesting_idx = intersect(UF_struct.bump_indexes{3},UF_struct.bias_indexes{2});
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran(UF_struct,interesting_idx,factor_offset,0)

% % Very different EMG vs neuron patterns!
% % Mini_2013-11-22_UF_
% UF_struct = UF_struct_22;
% interesting_idx = UF_struct.field_indexes{1};
% factor_offset = 0.03;
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran_bump(UF_struct,interesting_idx,factor_offset,0)

% % Very different EMG vs neuron patterns!
% % Mini_2013-11-05_UF_
% UF_struct = UF_struct_05;
% interesting_idx = intersect(UF_struct.bias_indexes{1},UF_struct.field_indexes{1});
% factor_offset = 0.03;
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran_bump(UF_struct,interesting_idx,factor_offset,0)

% % Very different EMG vs neuron patterns!
% % Mini_2013-11-20_UF_
% UF_struct = UF_struct_20;
% interesting_idx = UF_struct.field_indexes{1};
% factor_offset = 0.03;
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran_bump(UF_struct,interesting_idx,factor_offset,0)

% % One factor
% % Mini_2013-11-22_UF_
% UF_struct = UF_struct_22;
% interesting_idx = [];
% factor_offset = 0.03;
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran(UF_struct,interesting_idx,factor_offset,0)

% % Nice separation
% % Mini_2013-11-22_UF_
% UF_struct = UF_struct_22;
% interesting_idx = UF_struct.bump_indexes{2};
% factor_offset = -.1;
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran(UF_struct,interesting_idx,factor_offset,0)


% % Two factors?
% % Mini_2013-11-05_UF_
% UF_struct = UF_struct_05;
% factor_offset = 0.03;
% interesting_idx = UF_struct.bias_indexes{2};
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran(UF_struct,interesting_idx,factor_offset,0)

% % Two factors?
% % Mini_2013-11-05_UF_
% UF_struct = UF_struct_05;
% factor_offset = -0.1;
% interesting_idx = UF_struct.bias_indexes{2};
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran(UF_struct,interesting_idx,factor_offset,0)

% 
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran(UF_struct,interesting_idx,factor_offset,0)
% UF_factoran_bump(UF_struct,interesting_idx,factor_offset,0)