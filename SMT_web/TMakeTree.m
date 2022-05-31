function [tree] = TMakeTree(depth,pre_l,X,cls,rho,entropyFlag,opts)
    depth=depth+1;
    tree.terminal=0; %not a terminal node

    tempCls=mode(cls);
    tempErr=sum(cls~=tempCls)/length(cls);
    tree.class=mode(cls);
    tree.ndata=size(X,1);
    ndata=tree.ndata;
    f=tempErr;z=0.69;
    pessE = (f+ z^2/(2*ndata) + z*sqrt(f/ndata-f^2/ndata+z^2/(4*ndata^2))  )/(1+z^2/ndata);
    tree.err=pessE;%pessmistic error

    % if the node's are pure, this will also include the leaf nodes only
    % consists of 1 data
    if(size(unique(cls),1)==1)
        tree.terminal=1; % ternimal node
        tree.depth=depth;
        tree.ndata=size(X,1);
        tree.oriEntropy = IGEntropy(cls);
        tree.class=mode(cls);%the most frequent class; if all equal frequency, then select the first class
        return ;
    end

    if(depth>=pre_l)
        tree.terminal=1; % ternimal node
        tree.depth=depth;
        tree.ndata=size(X,1);
        tree.oriEntropy = IGEntropy(cls);
        tree.class=mode(cls);%the most frequent class; if all equal frequency, then select the first class
        return ;
    end

    bestIG = 0; bestV = -1000;

    [coef, c1, funVal1, ValueL1]= fusedLogisticR(X,cls, rho, opts);
    set0=X*coef+c1; feaCls=[set0 cls];

    if(entropyFlag==0)  % use logistic regression model for splitting.
        if(~isempty(find(set0<0, 1))&&~isempty(find(set0>0, 1))) %if predicted values include two classes
            cutSet=0;
            [iG,V]=IGThisWin(cutSet,feaCls);
            bestIG=iG;
            bestV=0; %threshold for the logistic regression model
            bestCoef=coef;
            bestC1=c1;
        end
    end

    if(entropyFlag==1)
        setSort = sort(set0);
        cutSet=[];
        for j = 1:size(setSort,1)-1
            cutSet=[cutSet setSort(j)/2+setSort(j+1)/2];
        end

        [iG,V]=IGThisWin(cutSet,feaCls);
        if(iG>bestIG)
            bestIG=iG;
            bestV=V;
            bestCoef=coef;
            bestC1=c1;
        end
    end

    if(bestIG<=0)%if there is no entropy gain
        tree.terminal=1; % ternimal node
        tree.depth=depth;
        tree.ndata=size(X,1);
        tree.oriEntropy = IGEntropy(cls);
        tree.class=mode(cls);%the most frequent class; if all equal frequency, then select the first class
        return ;
    end

    stat=X*bestCoef+bestC1;

    ixL = find(stat<=bestV);
    ixR = find(stat>bestV);
    Xleft=X(ixL,:);Xright=X(ixR,:);
    clsleft=cls(ixL);clsright=cls(ixR);

    %tree.bestType=bestType;
    tree.bestCoef=bestCoef;
    tree.bestC1=bestC1;
    tree.split=bestV;
    tree.entropy=bestIG;
    tree.depth=depth;
    tree.ndata=size(X,1);
    tree.oriEntropy = IGEntropy(cls);
    tree.minChild = min(size(clsleft,1),size(clsright,1));
    [tree.childl]=TMakeTree(depth,pre_l,Xleft,clsleft,rho,entropyFlag,opts);
    [tree.childr]=TMakeTree(depth,pre_l,Xright,clsright,rho,entropyFlag,opts);

