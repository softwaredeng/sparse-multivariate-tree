function [tree,errSL]=TForestSparse(TRAIN,TEST,g_depth,lamdba1,lambda2,entropyFlag)
    X=TRAIN; X(:,1)=[]; %TL = size(TRAIN,2);
    cls=TRAIN(:,1);
    ntree=1;rho=lamdba1; %penalty 1: 0.1. sparsity on all variables
    opts = Parameter(lambda2);
    forest = cell(ntree,1); %parameterCell = cell(ntree,1);
    for itree=1:ntree
        depth=0;[tree] = TMakeTree(depth,g_depth,X,cls,rho,entropyFlag,opts);
        [tree,err] = TPruneTree(tree);
        forest{itree}=tree;

        %feaSSLT=zeros(1,size(TRAIN,2)); m_depth=0;
        %[m_depth,feaSSLT] = TFeaTree(tree,m_depth,feaSSLT)

    end
    Y = TEST;
    if(size(Y,1)~=0)
        clsTest=Y(:,1); Y(:,1)=[];
        %---batch processing test cases
        clsBatch=TReadForestBatchTest(forest,ntree,Y);
        errSL = 1-sum((clsBatch-clsTest(:,1))==0)/size(Y,1);
    else
        errSL=[];
    end
end


