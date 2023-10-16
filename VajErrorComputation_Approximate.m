%----------------------------------------
%--- Vaj Error Computation:
%----------------------------------------

clc,clear all,close all
mainpath='D:\ShaghayeghUni\AfterPropozal\Step1-EventLandmark\Programs\MyPrograms\EventExtraction';
load([mainpath,'\SmalFarsdatTestNames.mat']);
for ntest=1:length(SmalFarsdatTestNames)
    NameTest=SmalFarsdatTestNames{ntest}
    %-------------------------------------------------------------------------
    NetOutputFile=[mainpath,'\ErrorComputation\Error-labelType1\AllOutOne_TrainWithCntk_LabelType1ValidationType1LandmarkType2_NonLandmarkTag\tempTest\Net_',NameTest,'.txt.HLast'];
    GoldFilePath=[mainpath,'\Vaj\Vaj',NameTest,'.mat'];
    LandmarkPath=[mainpath,'\Landmarks\Landmarks',NameTest,'.mat'];
    load(GoldFilePath);
    load(LandmarkPath);
    %--------------------------------------------------------------------------
    Thr=-1000;
    Thr2=0.1;
    
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
    
    
    
    %--------------------------------------------------------------------------
    % Calculating approximate frame accuracy with 'n'
    % 'n' stands for not a landmark
    for i=1:size(TestOut,1)
        if indxx(i)<31 && Aindx(i)==1 && maxx(i)>Thr
            TestTags.total.flag(i)='s';
            TestTags.total.index(i)=indxx(i);
        elseif indxx(i)>30 && indxx(i)<103 && maxx(i)>Thr &&  Aindx(i)==2 && maxpart1(i)>Thr2 && maxpart2(i)>Thr2
            TestTags.total.flag(i)='b';
            if  maxpart1(i)>maxpart2(i)
                TestTags.total.index(i)=indexpart1(i);
            else
                TestTags.total.index(i)=indexpart2(i);
            end
        else
            TestTags.total.flag(i)='n';
            TestTags.total.index(i)=0;
        end
    end
    find (TestTags.total.index==Vaj);
    length(ans)/length(Vaj)
    find (TestTags.total.index==Landmarks.labels);
    length(ans)/length(Vaj)
    %--------------------------------------------------------------------------
    
    
    
    %--------------------------------------------------------------------------
    % Calculating approximate frame accuracy without 'n'
    % 'n' stands for not a landmark
    [Amax,Aindx]=max([maxpart0;aa]);
    for i=1:size(TestOut,1)
        if indxx(i)<31
            TestTags.total.flag2(i)='s';
            TestTags.total.index2(i)=indxx(i);
        else
            TestTags.total.flag2(i)='b';
            if  maxpart1(i)>maxpart2(i)
                TestTags.total.index2(i)=indexpart1(i);
            else
                TestTags.total.index2(i)=indexpart2(i);
            end
        end
    end
    find (TestTags.total.index2==Vaj);
    length(ans)/length(Vaj)
    find (TestTags.total.index2==Landmarks.labels);
    length(ans)/length(Vaj)
    %--------------------------------------------------------------------------
    
    
    
    
    %--------------------------------------------------------------------------
    % Calculating Vaj Error rate:
    
    
    % 1:Emiting Small Silence:
    TestTags2=[]; j=0;
    for i=3:size(TestOut,1)-2
        A=TestTags.total.index(i-1)==30 && TestTags.total.index(i+1)==30;
        B=TestTags.total.index(i+1)==30 && TestTags.total.index(i+2)==30;
        C=TestTags.total.index(i-1)==30 && TestTags.total.index(i-2)==30;
        
        if TestTags.total.index(i)==30
            if A || B || C
                'Big Silence';
                j=j+1; TestTags2(j)=TestTags.total.index(i);
            else
                'Small Silence';
                j=j+1; TestTags2(j)=0;
            end
        else
            j=j+1; TestTags2(j)=TestTags.total.index(i);
        end
    end
    TestTags2=[TestTags.total.index(1),TestTags.total.index(2),TestTags2,TestTags.total.index(end-1),TestTags.total.index(end)];
    
    
    % 2:Emiting each Vaj which is just one frame
    TestTags3=[]; j=1; TestTags3(1)=TestTags2(1);
    for i=2:size(TestOut,1)-1
        if (TestTags2(i)~=TestTags2(i+1)) && (TestTags2(i)~=TestTags2(i-1))
            j=j+1; TestTags3(j)=0;
        else
            j=j+1; TestTags3(j)=TestTags2(i);
        end
    end
    TestTags3(j+1)=TestTags2(j+1);
    %TestTags3=TestTags2;
    
    
    % 3: Emiting non landmark parts and Bast'ha and repeated Vaj
    VajTest=[];
    j=1; i=1; VajTest(j)=TestTags3(i);
    for i=2:size(TestOut,1)
        if (TestTags3(i)~=0) && (TestTags3(i)~=VajTest(j)) && (TestTags3(i)<31)
            j=j+1;
            VajTest(j)=TestTags3(i);
        end
    end
    
    % % Emiting 'n' and repeated vaj
    % VajTest=[];
    % j=1; i=1; VajTest(j)=TestTags.total.index(i);
    % for i=2:size(TestOut,1)
    %     %silence=TestTags.total.index(i)
    %     if (TestTags.total.index(i)~=0) && (TestTags.total.index(i)~=VajTest(j)) && (TestTags.total.index(i)<31)
    %         j=j+1;
    %         VajTest(j)=TestTags.total.index(i);
    %     end
    % end
    %
    VajGold=[];
    j=1; i=1; VajGold(j)=Landmarks.labels(i);
    for i=2:size(TestOut,1)
        %silence=TestTags.total.index(i)
        if (Landmarks.labels(i)~=0) && (Landmarks.labels(i)~=VajGold(j)) && (Landmarks.labels(i)<31)
            j=j+1;
            VajGold(j)=Landmarks.labels(i);
        end
    end
    %--------------------------------------------------------------------------
      
    
    
    %--------------------------------------------------------------------------
    A=['@','a','e','o','u','i','y','l','m','n','r','b','d','q','g','?','p','t','k','j','#','f','v','s','z','$','*','h','x','-'];
    VajGoldCharactor=[];
    VajTestCharactor=[];
    VajGoldCharactor(1:size(VajGold,2))=A(VajGold(1:size(VajGold,2)));
    VajTestCharactor(1:size(VajTest,2))=A(VajTest(1:size(VajTest,2)));
    Error(ntest)=lev(VajGoldCharactor,VajTestCharactor)/length(VajGold);
    %--------------------------------------------------------------------------   
end

PhoneAccuracyRateMean=100-100*mean(Error)



