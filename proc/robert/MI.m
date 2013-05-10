function varargout=MI(in1,in2)

% syntax [I,margX,margY]=MI(in1,in2)
%
% calculated mutual information between inputs in1,in2.
% does no pre-processing.




N=9;   % precision of the mesh
% arg2,3 are x_grid,y_grid. Use for: mesh(x_grid,y_grid,jpdf)
[~,jpdf,~,~]=kde2d([rowBoat(in1) rowBoat(in2)],2^N);
jpdf(jpdf<0)=0;
jpdf=jpdf./sum(jpdf(:));
margX=sum(jpdf,1); margY=sum(jpdf,2);

% take log, but apply convention that log(0)=0
logjpdf=jpdf; logjpdf(logjpdf==0)=NaN; logjpdf=log(logjpdf);
logjpdf(isnan(logjpdf))=0;
margX(margX==0)=NaN; margX=log(margX); margX(isnan(margX))=0;
margY(margY==0)=NaN; margY=log(margY); margY(isnan(margY))=0;
I=sum(sum(jpdf.*(logjpdf-repmat(margX,size(logjpdf,1),1)- ...
    repmat(margY,1,size(logjpdf,2)))));

varargout{1}=I;
if nargout > 1
    varargout{2}=margX;
    if nargout > 2
        varargout{3}=margY;
    end
end