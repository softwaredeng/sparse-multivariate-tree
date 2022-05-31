% SMT for non-time-series data evaluates performance based on
% cross-validation on training data set.

clc; clear;
temp=what;
addpath(genpath([temp.path '/SLEP_4.0/SLEP']));
rand('seed',5);

forest = [];
R=[];

datafile = '/home/baydogan/Research/sparseMultivariateTrees/SMT-Lasso/extra/ada.data';
all=load(datafile);
nofinstances=size(all,1);

cls=all(:,1); 
if(length(unique(cls))>2)
    message='Binary classification problem is required.'
    return;
end

% replace class labels with 1 and -1
uniCls = unique(cls); tempCls=cls;
tempCls(cls==uniCls(1))=-1;
tempCls(cls==uniCls(2))=1;
all(:,1)=tempCls;

%parameters
useEntropy=0;   % 1 if split value is to be found using entropy criterion, 0 if V=0 will be used

%experiment parameters
penSet=[0.05 0.1 0.3 0.5];  % penalty settings to be evaluated to set parameters
nofCVfoldinner=5;   % number of folds for CV used to set parameters
nofCVfold=5;        % number of folds for CV used evaluate the performance
nofRep=5;           % number of replications for CV runs

%definitions required for running solver for penalized regression models for SLEP
fusedPenalty=0;
g_depth=10000000;

% matrices to store results
errSMTfold=zeros(nofRep,nofCVfold);
nofFeatureSMTfold=zeros(nofRep,nofCVfold);
depthSMTfold=zeros(nofRep,nofCVfold);
bestPenalty=zeros(nofRep,nofCVfold);

for replicate=1:nofRep  % replicate nofRep times
    replicate
    Indices = crossvalind('Kfold', nofinstances, nofCVfold);
    for ii=1:nofCVfold  % each fold
        randIx = find(Indices==ii);
        TEST=all(randIx,:); TRAIN=all; TRAIN(randIx,:)=[];
        
        %standardize data based on the 
        TRAIN(:,2:end)=zscore(TRAIN(:,2:end),0,1);
        TEST(:,2:end)=zscore(TEST(:,2:end),0,1);
        
        % get the best lambda1 for SMT using an inner CV with 5 folds on
        % the training data (of the fold)
        eV=zeros(length(penSet),nofCVfoldinner);
        for pp=1:length(penSet)
            in_indices = crossvalind('Kfold', size(TRAIN,1), nofCVfoldinner);
            for jj=1:nofCVfoldinner
                randIx = find(in_indices==jj);
                B=TRAIN(randIx,:); A=TRAIN;A(randIx,:)=[]; %A: train; B:testing
                [tree,errTemp]=TForestSparse(A,B,g_depth,penSet(pp),fusedPenalty,useEntropy);
                eV(pp,jj)=errTemp*length(randIx);
            end
        end
        
        err=sum(eV,2);       % total number of misclassifications for each penalty setting
        [C,minInd]=min(err); % find the setting with minimum misclassification error for inner CV
        bestRho=penSet(minInd); % set penalty 
        bestPenalty(replicate,ii)=bestRho; %store best penalty setting
        
        [tree,errSMTtemp]=TForestSparse(TRAIN,TEST,g_depth,bestRho,fusedPenalty,useEntropy); %train for outer CV with selected penalty
        errSMTfold(replicate,ii)=errSMTtemp;
        errSMTtemp
        
        % get tree characteristics (depth and number of features used)
        features=[];
        depth=0;
        [depth,features] = TFeaTree(tree,depth,features); 
        depthSMTfold(replicate,ii)=depth;
        nofFeatureSMTfold(replicate,ii)=mean(features);
    end
end


