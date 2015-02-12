function W = plotH(H,numlags,varargin)
%this function plots the weights in H using imagesc for each
% 
% varargin = {norm,plot_type,subplot_flag,out_labels,in_labels)
%
% subplot_flag : set to 1 to plot all outputs as subplot of same figure
% out_labels   : output labels, either .emgguide or .cursorposlabel fields
% norm         : set to 1 to normalize weights W between -1 and 1
% plot_type    : set to 'image' to generate image plot. lines otherwise

[rowH,Nout]=size(H);
Nin  = floor(rowH/numlags);

%default:
norm = false;
plot_type = 'image';
subplot_flag = 'true';
out_labels = cell(1,Nout);
in_labels = cell(1,Nin);
for i = 1:Nin
    in_labels{i} = sprintf('in_%g',i);
end
in_labels = char(in_labels);
for o= 1:Nout
    out_labels{i} = sprintf('out_%g',o);
end
out_labels = char(in_labels);

if nargin>2 norm = varargin{1};end
if nargin>3 plot_type = varargin{2};end
if nargin>4 subplot_flag= varargin{3};end
if nargin>5 out_labels = varargin{4};end
if nargin>6 in_labels = varargin{5};end

if mod(rowH,Nin)
    H = H(2:end,:);
end

W     = zeros(Nin,numlags,Nout);

if subplot_flag
    figure;
end

for o = 1:Nout
    for i = 1:Nin
        firstbin = 1+(i-1)*numlags;
        H_i = H(firstbin:firstbin+numlags-1,o);
        max_i = max(abs(H_i));
        W(i,:,o) = H_i;
        if norm
            W(i,:,o) = H_i/max_i;
        end
    end
    if subplot_flag
        subplot(1,Nout,o);
    else
        figure;
    end
    
    switch plot_type
        case 'image'
            imagesc(W(:,:,o));
            colorbar;
        otherwise
            plotLM(W(:,:,o)');
            legend(cellstr(in_labels),'location','bestoutside');
    end            
    title(strrep(out_labels(o,:),'_','\_'));
end