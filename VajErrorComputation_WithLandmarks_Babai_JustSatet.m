clc,clear all,close all

WithoutTwoRepeatedSetences=1; %!!!!!!!!!!!!!!!!!!!!!!!!
load('LandmarkType3_Events.mat')
LandmarksType3=mat2str(LandmarkType3_Events);
LandmarksType3(1)=';'; LandmarksType3(end)=';';

mainpath='D:\Shapar\ShaghayeghUni\AfterPropozal\Step1-EventLandmark\Programs\MyPrograms\EventExtraction';
load([mainpath,'\TestBabaiName.mat']);
load('I30.mat')

fid=fopen('RecognizedPhonesOut.txt','w');
for ntest=1:length(TestBabaiName)
    NameTest=TestBabaiName(ntest)
    %-------------------------------------------------------------------------
    NetOutputFile=['D:\Shapar\ShaghayeghUni\AfterPropozal\RunCNTK\SoftOut-BabiData\tempTest\Net_',num2str(NameTest),'.txt.HLast'];
    GoldFilePath=[mainpath,'\Vaj\Vaj',num2str(NameTest),'.mat'];
    LandmarkPath=[mainpath,'\Landmarks\Landmarks',num2str(NameTest),'.mat'];
    load(GoldFilePath);
    load(LandmarkPath);
     TestOut=textread(NetOutputFile);
    %-------------------
    if WithoutTwoRepeatedSetences==1
        NN=num2str(NameTest);
        if NN(1)=='2'
            IndexOfSen405=I30(ntest,9);
            Vaj(IndexOfSen405:end)=[];
            TestOut(IndexOfSen405:end,:)=[];
        end 
    end
    %--------------------------------------------------------------------------   
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
        %elseif indxx(i)>30 && indxx(i)<103 &&  Aindx(i)==2
         %   TestTags.total.flag(i)='b';
        else
            TestTags.total.flag(i)='n';
        end
    end
    %--------------------------------------------------------------------------
    % Talfigh etelaate 'b' va 's', tahiye tavali landmark (landmark chain)
    VajTest=[]; VajTestFlag=[];
    j=1; VajTest{1}=0;  VajTestFlag{j}='s';
    %k=0; CountSilence(1:size(TestOut,1))=0;
    for i=1:size(TestOut,1)
        if TestTags.total.flag(i)=='s'
            if  VajTestFlag{j}=='s' && TestTags.state.index(i)~=VajTest{j}
                j=j+1; VajTest{j}=TestTags.state.index(i);
            elseif VajTestFlag{j}=='b'
                j=j+1; VajTest{j}=TestTags.state.index(i);
                %elseif VajTestFlag{j}=='s' && TestTags.state.index(i)==VajTest{j} %&& VajTest{j}==30
                %    CountSilence(j)=CountSilence(j)+1;
            end
            VajTestFlag{j}='s';
        end
        if TestTags.total.flag(i)=='b'
            if VajTestFlag{j}=='s'
                j=j+1;  VajTest{j}=[TestTags.event.indexpart1(i),TestTags.event.indexpart2(i)];
            elseif (VajTestFlag{j}=='b'   && TestTags.event.indexpart1(i)~=VajTest{j}(1) && TestTags.event.indexpart2(i)~=VajTest{j}(2))
                j=j+1;  VajTest{j}=[TestTags.event.indexpart1(i),TestTags.event.indexpart2(i)];
            end
            VajTestFlag{j}='b';
        end
    end
    %CountSilence(j+1:end)=[];
    %--------------------------------------------------------------------------
    VajTestFiltered=VajTest;
    
    %Emit repeated Vaj
    VajTestFilteredFinal=[];
    j=1; i=1;
    VajTestFilteredFinal(j)=VajTestFiltered{i};
    for i=2:size(VajTestFiltered,2)
        if (VajTestFiltered{i}~=VajTestFilteredFinal(j))
            j=j+1; VajTestFilteredFinal(j)=VajTestFiltered{i};
        end
    end
    %--------------------------------------------------------------------------
    VajGold=[];
    j=1; i=1;
    load(GoldFilePath);
    VajGold(j)=Vaj(i);
    for i=2:size(TestOut,1)
        if (Vaj(i)~=VajGold(j))
            j=j+1;
            VajGold(j)=Vaj(i);
        end
    end
    %--------------------------------------
    % Emit Basts
    VajTestFilteredFinal2=[]; j=0;
    for i=1:size(VajTestFilteredFinal,2)
        if VajTestFilteredFinal(i)<=30 && VajTestFilteredFinal(i)>0
            j=j+1;
            VajTestFilteredFinal2(j)=VajTestFilteredFinal(i);
        end
    end
    %-----------------------------------
    VajTestFilteredFinal=[];
    j=1; i=1;
    VajTestFilteredFinal(j)=VajTestFilteredFinal2(i);
    for i=2:size(VajTestFilteredFinal2,2)
        if (VajTestFilteredFinal2(i)~=VajTestFilteredFinal(j))
            j=j+1; VajTestFilteredFinal(j)=VajTestFilteredFinal2(i);
        end
    end
    VajTestFilteredFinal2=VajTestFilteredFinal;
    %--------------------------------------------------------------------------
   
    
    %--------------------------------------------------------------------------
    A=['@','a','e','o','u','i','y','l','m','n','r','b','d','q','g','?','p','t','k','j','#','f','v','s','z','$','*','h','x','-'];
    %A=['@','a','e','o','u','i','y','l','m','n','r','b','d','q','g','?','p','t','k','j','#','f','v','s','z','$','*','h','x'];
    VajGoldCharactor=[]; clear ('VajGoldCharactor')
    VajTestCharactor=[]; clear ('VajTestCharactor')
    VajGoldCharactor(1:size(VajGold,2))=A(VajGold(1:size(VajGold,2)));
    %VajTestCharactor(1:size(VajTestFilteredFinal,2))=A(VajTestFilteredFinal(1:size(VajTestFilteredFinal,2)));
    VajTestCharactor(1:size(VajTestFilteredFinal2,2))=A(VajTestFilteredFinal2(1:size(VajTestFilteredFinal2,2)));
    Error(ntest)=lev(VajGoldCharactor,VajTestCharactor)/length(VajGold);
    %--------------------------------------------------------------------------
end %ntest=1:length(SmalFarsdatTestNames)
mm=mean(Error)*100
