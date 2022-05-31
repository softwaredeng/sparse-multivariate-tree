function [tree,feaSSLT] = TMakeTree_fused(depth,pre_l,Series,DiffSeries,AbsDiffSeries,cls,rho,entropyFlag,opts,feaSSLT)
depth=depth+1;
tree.terminal=0; %not a terminal node

tempCls=mode(cls);
tempErr=sum(cls~=tempCls)/length(cls);
tree.class=mode(cls);
tree.ndata=size(Series,1);

ndata=tree.ndata;
f=tempErr;z=0.69;
pessE = ( f+ z^2/(2*ndata) + z*sqrt(f/ndata-f^2/ndata+z^2/(4*ndata^2))  )/(1+z^2/ndata);
tree.err=pessE;  %pessmistic error

% if the node's are pure, this will also include the leaf nodes only
% consists of 1 data
if(size(unique(cls),1)==1)
    tree.terminal=1; % ternimal node
    tree.depth=depth;
    tree.ndata=size(Series,1);
    tree.oriEntropy = IGEntropy(cls);
    tree.class=mode(cls); %the most frequent class; if all equal frequency, then select the first class
    return ;
end

if(depth>=pre_l)
    tree.terminal=1; % ternimal node
    tree.depth=depth;
    tree.ndata=size(Series,1);
    tree.oriEntropy = IGEntropy(cls);
    tree.class=mode(cls); %the most frequent class; if all equal frequency, then select the first class
    return ;
end

bestIG = 0; bestType=-1; %0:mean; 1:slope 2:var;
bestV = -1000; bestP1 = -1; best2=-1;
bestWinsz = -1;

% build model on absolute difference features to identify mean features
[coef, c1, funVal1, ValueL1]= fusedLogisticR(Series,cls, rho, opts);
set0=Series*coef+c1;feaCls=[set0 cls];

if(entropyFlag==0)  % use logistic regression model for splitting.
    cutSet=0;
else
    setSort = sort(set0);
    cutSet=[];
    for j = 1:(length(setSort)-1)
        cutSet=[cutSet setSort(j)/2+setSort(j+1)/2];
    end
end

[iG,V]=IGThisWin(cutSet,feaCls);
if(iG>bestIG)
    bestIG=iG;bestV=V;bestCoef=coef;bestC1=c1;
    bestType=1;
end


% build model on difference features to identify slope features
[coef, c1, funVal1, ValueL1]= fusedLogisticR(DiffSeries,cls, rho, opts);
set0=DiffSeries*coef+c1;feaCls=[set0 cls];

if(entropyFlag==0)  % use logistic regression model for splitting.
    cutSet=0;
else
    setSort = sort(set0);
    cutSet=[];
    for j = 1:(length(setSort)-1)
        cutSet=[cutSet setSort(j)/2+setSort(j+1)/2];
    end
end

[iG,V]=IGThisWin(cutSet,feaCls);
if(iG>bestIG)
    bestIG=iG;bestV=V;bestCoef=coef;bestC1=c1;
    bestType=2;
end


% build model on absolute difference features to identify variance features
[coef, c1, funVal1, ValueL1]= fusedLogisticR(AbsDiffSeries,cls, rho, opts);
set0=AbsDiffSeries*coef+c1;feaCls=[set0 cls];

if(entropyFlag==0)  % use logistic regression model for splitting.
    cutSet=0;
else
    setSort = sort(set0);
    cutSet=[];
    for j = 1:(length(setSort)-1)
        cutSet=[cutSet setSort(j)/2+setSort(j+1)/2];
    end
end

[iG,V]=IGThisWin(cutSet,feaCls);
if(iG>bestIG)
    bestIG=iG;bestV=V;bestCoef=coef;bestC1=c1;
    bestType=3;
end


%end
if(bestIG<=0) %if there is no entropy gain
    tree.terminal=1; % ternimal node
    tree.depth=depth;
    tree.ndata=size(Series,1);
    tree.oriEntropy = IGEntropy(cls);
    tree.class=mode(cls); %the most frequent class; if all equal frequency, then select the first class
    return ;
end

inx = find(bestCoef~=0);
feaSSLT(bestType,inx)=feaSSLT(bestType,inx)+1;


if(bestType==1)
    stat=Series*bestCoef+bestC1;
end
if(bestType==2)
    stat=DiffSeries*bestCoef+bestC1;
end
if(bestType==3)
    stat=AbsDiffSeries*bestCoef+bestC1;
end

ixL = find(stat<=bestV);
ixR = find(stat>bestV);
Xleft=Series(ixL,:);Xright=Series(ixR,:);
XXleft=DiffSeries(ixL,:);XXright=DiffSeries(ixR,:);
XXXleft=AbsDiffSeries(ixL,:);XXXright=AbsDiffSeries(ixR,:);
clsleft=cls(ixL);clsright=cls(ixR);

tree.bestType=bestType;
tree.bestCoef=bestCoef;
tree.bestC1=bestC1;
tree.split=bestV;
tree.entropy=bestIG;
tree.depth=depth;
tree.ndata=size(Series,1);
tree.oriEntropy = IGEntropy(cls);
tree.minChild = min(size(clsleft,1),size(clsright,1));
[tree.childl,feaSSLT]=TMakeTree_fused(depth,pre_l,Xleft,XXleft,XXXleft,clsleft,rho,entropyFlag,opts,feaSSLT);
[tree.childr,feaSSLT]=TMakeTree_fused(depth,pre_l,Xright,XXright,XXXright,clsright,rho,entropyFlag,opts,feaSSLT);

