
function [cls]=TReadTreeBatchTest(tree,X,cls)
    % if the node is a terminal, then return
    if(tree.terminal==1)
        index = X(:,end);
        cls(index,:)=tree.class;
        return
    end


    type=0;
    testStat = X(:,1:end-1)*(tree.bestCoef)+tree.bestC1;

    Xleft=X(testStat<=tree.split,:);
    Xright=X(testStat>tree.split,:);

    if(size(Xleft,1)>0)
        %[cls]=TReadTreeBatchTest(tree.childl,Xleft,cls);
        [cls]=TReadTreeBatchTest(tree.childl,Xleft,cls);
    end
    if(size(Xright,1)>0)
        %[cls]=TReadTreeBatchTest(tree.childr,Xright,cls);
        [cls]=TReadTreeBatchTest(tree.childr,Xright,cls);
    end


    %return;
end
