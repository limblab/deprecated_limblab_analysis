function r=featureRank(PB,y)

if ~verLessThan('matlab','7.7.0') || size(y,2)>1
    for c=1:size(PB,2)
        for f=1:size(PB,1)
            rt1=corrcoef(y(:,1),squeeze(PB(f,c,:)));
            if size(y,2)>1                  %%%%% NOTE: MODIFIED THIS 1/10/11 to use ALL outputs in calculating bestfeat (orig modified 12/13/10 for 2 outputs)
                rsum=abs(rt1);
                for n=2:size(y,2)
                    rtemp=corrcoef(y(:,n),squeeze(PB(f,c,:)));
                    rsum=rsum+abs(rtemp);
                end
                rt=rsum/n;
                %                 rt=(abs(rt1)+abs(rt2))/2;
            else
                rt=rt1;
            end
            if size(rt,2)>1
                r(f,c)=abs(rt(1,2));    %take absolute value of r
            else
                r(f,c)=abs(rt);
            end
        end
    end
else %if older versions than 2008 (7.7.0), corrcoef outputs a scalar; in newer versions it outputs matrix for vectors
    for c=1:size(PB,2)
        for f=1:size(PB,1)
            rt1=corrcoef(y(:,1),squeeze(PB(f,c,:)));
            if size(y,2)>1
                rsum=abs(rt1);
                for n=2:size(y,2)
                    rtemp=corrcoef(y(:,n),squeeze(PB(f,c,:)));
                    rsum=rsum+abs(rtemp);
                end
                rt=rsum/n;
            else
                rt=rt1;
            end
            
            r(f,c)=abs(rt);    %take absolute value of r
        end
    end
end


