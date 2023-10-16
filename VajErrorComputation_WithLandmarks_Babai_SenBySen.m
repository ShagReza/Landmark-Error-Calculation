clc,clear all,close all

WithoutTwoRepeatedSetences=1; %!!!!!!!!!!!!!!!!!!!!!!!!
load('LandmarkType3_Events.mat')
LandmarksType3=mat2str(LandmarkType3_Events);
LandmarksType3(1)=';'; LandmarksType3(end)=';';

mainpath='D:\Shapar\ShaghayeghUni\AfterPropozal\MyPrograms\EventExtraction';
load([mainpath,'\TestBabaiName.mat']);
load('I30.mat')
II=I30;
I30=[];

Error=[];
bb=0;

fid=fopen('RecognizedPhonesOut.txt','w');


for ntest=1:length(TestBabaiName)
    NameTest=TestBabaiName(ntest)
    %-------------------------------------------------------------------------
    %Cntk:
    %NetOutputFile=['D:\Shapar\ShaghayeghUni\AfterPropozal\RunCNTK\SoftOut-BabiData\context7_norm3\tempTest\Net_',num2str(NameTest),'.txt.HLast'];
    %TestOut=textread(NetOutputFile);
    %keras:
    TestOut=load(['D:\Shapar\ShaghayeghUni\AfterPropozal\MyPrograms\EventExtraction\Keras\TestOut\',num2str(NameTest),'.mat']);
    TestOut=TestOut.lbl;
    %----
    GoldFilePath=[mainpath,'\Vaj\Vaj',num2str(NameTest),'.mat'];
    LandmarkPath=[mainpath,'\Landmarks\Landmarks',num2str(NameTest),'.mat'];
    load(GoldFilePath);
    load(LandmarkPath);
    %-------------------
    %     if WithoutTwoRepeatedSetences==1             
    %         j=0; k=0; I30=[];
    %         for i=1:length(Vaj)-1
    %             if Vaj(i)==30 && Vaj(i+1)==30
    %                 k=k+1;
    %             elseif Vaj(i)==30 && Vaj(i+1)~=30 && k>21
    %                 j=j+1; I30(j)=i+1;
    %             else
    %                 k=0;
    %             end
    %         end
    %         
    %         NN=num2str(NameTest); 
    %         if NN(1)=='2'
    %             Vaj(I30(9):end)=[];
    %             TestOut(I30(9):end,:)=[];
    %             I30_9=I30(9);
    %             I30(9:10)=[];
    %         end
    %     end
    %--------------------------------------------------------------------------   
     if WithoutTwoRepeatedSetences==1
        NN=num2str(NameTest);
        I30=[];
        I30=II(ntest,:);
        if NN(1)=='2'          
            IndexOfSen405=II(ntest,9);
            Vaj(IndexOfSen405:end)=[];
            TestOut(IndexOfSen405:end,:)=[];
            I30_9=IndexOfSen405;
            I30(9:10)=[];
        end 
     end
    %---------------------------------------------------
    TestOut2=TestOut;
    Vaj2=Vaj;
    I30(1)=0;
    if NN(1)=='2', E=I30_9; 
    else E=length(Vaj);
    end
    
    I30=[I30,E];
    for hh=1:length(I30)-1
        hh
         ss= I30(hh)+1;
        ee=I30(hh+1)-1;
        TestOut=TestOut2(ss:ee,:);
        Vaj= Vaj2(ss:ee);

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
        elseif indxx(i)>30 && indxx(i)<103 &&  Aindx(i)==2
            TestTags.total.flag(i)='b';
        else
            TestTags.total.flag(i)='n';
        end
    end
    %     %--------------------------------------------------------------------------
    %     for i=1:size(TestOut,1)
    %         if indxx(i)<31  && maxx(i)>Thr && Aindx(i)==1
    %             TestTags.state.flag(i)='s';
    %             TestTags.state.index(i)=indxx(i);
    %         else
    %             TestTags.state.index(i)=0;
    %             TestTags.state.flag(i)='n';
    %         end
    %
    %         if indxx(i)>30 && indxx(i)<103 && Aindx(i)==2  && maxx(i)>Thr && maxpart1(i)>Thr2 && maxpart2(i)>Thr2
    %             TestTags.event.flag(i)='b';
    %             TestTags.event.indexpart1(i)=indexpart1(i);
    %             TestTags.event.indexpart2(i)=indexpart2(i);
    %         else
    %             TestTags.event.flag(i)='n';
    %             TestTags.event.indexpart1(i)=0;
    %             TestTags.event.indexpart2(i)=0;
    %         end
    %
    %         if indxx(i)<31 && Aindx(i)==1 && maxx(i)>Thr
    %             TestTags.total.flag(i)='s';
    %         elseif indxx(i)>30 && indxx(i)<103 && maxx(i)>Thr &&  Aindx(i)==2 && maxpart1(i)>Thr2 && maxpart2(i)>Thr2
    %             TestTags.total.flag(i)='b';
    %         else
    %             TestTags.total.flag(i)='n';
    %         end
    %     end
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
    %--------------------------------------------------------------------------
    %         %Filter non landmarks (17-1-2020)
    %         VajTest2=[]; VajTestFlag2=[]; NonLandmarksFlag(1:length(VajTestFlag))=0;  ii=0;
    %         for i=1: length(VajTestFlag)
    %             if  strcmp(VajTestFlag(i),'b')
    %                 A=mat2str(cell2mat(VajTest(i))); A(1)=';'; A(end)=';';
    %                 if isempty(strfind(LandmarksType3,A))==0
    %                     ii=ii+1;
    %                     VajTest2{ii}=VajTest{i};
    %                     VajTestFlag2{ii}=VajTestFlag{i};
    %                 end
    %             else
    %                 ii=ii+1;
    %                 VajTest2{ii}=VajTest{i};
    %                 VajTestFlag2{ii}=VajTestFlag{i};
    %             end
    %         end
    %          VajTestFlag= VajTestFlag2;
    %          VajTest=VajTest2;
    %     %---------------------------------------------------------------------
    %---------------------------------------------------------------------
    
    %filtering landmark Chain
    VajTestFiltered=[]; j=1;
    if  VajTestFlag{2}=='s', VajTestFiltered{j}=VajTest{2};
    else  VajTestFiltered{j}=VajTest{2}(1);
    end
    
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
            
            if (VajTestFlag{i-1}=='s' && VajTestFlag{i+1}=='s') && (VajTest{i}==VajTest{i-1} || VajTest{i}==VajTest{i+1} || VajTest{i-1}==30),j=j+1; VajTestFiltered{j}=VajTest{i}; end
            if (VajTestFlag{i-1}=='b' && VajTestFlag{i+1}=='b') && (VajTest{i}==VajTest{i-1}(2) || VajTest{i}==VajTest{i+1}(1) || VajTest{i-1}(2)==30 || C==1),j=j+1; VajTestFiltered{j}=VajTest{i}; end
            if (VajTestFlag{i-1}=='s' && VajTestFlag{i+1}=='b') && (VajTest{i}==VajTest{i-1} || VajTest{i}==VajTest{i+1}(1) || VajTest{i-1}==30),j=j+1; VajTestFiltered{j}=VajTest{i}; end
            if (VajTestFlag{i-1}=='b' && VajTestFlag{i+1}=='s') && (VajTest{i}==VajTest{i-1}(2) || VajTest{i}==VajTest{i+1} || VajTest{i-1}(2)==30 || C==1),j=j+1; VajTestFiltered{j}=VajTest{i}; end
            
            %Don't emit sokot states
            if (VajTest{i}==30),j=j+1; VajTestFiltered{j}=VajTest{i}; end
        else
            %Bast-Burst
            C=0;
            if (VajTestFlag{i-1}=='b' && VajTest{i-1}(2)>30)
                A=VajTest{i}(1); B=VajTest{i-1}(2); C=0;
                if  (B== 31 &&  (A==13 || A==18))  ||(B== 32 &&  (A==12 || A==17)) || (B== 33 &&  (A==15 || A==19)) || (B== 34 &&  A==14) || (B== 35 && A==16) || (B== 36 &&  (A==20 || A==21))
                    C=1;
                end
            end
            if (VajTestFlag{i-1}=='s' && (VajTest{i}(1)==VajTest{i-1} || VajTest{i-1}==30)), j=j+1; VajTestFiltered{j}=VajTest{i}(1); end
            if (VajTestFlag{i-1}=='b' && (VajTest{i}(1)==VajTest{i-1}(2) || VajTest{i-1}(2)==30) || C==1), j=j+1; VajTestFiltered{j}=VajTest{i}(1); end
            if (VajTestFlag{i+1}=='s' && VajTest{i}(2)==VajTest{i+1}), j=j+1; VajTestFiltered{j}=VajTest{i}(2); end
            if (VajTestFlag{i+1}=='b' && VajTest{i}(2)==VajTest{i+1}(1)), j=j+1; VajTestFiltered{j}=VajTest{i}(2); end
        end
    end
    j=j+1; VajTestFiltered{j}=VajTest{i+1}(1);
    
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
    %---------

    %--------------------------------------------------------------------------
    
    
    
    
 
    %--------------------------------------------------------------------------
    A=['@','a','e','o','u','i','y','l','m','n','r','b','d','q','g','?','p','t','k','j','#','f','v','s','z','$','*','h','x','-'];
    %A=['@','a','e','o','u','i','y','l','m','n','r','b','d','q','g','?','p','t','k','j','#','f','v','s','z','$','*','h','x'];
    VajGoldCharactor=[]; clear ('VajGoldCharactor')
    VajTestCharactor=[]; clear ('VajTestCharactor')
    VajGoldCharactor(1:size(VajGold,2))=A(VajGold(1:size(VajGold,2)));
    %VajTestCharactor(1:size(VajTestFilteredFinal,2))=A(VajTestFilteredFinal(1:size(VajTestFilteredFinal,2)));
    VajTestCharactor(1:size(VajTestFilteredFinal2,2))=A(VajTestFilteredFinal2(1:size(VajTestFilteredFinal2,2)));
    bb=bb+1;
    Error(bb)=lev(VajGoldCharactor,VajTestCharactor)/length(VajGold);
    VajGoldCharactor,VajTestCharactor,length(VajGold)
    
    fprintf(fid,'NameTest:%s    Sentence:%s\n',num2str(NameTest),num2str(hh));
    StringOut=[VajGoldCharactor,'             ',VajTestCharactor];
    fprintf(fid,StringOut);
    fprintf(fid,'\n---------------------------------------------------------------------------------------------\n');
    end
    %--------------------------------------------------------------------------
end %ntest=1:length(SmalFarsdatTestNames)
mm=mean(Error)*100

fclose(fid)



