% Separation by bump direction with dots
% Mini_2013-11-25_UF_
file_prefix = 'Mini_2013-11-25_UF_';
if ~strcmp(UF_struct.UF_file_prefix,file_prefix)
    load(['D:\Data\Mini_7H1\' file_prefix '-bdf'],'UF_struct')
end
show_dots = 1;
factor_range = [.03 .06]; 
interesting_idx = UF_struct.field_indexes{1};
UF_struct.colors_field = [0 0 1; 1 0 0];
UF_factoran_bump(UF_struct,interesting_idx,factor_range,show_dots,0)


% % Nice separation of factors
% % Mini_2013-12-10_UF_
% file_prefix = 'Mini_2013-12-10_UF_';
% if ~strcmp(UF_struct.UF_file_prefix,file_prefix)
%     load(['D:\Data\Mini_7H1\' file_prefix '-bdf'],'UF_struct')
% end
% factor_range = [.03 .06]; 
% show_dots = 1;
% interesting_idx = UF_struct.bump_indexes{2};
% interesting_idx = intersect(interesting_idx,UF_struct.bias_indexes{2});
% % UF_struct.colors_field = [0 0 1; 1 0 0];
% % UF_factoran_field_bump(UF_struct,interesting_idx,factor_offset,show_dots,0)
% UF_factoran(UF_struct,interesting_idx,factor_range,show_dots,1)

% % Neurons and Tri correlation!
% % Mini_2013-12-06_UF
% file_prefix = 'Mini_2013-12-06_UF_';
% if ~strcmp(UF_struct.UF_file_prefix,file_prefix)
%     load(['D:\Data\Mini_7H1\' file_prefix '-bdf'],'UF_struct')
% end
% factor_range = [-.1 0]; 
% show_dots = 0;
% interesting_idx = UF_struct.bump_indexes{3};
% UF_factoran(UF_struct,interesting_idx,factor_range,show_dots,0)


% % 
% % Separation by bump direction, without dots
% % Mini_2013-11-25_UF_
% % UF_struct = UF_struct_25;
% % show_dots = 0;
% % factor_offset = 0.03; 
% % interesting_idx = UF_struct.field_indexes{1};
% % UF_struct.colors_field = [0 0 1; 1 0 0];
% % UF_factoran_bump(UF_struct,interesting_idx,factor_offset,show_dots,0)
% 
% % Separation by bump direction, without dots
% % Mini_2013-11-25_UF_
% UF_struct = UF_struct_25;
% show_dots = 0;
% factor_offset = .1; 
% interesting_idx = UF_struct.field_indexes{1};
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran_bump(UF_struct,interesting_idx,factor_offset,show_dots,0)

% % One factor for all bumps, with dots
% % Mini_2013-11-05_UF_
% UF_struct = UF_struct_05;
% factor_offset = -.1; 
% show_dots = 0;
% interesting_idx = UF_struct.bias_indexes{2};
% % UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran(UF_struct,interesting_idx,factor_offset,show_dots,0)

% % Different when force pulse
% % Mini_2013-11-05_UF_
% UF_struct = UF_struct_25;
% factor_offset = .03; 
% show_dots = 0;
% interesting_idx = intersect(UF_struct.bump_indexes{3},UF_struct.bias_indexes{1});
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran(UF_struct,interesting_idx,factor_offset,show_dots,0)

% % % Curve in position and neurons
% % Mini_2013-11-25_UF_
% UF_struct = UF_struct_25;
% show_dots = 0;
% factor_offset = .03; 
% interesting_idx = UF_struct.bump_indexes{1};
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran(UF_struct,interesting_idx,factor_offset,show_dots,0)

% % % Very different EMG vs neuron patterns!
% % Mini_2013-11-25_UF_
% UF_struct = UF_struct_22;
% show_dots = 0;
% factor_offset = .1; 
% interesting_idx = UF_struct.field_indexes{1};
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran_bump(UF_struct,interesting_idx,factor_offset,show_dots,0)

% % Very different EMG vs neuron patterns!
% % Mini_2013-11-22_UF_
% UF_struct = UF_struct_22;
% interesting_idx = UF_struct.field_indexes{1};
% show_dots = 0;
% factor_offset = 0.03;
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran_bump(UF_struct,interesting_idx,factor_offset,show_dots,0)

% % Very different EMG vs neuron patterns!
% % Mini_2013-11-05_UF_
% UF_struct = UF_struct_05;
% interesting_idx = intersect(UF_struct.bias_indexes{1},UF_struct.field_indexes{1});
% show_dots = 0;
% factor_offset = 0.03;
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran_bump(UF_struct,interesting_idx,factor_offset,show_dots,0)

% % Very different EMG vs neuron patterns!
% % Mini_2013-11-20_UF_
% UF_struct = UF_struct_20;
% interesting_idx = UF_struct.field_indexes{1};
% show_dots = 0;
% factor_offset = 0.03;
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran_bump(UF_struct,interesting_idx,factor_offset,show_dots,0)

% % One factor
% % Mini_2013-11-22_UF_
% UF_struct = UF_struct_22;
% interesting_idx = [];
% show_dots = 0;
% factor_offset = 0.03;
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran(UF_struct,interesting_idx,factor_offset,show_dots,0)

% % Nice separation
% % Mini_2013-11-22_UF_
% UF_struct = UF_struct_22;
% interesting_idx = UF_struct.bump_indexes{2};
% show_dots = 0;
% factor_offset = -.1;
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran(UF_struct,interesting_idx,factor_offset,show_dots,0)


% % One factor? For all bump directions
% % Mini_2013-11-05_UF_
% UF_struct = UF_struct_05;
% show_dots = 0;
% factor_offset = 0.03;
% interesting_idx = UF_struct.bias_indexes{2};
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran(UF_struct,interesting_idx,factor_offset,show_dots,0)

% % One factor? For all bump directions
% % Mini_2013-11-05_UF_
% UF_struct = UF_struct_05;
% show_dots = 0;
% factor_offset = -0.1;
% interesting_idx = UF_struct.bias_indexes{2};
% UF_struct.colors_field = [0 0 1; 1 0 0];
% UF_factoran(UF_struct,interesting_idx,factor_offset,show_dots,0)
