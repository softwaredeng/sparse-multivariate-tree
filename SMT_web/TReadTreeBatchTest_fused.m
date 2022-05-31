function [cls]=TReadTreeBatchTest_fused(tree,X,XX,XXX,cls)

% if the node is a terminal, then return
if(tree.terminal==1)  
    index = X(:,end);
    cls(index,:)=tree.class; 
return  
end

type=0;
if(tree.bestType==1)%mean
    tempX=X(:,1:end-1);
    testStat = tempX*(tree.bestCoef)+tree.bestC1;    
end
if(tree.bestType==2)%slope
    tempX=XX;
    testStat = tempX*(tree.bestCoef)+tree.bestC1;    
end 
if(tree.bestType==3)%slope
    tempX=XXX;
    testStat = tempX*(tree.bestCoef)+tree.bestC1;    
end 

Xleft=X(testStat<=tree.split,:);
Xright=X(testStat>tree.split,:);
XXleft=XX(testStat<=tree.split,:);
XXright=XX(testStat>tree.split,:);
XXXleft=XXX(testStat<=tree.split,:);
XXXright=XXX(testStat>tree.split,:);

if(size(Xleft,1)>0)
[cls]=TReadTreeBatchTest_fused(tree.childl,Xleft,XXleft,XXXleft,cls);
end
if(size(Xright,1)>0)
[cls]=TReadTreeBatchTest_fused(tree.childr,Xright,XXright,XXXright,cls);
end


end
