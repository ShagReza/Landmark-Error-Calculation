clc,clear all,close all
    IP=-1;%-2; % Insertion Penalty
    GSF=4; %0.0; % Grammer Scale Factor


mainpath='D:\Shapar\ShaghayeghUni\AfterPropozal\Step1-EventLandmark\Programs\MyPrograms\EventExtraction';

load([mainpath,'\SmalFarsdatTestNames.mat']);
for ntest=1:length(SmalFarsdatTestNames)
    NameTest=SmalFarsdatTestNames{ntest}
    %-------------------------------------------------------------------------
    NetOutputFile=[mainpath,'\ErrorComputation\Error-labelType1\SoftOut_TrainWithCntk_LabelType1ValidationType1LandmarkType3_NonLandmarkTag\tempTest\Net_',NameTest,'.txt.HLast'];
    GoldFilePath=[mainpath,'\Vaj\Vaj',NameTest,'.mat'];
    LandmarkPath=[mainpath,'\Landmarks\Landmarks',NameTest,'.mat'];
    load(GoldFilePath);
    load(LandmarkPath);
    %--------------------------------------------------------------------------
    TestOut=textread(NetOutputFile);
    TestTags=[];
    [maxx,indxx]=max(TestOut');
    part1=TestOut(:,1:30);
    [maxpart0,indexpart0]=max(part1');
    part2=TestOut(:,31:66);
    [maxpart1,indexpart1]=max(part2');
    part3=TestOut(:,67:102);
    [maxpart2,indexpart2]=max(part3');
    aa=(maxpart1+maxpart2); aa=aa./2;
    [Amax,Aindx]=max([maxpart0;aa;TestOut(:,103)']);
    %--------------------------------------------------------------------------
    %Emission Probabilities
    EmisProb0=[];
    for i=1:size(TestOut,1)
        for j=1:30
            EmisProb0(i,j)=max([part1(i,j),part2(i,j),part3(i,j)]);
        end
        for j=31:36
            EmisProb0(i,j)=max([part2(i,j),part3(i,j)]);
        end
            
    end
    %--------------------------------------------------------------------------
    for i=1:size(TestOut,1)
        if indxx(i)<31   && Aindx(i)==1
            TestTags.state.flag(i)='s';
            TestTags.state.index(i)=indxx(i);
        else
            TestTags.state.index(i)=0;
            TestTags.state.flag(i)='n';
        end
        
        if indxx(i)>30 && indxx(i)<103 && Aindx(i)==2
            TestTags.event.flag(i)='b';
            TestTags.event.indexpart1(i)=indexpart1(i);
            TestTags.event.indexpart2(i)=indexpart2(i);
        else
            TestTags.event.flag(i)='n';
            TestTags.event.indexpart1(i)=0;
            TestTags.event.indexpart2(i)=0;
        end
        
        if indxx(i)<31 && Aindx(i)==1
            TestTags.total.flag(i)='s';
        elseif indxx(i)>30 && indxx(i)<103 &&  Aindx(i)==2
            TestTags.total.flag(i)='b';
        else
            TestTags.total.flag(i)='n';
        end
    end
    %--------------------------------------------------------------------------
    % Talfigh etelaate 'b' va 's', tahiye tavali landmark (landmark chain)
    VajTest=[]; VajTestFlag=[];
    j=1; VajTest{1}=0;  VajTestFlag{j}='s';
    %k=0; CountSilence(1:size(TestOut,1))=0;
    EmisProb1=[];
    for i=1:size(TestOut,1)
        if TestTags.total.flag(i)=='s'
            if  VajTestFlag{j}=='s' && TestTags.state.index(i)~=VajTest{j}
                j=j+1; VajTest{j}=TestTags.state.index(i);
                EmisProb1(j,:)=EmisProb0(i,:);
            elseif VajTestFlag{j}=='b'
                j=j+1; VajTest{j}=TestTags.state.index(i);
                EmisProb1(j,:)=EmisProb0(i,:);
                %elseif VajTestFlag{j}=='s' && TestTags.state.index(i)==VajTest{j} %&& VajTest{j}==30
                %    CountSilence(j)=CountSilence(j)+1;
            end
            VajTestFlag{j}='s';
        end
        if TestTags.total.flag(i)=='b'
            if VajTestFlag{j}=='s'
                j=j+1;  VajTest{j}=[TestTags.event.indexpart1(i),TestTags.event.indexpart2(i)];
                EmisProb1(j,:)=EmisProb0(i,:);
            elseif (VajTestFlag{j}=='b'   && TestTags.event.indexpart1(i)~=VajTest{j}(1) && TestTags.event.indexpart2(i)~=VajTest{j}(2))
                j=j+1;  VajTest{j}=[TestTags.event.indexpart1(i),TestTags.event.indexpart2(i)];
                EmisProb1(j,:)=EmisProb0(i,:);
            end
            VajTestFlag{j}='b';
        end
    end
    %CountSilence(j+1:end)=[];
    %--------------------------------------------------------------------------
    %filtering landmark Chain
    EmisProb2=[];
    VajTestFiltered=[]; j=1;
    if  VajTestFlag{2}=='s', VajTestFiltered{j}=VajTest{2};
    else  VajTestFiltered{j}=VajTest{2}(1);
    end
    EmisProb2(j,:)=EmisProb1(2,:);
    
    for i=3:size(VajTestFlag,2)-1
        if  VajTestFlag{i}=='s'
            %Bast-Burst
            C=0;
            if (VajTestFlag{i-1}=='b' && VajTest{i-1}(2)>30)
                A=VajTest{i}; B=VajTest{i-1}(2); C=0;
                if  (B== 31 &&  (A==13 || A==18))  ||(B== 32 &&  (A==12 || A==17)) || (B== 33 &&  (A==15 || A==19)) || (B== 34 &&  A==14) || (B== 35 && A==16) || (B== 36 &&  (A==20 || A==21))
                    C=1;
                end
            end
            
            if (VajTestFlag{i-1}=='s' && VajTestFlag{i+1}=='s') && (VajTest{i}==VajTest{i-1} || VajTest{i}==VajTest{i+1} || VajTest{i-1}==30),j=j+1; VajTestFiltered{j}=VajTest{i}; EmisProb2(j,:)=EmisProb1(i,:); end
            if (VajTestFlag{i-1}=='b' && VajTestFlag{i+1}=='b') && (VajTest{i}==VajTest{i-1}(2) || VajTest{i}==VajTest{i+1}(1) || VajTest{i-1}(2)==30 || C==1),j=j+1; VajTestFiltered{j}=VajTest{i}; EmisProb2(j,:)=EmisProb1(i,:); end
            if (VajTestFlag{i-1}=='s' && VajTestFlag{i+1}=='b') && (VajTest{i}==VajTest{i-1} || VajTest{i}==VajTest{i+1}(1) || VajTest{i-1}==30),j=j+1; VajTestFiltered{j}=VajTest{i}; EmisProb2(j,:)=EmisProb1(i,:); end
            if (VajTestFlag{i-1}=='b' && VajTestFlag{i+1}=='s') && (VajTest{i}==VajTest{i-1}(2) || VajTest{i}==VajTest{i+1} || VajTest{i-1}(2)==30 || C==1),j=j+1; VajTestFiltered{j}=VajTest{i}; EmisProb2(j,:)=EmisProb1(i,:); end
            
            %Don't emit sokot states
            if (VajTest{i}==30),j=j+1; VajTestFiltered{j}=VajTest{i}; EmisProb2(j,:)=EmisProb1(i,:); end
        else
            %Bast-Burst
            C=0;
            if (VajTestFlag{i-1}=='b' && VajTest{i-1}(2)>30)
                A=VajTest{i}(1); B=VajTest{i-1}(2); C=0;
                if  (B== 31 &&  (A==13 || A==18))  ||(B== 32 &&  (A==12 || A==17)) || (B== 33 &&  (A==15 || A==19)) || (B== 34 &&  A==14) || (B== 35 && A==16) || (B== 36 &&  (A==20 || A==21))
                    C=1;
                end
            end
            if (VajTestFlag{i-1}=='s' && (VajTest{i}(1)==VajTest{i-1} || VajTest{i-1}==30)), j=j+1; VajTestFiltered{j}=VajTest{i}(1);
                EmisProb2(j,:)=EmisProb1(i,:); [maxP,IndP]=max(EmisProb1(i,:)); Pbest=EmisProb2(j, VajTest{i}(1)); EmisProb2(j,VajTest{i}(1))=maxP; EmisProb2(j, IndP)=  Pbest;
            end
            if (VajTestFlag{i-1}=='b' && (VajTest{i}(1)==VajTest{i-1}(2) || VajTest{i-1}(2)==30) || C==1), j=j+1; VajTestFiltered{j}=VajTest{i}(1);
                EmisProb2(j,:)=EmisProb1(i,:); [maxP,IndP]=max(EmisProb1(i,:)); Pbest=EmisProb2(j, VajTest{i}(1)); EmisProb2(j,VajTest{i}(1))=maxP; EmisProb2(j, IndP)=  Pbest;
            end
            if (VajTestFlag{i+1}=='s' && VajTest{i}(2)==VajTest{i+1}), j=j+1; VajTestFiltered{j}=VajTest{i}(2); 
                EmisProb2(j,:)=EmisProb1(i,:); [maxP,IndP]=max(EmisProb1(i,:)); Pbest=EmisProb2(j, VajTest{i}(2)); EmisProb2(j,VajTest{i}(2))=maxP; EmisProb2(j, IndP)=  Pbest;
            end
            if (VajTestFlag{i+1}=='b' && VajTest{i}(2)==VajTest{i+1}(1)), j=j+1; VajTestFiltered{j}=VajTest{i}(2); 
                EmisProb2(j,:)=EmisProb1(i,:); [maxP,IndP]=max(EmisProb1(i,:)); Pbest=EmisProb2(j, VajTest{i}(2)); EmisProb2(j,VajTest{i}(2))=maxP; EmisProb2(j, IndP)=  Pbest;
            end
        end
    end  
    j=j+1; VajTestFiltered{j}=VajTest{i+1}(1);
    EmisProb2(j,:)=EmisProb1(i+1,:);
    %--------------------------------------------------------------------------
    %convnert to probability:
    eps=10^-6;
    EmisProb3=[];
    EmisProb3=mapminmax( EmisProb2,0,1);
    EmisProb3= EmisProb3./repmat(sum(EmisProb3,2),1,size(EmisProb2,2));
    ZeroProbs=find(EmisProb3==0);
    EmisProb3(ZeroProbs)=EmisProb3(ZeroProbs)+eps;
    %--------------------------------------------------------------------------
    %Apply Viterbi Decoding:
    TransitionMatrix36=[];
    load([mainpath,'\TransitionMatrix36.mat']);
    TransitionMatrix=TransitionMatrix36;
    TransitionMatrix=TransitionMatrix+eps;
    EmisProb3=log(EmisProb3);
    ProbBi2=TransitionMatrix;

    ybar_tj=EmisProb3;
    np=36;
    P_acc = zeros(size(ybar_tj));
    
    %%% t=1 (for first frame)
    P_acc(1,:)=ybar_tj(1,:);
    
    %%% t>1 (for other frames)
    S_prev = zeros(size(ybar_tj));
    T=size(ybar_tj,1);
    for t=2:T % frame
        for j=1:np % index of phoneme
            temp1=zeros(1,np);
            for i=1:np
                temp1(i)=P_acc(t-1,i)+(i~=j)*(IP+GSF*(ProbBi2(i,j)))+ybar_tj(t,j);                
            end
            [P_acc(t,j),S_prev(t,j)]=max(temp1);
            P_acc(t,j)=P_acc(t,j);%+ybar_tj(t,j); 
        end
    end
    PH=[]; PH=zeros(T,1);
    %%% Total-Prob
    [Ptot,PH(end)]=max(P_acc(end,:));
    for t=T-1:-1:1 % frame
        PH(t)=S_prev(t+1,PH(t+1));
    end    
    %--------------------------------------------------------------------------
    %Emit repeated Vaj
    VajTestFilteredFinal=[];
    j=1; i=1;
    VajTestFilteredFinal(j)=PH(i);
    for i=2:size(VajTestFiltered,2)
        if (PH(i)~=VajTestFilteredFinal(j))
            j=j+1; VajTestFilteredFinal(j)=PH(i);
        end
    end
    %--------------------------------------------------------------------------
    VajGold=[];
    j=1; i=1;
    load(GoldFilePath);
    VajGold(j)=Vaj(i);
    for i=2:size(TestOut,1)
        %silence=TestTags.total.index(i)
        if (Vaj(i)~=VajGold(j))
            j=j+1;
            VajGold(j)=Vaj(i);
        end
    end
    %--------------------------------------------------------------------------
    
    
    %------------new !!!!
    % Emit Basts
    VajTestFilteredFinal2=[]; j=0;
    for i=1:size(VajTestFilteredFinal,2)
        if VajTestFilteredFinal(i)<=30
            j=j+1;
            VajTestFilteredFinal2(j)=VajTestFilteredFinal(i);
        end
    end
    
    
    
    %--------------------------------------------------------------------------
    A=['@','a','e','o','u','i','y','l','m','n','r','b','d','q','g','?','p','t','k','j','#','f','v','s','z','$','*','h','x','-'];
    VajGoldCharactor=[]; clear ('VajGoldCharactor')
    VajTestCharactor=[]; clear ('VajTestCharactor')
    VajGoldCharactor(1:size(VajGold,2))=A(VajGold(1:size(VajGold,2)));
    %VajTestCharactor(1:size(VajTestFilteredFinal,2))=A(VajTestFilteredFinal(1:size(VajTestFilteredFinal,2)));
    VajTestCharactor(1:size(VajTestFilteredFinal2,2))=A(VajTestFilteredFinal2(1:size(VajTestFilteredFinal2,2)));
    Error(ntest)=lev(VajGoldCharactor,VajTestCharactor)/length(VajGold)
    %--------------------------------------------------------------------------
end %ntest=1:length(SmalFarsdatTestNames)
100-mean(Error)*100










