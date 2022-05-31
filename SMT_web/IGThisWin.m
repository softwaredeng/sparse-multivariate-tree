
%calculate information gain of a given window. X is the time series, cls is
%the class label
%nVar: number var threshold to test; nMean: number of mean threhold to test
% bestType: %0:mean; 1:var; 

function [bestIG,bestV]=IGThisWin(cutSet,feaCls)
%function [bestIG,bestType,bestV]=IGThisWin(X,cls,nVar,nMean,nSlope,p1,p2)
bestIG = 0; bestType=-1; %0:mean; 1:meanSet; 
bestV = -1000;


entropy0= IGEntropy(feaCls(:,2));

MaxM=-1000;
for i=cutSet
    if(MaxM< min(abs(feaCls(:,1)-i))  )
        MaxM=min(abs(feaCls(:,1)-i));
    end
end

for i=cutSet
    inx1 = find(feaCls(:,1)>i);
    inx2 = find(feaCls(:,1)<=i);
    set1 = feaCls(inx1,2);
    set2 = feaCls(inx2,2);
    iG =  entropy0 - length(set1)/length(feaCls(:,2))*IGEntropy(set1) - length(set2)/length(feaCls(:,2))*IGEntropy(set2);
    
    %MSE
    MSE=( norm( feaCls(:,1)-mean(feaCls(:,1)) ))^2;
    MSE1=( norm( feaCls(inx1,1)-mean(feaCls(inx1,1)) ))^2;
    MSE2=( norm( feaCls(inx2,1)-mean(feaCls(inx2,1)) ))^2;
    RMSE=1-(MSE1+MSE2)/MSE;
    
    %margin
    RM=min(abs(feaCls(:,1)-i))/MaxM;
    
    %iG=iG+0.001*RMSE + 0.000001*RM;
    %also consider the difference between the two children. Each child only
    %extract the major class
    %tic
    %mCls1 = mode(set1); mCls2 = mode(set2); 
    %inx1M = find(meanCls(:,1)>i & meanCls(:,2)==mCls1);
    %inx2M = find(meanCls(:,1)<=i & meanCls(:,2)==mCls2);
    %iG = iG + max(mean(meanCls(inx1M,1)),mean(meanCls(inx2M,1)))/abs(mean(meanCls(inx1M,1))-mean(meanCls(inx2M,1)));%0.001
    %iG = iG + 0.001* feaCls(:,1)-mean(feaCls(:,2)) max(mean(meanCls(inx1M,1)),mean(meanCls(inx2M,1)))/abs(mean(meanCls(inx1M,1))-mean(meanCls(inx2M,1)));%0.001
    %toc
      
    if(iG>=bestIG)
        bestIG=iG;bestV=i;
    end    
end

end
