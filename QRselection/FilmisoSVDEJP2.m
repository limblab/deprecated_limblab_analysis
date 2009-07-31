function [H,v,mcc,vi]=filMISOSVDEJP2(X,Y,numlags,numsides,fs,flag)
% Main code here is identical to FilMIMO.  However, additional
% computations are added to compute contributions of each input 
% to a single output.  These may later be added to FilMIMO
%
% New output, vi : output variance (unique) contributed by each input
% New input, flag: 0 - Run SVD and input selection, no interactive plotting
%                  1 - Run SVD and input selection with interactive plotting
%                  2 - Input selection only, no plotting

% Identification and input selection could be separated for greater speed if
% input selection is of primary concern

%%%%%%%%%%%%%%%%%%%% Comments from FilMIMO %%%%%%%%%%%%%%%%%%%%%%%%
%
% Solves for the nonparametric filters of a MIMO linear
% system using a correlation function based approach.
%
%    USAGE:   [H,vaf]=filMIMOSVD(X,Y,numlags,numsides,fs);
%
%
%    X        : Columnwise inputs  [x1 x2 ...] to the unknown system
%    Y        : Columnwise outputs [y1 y2 ...] to the unknown system
%    numlags  : the number of lags to calculate for all linear filters
%    numsides : determine a causal (1 side) or noncausal 
%               (2 sides) response.
%    fs		: Sampling rate (default=1)
%    H      : the identified nonparametric filters between X and Y.
%
% The returned filter matrix is organized in columns as:
%     H=[h11 h21 h31 ....;
%        h12 h22 h32 ....;
%        h13 h23 h33 ...;
%        ... ... ... ...]
%  Which represents the system:
%  y1=h11*x1 + h12*x2 + h13*x3 + ...     
%  y2=h21*x1 + h22*x2 + h33*x3 + ...     
%  y3=h31*x1 + h32*x2 + h33*x3 + ...    
%  ... 

% EJP Feb 1997
% EJP & DTW May 2003 -  Updated to sort SVs according to their contribution
%                       to the output.
% EJP & DTW AUG 03 -  Added contributions to outputs, and checkes to ensure that a
%               MISO system is being identified

if (nargin==4) fs=1;flag=0;disp('Sampling rate set to 1.0'); 
elseif (nargin==5) flag=0;
elseif (nargin ~=6) disp('Wrong number of inputs');return;end

% if (rem(numlags,4) ~= 0 )
%     disp('numlags must be a multiple of 4');
%     return
% end

[rX,cX]= size(X); [rY,cY]= size(Y);

if cY ~= 1 disp('Multiple outputs.  Use filMIMO instead.');return;end

numio=cX+cY;

X= detrend(X); Y=detrend(Y);

R=covf([X Y],numlags);

PHI=zeros(2*numlags-1,numio^2);

