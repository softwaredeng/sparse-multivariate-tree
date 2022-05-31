function [m_depth,feaSSLT] = TFeaTree_fused(tree,m_depth,feaSSLT)

if(tree.terminal==1)
    return
end

inx = find(tree.bestCoef~=0);
feaSSLT(tree.bestType,inx)=feaSSLT(tree.bestType,inx)+1;

if(m_depth<tree.depth)
    m_depth=tree.depth;
end

[m_depth,feaSSLT]=TFeaTree_fused(tree.childl,m_depth,feaSSLT);
[m_depth,feaSSLT]=TFeaTree_fused(tree.childr,m_depth,feaSSLT);


