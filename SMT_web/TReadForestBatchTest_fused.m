function [clsBatch,clsV]=TReadForestBatchTest_fused(forest,ntree,X,XX,XXX)
%length=length+1;
clsV =zeros(size(X,1),ntree);
index = 1:size(X,1);
X=[X index'];
for itree=1:ntree
    tree=forest{itree};
    cls = zeros(size(X,1),1)-100;
    clsV(:,itree)=TReadTreeBatchTest_fused(tree,X,XX,XXX,cls);
end

clsBatch = mode(clsV,2);