%PHI(:,i+(j-1)*numio)=E[z(i,:)*z(j,:)]  This is a 2-sided correlation  
for i=1:numio
    for j=1:numio
        PHI(:,i+(j-1)*numio)=[R(j+(i-1)*numio,numlags:-1:2)';
            R(i+(j-1)*numio,:)'];
    end
end

if numsides == 1
    Nxxr=numlags:2*numlags-1;
    Nxxc=numlags:-1:1;
    Nxy=numlags:2*numlags-1;
else
    Nxxr=numlags:2*numlags-2;
    Nxxc=numlags:-1:2;
    Nxy=numlags/2+1:3*numlags/2 -1;
    numlags=numlags-1;
end

%Create Correlation matrices
%Input
PX=zeros(cX*numlags,cX*numlags);
for i=1:cX
    for j=1:cX
        cidx=1+(i-1)*numlags:i*numlags;
        ridx=1+(j-1)*numlags:j*numlags;
        PX(ridx,cidx)=toeplitz(PHI(Nxxc,i+(j-1)*numio),PHI(Nxxr,i+(j-1)*numio));
    end
end 

%Input/Output
PXY=zeros(cX*numlags,cY);
for i=1:cX							%input loop
    for j=cX+1:cY+cX				    %output loop
        ridx=1+(i-1)*numlags:i*numlags;
        cidx=j-cX;
        PXY(ridx,cidx)=PHI(Nxy,i+(j-1)*numio);
    end
end	

if flag~=2 %Run SVD
    disp('Calculating SVD')
    %%Compute SVD for use in pseudoinverse
    [U,S,V] = svd(PX);
    
    %1. compute H with full inverse.  This is the initial estimate.
    %Note that U should equal V for positive definite symmetric matrices.
    H=V*diag(1./diag(S))*U'*PXY;
    
    %2. Compute projection of H onto the singular vectors. 
    ProjH=V'*H;
    
    %3. Contribution of SVs to total variance of the outputs
    % Each row of ProjH corresponds to a singular value.
    % Each colummn corresponds to a single o/p
    SVCont=S*(ProjH.^2);
    %This is a matrix where element (i,j) is the ith SV's contribution
    % to output j.
    
    %4. Sorting algorithm.  There are many options for this.
    % Let's simply start by determining the contribution of each SV to the
    % total o/p variance
    if cY>1
        SortVector=sum(SVCont')';
    else
        SortVector=SVCont;
    end
    [SordidVector,idx]=sort(SortVector);
    SordidVector=flipud(SordidVector);  %(Descending order)
    idx=flipud(idx);
else
        %disp('_NOT_ Calculating SVD')
    H=fs*(PX\PXY);
end

% %5. Selection algorithm.  Something smart like MDL would be best.
% %Let's be dum here to get started.
% if (flag==1)
%     figure(1)
%     subplot(211)
%     plot(cumsum(SordidVector)/sum(SordidVector))
%     title 'Normalized SV contributions to Output'
%     
%     subplot(212)
%     plot(idx)
%     title 'Sorted indeces'
% end
% 
% if (flag~=2)
%     tol=0.95;
%     while tol>0
%         Num2Keep=sum(cumsum(SordidVector/sum(SordidVector))<tol);
%         %Compute estimated H, based upon pseudoinverse
%         idxK=idx(1:Num2Keep);
%         Hpinv=V(:,idxK)*diag(1./diag(S(idxK,idxK)))*U(:,idxK)'*PXY;
%         
%         if (flag==1)
%             ll=IRFResultsGen(H,numsides,cX,fs,2,0);     set(ll,'col','b');
%             ll=IRFResultsGen(Hpinv,numsides,cX,fs,2,1); set(ll,'col','r');
%             tol=input('Input fraction of output variance to use (0-1), -1 to exit: ');
%         else
%             tol=-1;
%         end
%     end
% end

%Compute the UNIQUE contribution of each input to the total output variance
% This needs to be done one input at a time.
for k=1:cX
    %Order inputs so that the one of interest is placed last.  This is
    %necessary due to the process of Gram-Schmidt orthogonalization (QR decomposition).
    %In this process, each succesive vector of the Q matrix represents the
    %unique contributions of that input not present in the PREVIOUS inputs.
    %However, the first cX-1 Q vectors may contain contributions also
    %present in the original (non-orthogonalized) input cX.
    
    %swap the last input (index) with the one of interest
    ii=1:cX; temp=ii(k);ii(k)=ii(cX);ii(cX)=temp;
    
    %Create Correlation matrices
    %Input
    PX=PX*0;
    for i=1:cX      %input i
        for j=1:cX  %input j
            cidx=1+(i-1)*numlags:i*numlags;
            ridx=1+(j-1)*numlags:j*numlags;
            %use swapped indeces for each input used in the correlation
            PX(ridx,cidx)=toeplitz(PHI(Nxxc,ii(i)+(ii(j)-1)*numio),PHI(Nxxr,ii(i)+(ii(j)-1)*numio));
        end
    end 
    
    
    %Input/Output
    PXY=PXY*0;
    for i=1:cX							%input i
        for j=cX+1:cY+cX				    %output j
            ridx=1+(i-1)*numlags:i*numlags;
            cidx=j-cX;
            %use swapped indeces for only the input, not the output
            PXY(ridx,cidx)=PHI(Nxy,ii(i)+(j-1)*numio);
        end
    end	
    
    %See MISO paper (Westwick et al., 2004)
    A=[PX, PXY;PXY' var(Y)];
    R=chol(A);
    
    %select term relevant to last input in the current ordering
    XX=R((numlags*(cX-1)+1):numlags*cX,numlags*cX+1);
    vi(k,1)=(XX'*XX);
end


%%%Left over from old code.  Need to see what this means after pseudoinverse   
%Estimate of VAF for each input of each output based upon identified system
v=diag(100*(PXY'*H)./cov(Y)/fs);
mcc=sum(v.*diag(cov(Y)))/sum(diag(cov(Y)));
