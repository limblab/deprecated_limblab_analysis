function h = errorarea(x,ymean,yerror,c,alpha_val)
    mat_ver = ver;
    mat_ver = str2double(mat_ver(strcmp({mat_ver.Name},'MATLAB')).Version);
    
    x = reshape(x,1,[]);
    ymean = reshape(ymean,size(x,1),size(x,2));
    yerror = reshape(yerror,size(x,1),size(x,2));
    
    if mat_ver < 8.4
        h = area(x([1:end end:-1:1]),[ymean(1:end)+yerror(1:end) ymean(end:-1:1)-yerror(end:-1:1)],...
        'FaceColor',c,'LineStyle','none');
        alpha(alpha_val)
    else
        h = patch(x([1:end end:-1:1]),[ymean(1:end)+yerror(1:end) ymean(end:-1:1)-yerror(end:-1:1)],...
        c,'LineStyle','none');
        h.FaceColor = c;
        drawnow; pause(0.05);  % this is important!
        h.FaceAlpha = alpha_val;
%         h.Face.ColorType = 'truecoloralpha';
%         h.Face.ColorData(4) = alpha_val*255;  % 40/255 = 0.16 opacity = 84% transparent
    end
    
    hChildren = get(gca,'children');
    hType = get(hChildren,'Type');
    set(gca,'children',hChildren([find(strcmp(hType,'line')); find(~strcmp(hType,'line'))]))
    
end