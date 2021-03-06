% SMT for time-series data evaluates performance on TEST data set
clc; clear;
temp=what;
addpath(genpath([temp.path '/SLEP_4.0/SLEP']));
rand('seed',5);

trainDir='/home/baydogan/Research/TimeSeries/UnivariateDataSets/5TRAIN';
testDir='/home/baydogan/Research/TimeSeries/UnivariateDataSets/5TEST';

TRAIN = load(trainDir);
TEST = load(testDir);

noftrain=size(TRAIN,1);
noftest=size(TEST,1);

cls=TRAIN(:,1);
if(length(unique(cls))>2)
    message='Binary classification problem is required.'
    return;
end

% replace class labels with 1 and -1
uniCls = unique(cls); tempCls=cls;
tempCls(cls==uniCls(1))=-1;
tempCls(cls==uniCls(2))=1;
cls=tempCls;

%parameters
useEntropy=0;   % 1 if split value is to be found using entropy criterion, 0 if V=0 will be used

%experiment parameters
nofCVfold=5;
bestFuse=0;
rhoSet=[0.05 0.1 0.3 0.5];
fuseSet=[0.05 0.1 0.3 0.5];

%definitions required for running solver for penalized regression models for SLEP
ntree=1;
pre_l=max(ceil(log(length(cls))),10);
forest = cell(1,1);

%fused lasso parameters
opts=[];
opts.init=2;        % starting from a zero point
opts.tFlag=10;      % run .maxIter iterations
opts.maxIter=500;   % maximum number of iterations
opts.nFlag=0;       % without normalization
opts.rFlag=1;       % the input parameter 'rho' is a ratio in (0, 1)
opts.fusedPenalty=1;% initialize fuse penalty
opts.lFlag=0;       % line search
rho=0.1;%penalty 1: 0.1. sparsity on all variables

% standardize series and generate difference and absolute difference series
Series=zscore(TRAIN(:,2:end),0,2);
DiffSeries=(diff(Series'))';
AbsDiffSeries=abs(DiffSeries);

Indices = crossvalind('Kfold', noftrain, nofCVfold);

bestE=99999;bestRho=0;bestFuse=0;
for iRho=rhoSet
    for iFuse=fuseSet
        rho=iRho; opts.fusedPenalty=iFuse;
        eV=[];
        for fold=1:nofCVfold;
            message=[' penalty setting ', num2str(iRho), 'fuse setting ', num2str(iFuse), 'CV ', num2str(fold)]
            randIx = find(Indices==fold);
            tempClsTest = cls(randIx);
            tempCls = cls; tempCls(randIx)=[];
            B=Series(randIx,:); A=Series; A(randIx,:)=[]; %A: train; B:tsting
            AA=(diff(A'))';     AAA=abs(AA);
            BB=(diff(B'))';     BBB=abs(BB);
            
            depth=0;
            feaSSLT=zeros(3,size(A,2));
            [tree1,feaSSLT] = TMakeTree_fused(depth,pre_l,A,AA,AAA,tempCls,rho,useEntropy,opts,feaSSLT);
            [tree1,err] = TPruneTree(tree1);
            
            forest{1}=tree1;
            
            clsBatch=TReadForestBatchTest_fused(forest,ntree,B,BB,BBB);
            errTemp = sum(clsBatch~=tempClsTest);
            eV=[eV errTemp];
        end
        err=sum(eV);
        if(err<bestE)
            bestE=err; bestRho=rho; bestFuse=iFuse;
        end
        if(err==bestE && rho+iFuse>bestRho+bestFuse)
            bestE=err; bestRho=rho; bestFuse=iFuse;
        end
    end
end

% train with best parameter set based on CV on training data
rho=bestRho;opts.fusedPenalty=bestFuse;
depth=0;
feaSSLT=zeros(3,size(Series,2));
[tree1,feaSSLT] = TMakeTree_fused(depth,pre_l,Series,DiffSeries,AbsDiffSeries,cls,rho,useEntropy,opts,feaSSLT);
[tree1,err] = TPruneTree(tree1);


% visualize important patterns
feaSSLT=zeros(3,size(Series,2));
m_depth=0;
[m_depth,feaSSLT] = TFeaTree_fused(tree1,m_depth,feaSSLT);
col={'.r' '.b' '.k'} ;
figure,hold on,
for jj =1:3
    plot(feaSSLT(jj,:),col{jj})
end
legend('mean','slope','deviation')

% evaluate test performance
forest{1}=tree1;
testSeries=zscore(TEST(:,2:end),0,2);
testDiffSeries=(diff(testSeries'))';
testAbsDiffSeries=abs(testDiffSeries);
clsBatch=TReadForestBatchTest_fused(forest,ntree,testSeries,testDiffSeries,testAbsDiffSeries);
testcls=TEST(:,1);
tempCls=testcls;
tempCls(testcls==uniCls(1))=-1;
tempCls(testcls==uniCls(2))=1;
testcls=tempCls;
errTest = sum(clsBatch~=testcls)/noftest % print error rate

