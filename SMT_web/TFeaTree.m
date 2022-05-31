function [m_depth,feaSSLT] = TFeaTree(tree,m_depth,feaSSLT)
if(tree.terminal==1)
    return
end

inx = find(tree.bestCoef~=0);
feaSSLT=[feaSSLT;length(inx)];
if(m_depth<tree.depth)
    m_depth=tree.depth;
end

[m_depth,feaSSLT]=TFeaTree(tree.childl,m_depth,feaSSLT);
[m_depth,feaSSLT]=TFeaTree(tree.childr,m_depth,feaSSLT);


