
function [tree,err] = TPruneTree(tree)
    cls=tree.class;
    ndata=tree.ndata;
    thisE=tree.err;%pessmistic error
    if( tree.terminal==1)
        err = tree.err;
        return
    end

    [tree.childl,errL]=TPruneTree(tree.childl);
    [tree.childr,errR]=TPruneTree(tree.childr);

    temp=tree.childl;nL=temp.ndata;
    temp=tree.childr;nR=temp.ndata;

    errB = (nL/ndata)*errL+(nR/ndata)*errR;

    if(thisE<errB)
      %  disp('pruned')
        err = thisE;
        tree.terminal=1;
        tree.childl=[];
        tree.childr=[];
    end

    if(thisE>=errB)
        err = errB;
    end
