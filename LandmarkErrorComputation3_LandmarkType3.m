
% Landmark Error Computation
clc,clear all,close all
%--------------------------------------------------------------------------
Name='AllOutOne_TrainWithCntk_LabelType1ValidationType1LandmarkType3_NonLandmarkTag';
Thr=-1000;
Thr2=0.1;
TestFile=[Name,'\Net.txt.HLast'];
CorrectLabelsFile=[Name,'\LblLandmark_Test_All.txt'];
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
TestOut=textread(TestFile);
GoldLabels=textread(CorrectLabelsFile); 
GoldLabels(:,end)=[]; %chera 103 ta khande mishavad????!!!!
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Target Labels:
GoldTags=[];
part1=GoldLabels(:,1:30); 
[GoldTags.state.max,GoldTags.state.index]=max(part1');
 part2=GoldLabels(:,31:66);
[GoldTags.event.maxpart1,GoldTags.event.part1]=max(part2');
part3=GoldLabels(:,67:102);
[GoldTags.event.maxpart2,GoldTags.event.part2]=max(part3');
for i=1:size(GoldLabels,1)
    if GoldTags.state.max(i)==0, GoldTags.state.index(i)=0; GoldTags.state.flag(i)='n';
    else GoldTags.state.flag(i)='s'; end;
   
    if GoldTags.event.maxpart1(i)==0, GoldTags.event.part1(i)=0; GoldTags.event.part2(i)=0; GoldTags.event.flag(i)='n';
    else GoldTags.event.flag(i)='b'; end;
    
    if (GoldTags.state.max(i)==0 &&  GoldTags.event.maxpart1(i)==0)
        GoldTags.total.flag(i)='n';
    elseif GoldTags.state.max(i)~=0, GoldTags.total.flag(i)='s';
    else GoldTags.total.flag(i)='b';
    end
end
%--------------------------------------------------------------------------




%--------------------------------------------------------------------------
% Test Labels:
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
%[Amax2,Aindx2]=max([maxpart0; max([maxpart1;maxpart2]);TestOut(:,103)']);

for i=1:size(TestOut,1)
%     if indxx(i)<31  && maxx(i)>Thr && Aindx(i)==1
%         Amax(i),Aindx(i),maxx(i),indxx(i)
%     end
    if indxx(i)<31  && maxx(i)>Thr && Aindx(i)==1
        TestTags.state.flag(i)='s';
        TestTags.state.index(i)=indxx(i);
    else
        TestTags.state.index(i)=0;
        TestTags.state.flag(i)='n'; 
    end
    
    if indxx(i)>30 && indxx(i)<103 && Aindx(i)==2  && maxx(i)>Thr && maxpart1(i)>Thr2 && maxpart2(i)>Thr2
        TestTags.event.flag(i)='b';
        TestTags.event.indexpart1(i)=indexpart1(i);
        TestTags.event.indexpart2(i)=indexpart2(i);
    else
        TestTags.event.flag(i)='n'; 
        TestTags.event.indexpart1(i)=0;
        TestTags.event.indexpart2(i)=0;
    end
    
    if indxx(i)<31 && Aindx(i)==1 && maxx(i)>Thr 
        TestTags.total.flag(i)='s';
    elseif indxx(i)>30 && indxx(i)<103 && maxx(i)>Thr &&  Aindx(i)==2 && maxpart1(i)>Thr2 && maxpart2(i)>Thr2
        TestTags.total.flag(i)='b';
    else
        TestTags.total.flag(i)='n';
    end
end
%--------------------------------------------------------------------------





%--------------------------------------------------------------------------
% Error Measures (State):
 Nstate=0; NnonState=0; nTA=0; nFA=0; nTI=0; Nstate2(1:30)=0; nTI2(1:30)=0;
for i=1:size(TestOut,1)
    if GoldTags.state.flag(i)=='s'
        Nstate=Nstate+1;
        Nstate2(GoldTags.state.index(i))=Nstate2(GoldTags.state.index(i))+1;
        if TestTags.state.flag(i)=='s'
            nTA=nTA+1;
            if GoldTags.state.index(i)==TestTags.state.index(i)
                nTI=nTI+1;
                nTI2(GoldTags.state.index(i))=nTI2(GoldTags.state.index(i))+1;
            end
        end
    end
    if GoldTags.state.flag(i)=='n'
        NnonState=NnonState+1;
       if TestTags.state.flag(i)=='s'
            nFA=nFA+1;
        end
    end
end
TrueIdent_state=nTI/Nstate*100;
TrueIdent_state2=nTI2./Nstate2*100;
TrueIdentTotal_state=(nTI+(NnonState-nFA))/size(TestOut,1)*100;
FalseAccept_state=nFA/size(TestOut,1)*100;
FalseReject_state=(Nstate-nTA)/size(TestOut,1)*100;
FalseIdent_state=(nTA-nTI)/size(TestOut,1)*100;
resultFile=[Name,'\result_landmark_ErComp3.txt'];
fid=fopen(resultFile,'w');
fprintf(fid, 'Result (State) \n\n');
fprintf(fid, 'Threshold: %f\n',Thr);
fprintf(fid, 'TrueIdent_state: %f\n',TrueIdent_state);
fprintf(fid, 'TrueIdentTotal_state: %f\n',TrueIdentTotal_state);
fprintf(fid, 'FalseAccept_state: %f\n',FalseAccept_state);
fprintf(fid, 'FalseReject_state: %f\n',FalseReject_state);
fprintf(fid, 'FalseIdent_state: %f\n',FalseIdent_state);

fprintf(fid, ' \nIdentification of each state\n');
for i=1:30
fprintf(fid, 'i: %d nTI2(i): %d Nstate2(i): %d TrueIdent_state2(i): %f\n',i,nTI2(i),Nstate2(i),TrueIdent_state2(i));
end
%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
% Error Measures (event):
 Nevent=0; Nnonevent=0; nTA=0; nFA=0; nTI=0; %Nevent2(1:30)=0; nTI2(1:30)=0;
for i=1:size(TestOut,1)
    if GoldTags.event.flag(i)=='b'
        Nevent=Nevent+1;
       % Nevent2(GoldTags.event.index(i))=Nevent2(GoldTags.event.index(i))+1;
        if TestTags.event.flag(i)=='b'
            nTA=nTA+1;
            if (GoldTags.event.part1(i)==TestTags.event.indexpart1(i)) && (GoldTags.event.part2(i)==TestTags.event.indexpart2(i))
                nTI=nTI+1;
                %nTI2(GoldTags.event.index(i))=nTI2(GoldTags.event.index(i))+1;
            end
        end
    end
    if GoldTags.event.flag(i)=='n'
        Nnonevent=Nnonevent+1;
       if TestTags.event.flag(i)=='b'
            nFA=nFA+1;
        end
    end
end
TrueIdent_event=nTI/Nevent*100;
%TrueIdent_event2=nTI2./Nevent2*100;
TrueIdentTotal_event=(nTI+(Nnonevent-nFA))/size(TestOut,1)*100;
FalseAccept_event=nFA/size(TestOut,1)*100;
FalseReject_event=(Nevent-nTA)/size(TestOut,1)*100;
FalseIdent_event=(nTA-nTI)/size(TestOut,1)*100;
%fid=fopen('result_landmark.txt','w');
fprintf(fid, 'Result (event) \n\n');
fprintf(fid, 'Threshold: %f\n',Thr);
fprintf(fid, 'TrueIdent_event: %f\n',TrueIdent_event);
fprintf(fid, 'TrueIdentTotal_event: %f\n',TrueIdentTotal_event);
fprintf(fid, 'FalseAccept_event: %f\n',FalseAccept_event);
fprintf(fid, 'FalseReject_event: %f\n',FalseReject_event);
fprintf(fid, 'FalseIdent_event: %f\n',FalseIdent_event);

% fprintf(fid, ' \nIdentification of each event\n');
% for i=1:30
% fprintf(fid, 'i: %d nTI2(i): %d Nevent2(i): %d TrueIdent_event2(i): %f\n',i,nTI2(i),Nevent2(i),TrueIdent_event2(i));
% end

%--------------------------------------------------------------------------








%--------------------------------------------------------------------------
% Error Measures (landmark):
 Nlandmark=0; Nnonlandmark=0; nTA=0; nFA=0; nTI=0; %Nlandmark2(1:30)=0; nTI2(1:30)=0;
for i=1:size(TestOut,1)
    if GoldTags.total.flag(i)=='b' || GoldTags.total.flag(i)=='s'
        Nlandmark=Nlandmark+1;
        if (TestTags.total.flag(i)=='b') && (GoldTags.total.flag(i)=='b')
            nTA=nTA+1;
            if (GoldTags.event.part1(i)==TestTags.event.indexpart1(i)) && (GoldTags.event.part2(i)==TestTags.event.indexpart2(i))
                nTI=nTI+1;
            end
        end
        if (TestTags.total.flag(i)=='s') && (GoldTags.total.flag(i)=='s')
            nTA=nTA+1;
            if GoldTags.state.index(i)==TestTags.state.index(i)
                nTI=nTI+1;
            end
        end
    end
    if GoldTags.total.flag(i)=='n'
        Nnonlandmark=Nnonlandmark+1;
       if (TestTags.total.flag(i)=='b') || (TestTags.total.flag(i)=='s')
            nFA=nFA+1;
        end
    end
end
TrueIdent_landmark=nTI/Nlandmark*100;
%TrueIdent_landmark2=nTI2./Nlandmark2*100;
TrueIdentTotal_landmark=(nTI+(Nnonlandmark-nFA))/size(TestOut,1)*100;
FalseAccept_landmark=nFA/size(TestOut,1)*100;
FalseReject_landmark=(Nlandmark-nTA)/size(TestOut,1)*100;
FalseIdent_landmark=(nTA-nTI)/size(TestOut,1)*100;
%fid=fopen('result_landmark.txt','w');
fprintf(fid, 'Result (landmark) \n\n');
fprintf(fid, 'Threshold: %f\n',Thr);
fprintf(fid, 'TrueIdent_landmark: %f\n',TrueIdent_landmark);
fprintf(fid, 'TrueIdentTotal_landmark: %f\n',TrueIdentTotal_landmark);
fprintf(fid, 'FalseAccept_landmark: %f\n',FalseAccept_landmark);
fprintf(fid, 'FalseReject_landmark: %f\n',FalseReject_landmark);
fprintf(fid, 'FalseIdent_landmark: %f\n',FalseIdent_landmark);

% fprintf(fid, ' \nIdentification of each landmark\n');
% for i=1:30
% fprintf(fid, 'i: %d nTI2(i): %d Nlandmark2(i): %d TrueIdent_landmark2(i): %f\n',i,nTI2(i),Nlandmark2(i),TrueIdent_landmark2(i));
% end

fclose(fid);
%--------------------------------------------------------------------------







%--------------------------------------------------------------------------
                        % Draw a Confusion Matrix
                        
%Gold                       
load('LandmarkType3_Events.mat');
GoldTagsLandmarkname=[];
GoldTagsLandmarkname2(307,size(TestOut,1))=0;

for i=1:size(TestOut,1)
    if GoldTags.total.flag(i)=='n'
        GoldTagsLandmarkname(i)=307;
        GoldTagsLandmarkname2(307,i)=1;

    elseif GoldTags.total.flag(i)=='s'
        GoldTagsLandmarkname(i)= GoldTags.state.index(i);
        GoldTagsLandmarkname2(GoldTags.state.index(i),i)=1;
    elseif  GoldTags.total.flag(i)=='b'
        for k=1:276
            if GoldTags.event.part1(i)==LandmarkType3_Events(k,1) && GoldTags.event.part2(i)==LandmarkType3_Events(k,2)
                GoldTagsLandmarkname(i)=k+30;
                GoldTagsLandmarkname2(k+30,i)=1;
            end
        end
    end
end

%Test:
TestTagsLandmarkname=[];
TestTagsLandmarkname2(307,size(TestOut,1))=0;
for i=1:size(TestOut,1)
    if  TestTags.total.flag(i)=='b'
%         for k=1:276
%             if TestTags.event.indexpart1(i)==LandmarkType3_Events(k,1) && TestTags.event.indexpart2(i)==LandmarkType3_Events(k,2)
%                 k
%                 TestTagsLandmarkname(i)=k+30;
%                 TestTagsLandmarkname2(k+30,i)=1;
%             else
%                 TestTagsLandmarkname(i)=307;
%                 TestTagsLandmarkname2(307,i)=1;
%             end
%         end
        BorderFlag=0;
        for k=1:276
            if TestTags.event.indexpart1(i)==LandmarkType3_Events(k,1) && TestTags.event.indexpart2(i)==LandmarkType3_Events(k,2)
                BorderFlag=k;
            end
        end
        if BorderFlag>0
            k=BorderFlag;
            TestTagsLandmarkname(i)=k+30;
            TestTagsLandmarkname2(k+30,i)=1;
        else
            TestTagsLandmarkname(i)=307;
            TestTagsLandmarkname2(307,i)=1;
        end

    elseif TestTags.total.flag(i)=='s'
        TestTagsLandmarkname(i)= TestTags.state.index(i);
        TestTagsLandmarkname2(TestTags.state.index(i),i)=1;
    else
        TestTagsLandmarkname(i)=307;
        TestTagsLandmarkname2(307,i)=1;
    end;
end


[Conf1,Conf2]=confusionmat(GoldTagsLandmarkname,TestTagsLandmarkname);
%plotconfusion(GoldTagsLandmarkname2,TestTagsLandmarkname2);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
SS={'@','a','e','o','u','i','y','l','m','n','r','b','d','q','g','?','p','t','k','j','#','f','v','s','z','$','*','h','x','^'};
BB={'1','2','3','4','5','6'};
SB={'@','a','e','o','u','i','y','l','m','n','r','b','d','q','g','?','p','t','k','j','#','f','v','s','z','$','*','h','x','^','1','2','3','4','5','6'};
for i=1:30
    LL{i}=SS(i);
end
for i=31:306
    LL{i}=strcat(SB(LandmarkType3_Events(i-30,1)), SB(LandmarkType3_Events(i-30,2)));
end
LL{307}={'NN'};

result=[]; fid=fopen([Name,'\confusionText.txt'],'w');
for i=1:size(Conf1,1)
    r1=find(Conf1(i,:)~=0);
    r2=Conf1(i,r1); [r2,b]=sort(r2,'descend');
    r1=r1(b);
    NumLandmark=Conf2(i);
    result{NumLandmark}=[r1;r2];
    fprintf(fid,'\n\n\n---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n');
    fprintf(fid,'%d --> %s   N: %d\n',Conf2(i),cell2mat(LL{NumLandmark}),sum(r2));
    NumberOfLandmarks(Conf2(i))=sum(r2);
    for j=1:length(r1)
        %fprintf(fid,'%s:%d,  ',cell2mat(LL{Conf2(r1(j))}),r2(j));
        fprintf(fid,'%s:%f,  ',cell2mat(LL{Conf2(r1(j))}),r2(j)/sum(r2));
    end   
    fprintf(fid,'\n-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n');
end
fclose(fid)
%--------------------------------------------------------------------------





% %--------------------------------------------------------------------------
% % 307 Landmarks.txt
% fid=fopen('307Landmarks.txt','w');
% for i=1:307
%     fprintf(fid,'%d --> %s\n',i,cell2mat(LL{i}));
%     %fprintf(fid,'%s\n',cell2mat(LL{i}));
% end 
% fclose(fid)
% %--------------------------------------------------------------------------



% %--------------------------------------------------------------------------
% Empty=[];
% for i=1:307
%     a=find(GoldTagsLandmarkname==i);
%     if length(a)==0
%         Empty=[Empty,i];
%     end
% end
% %--------------------------------------------------------------------------





% %--------------------------------------------------------------------------
% % Index Of True Identified data:
% j=0; IndexTrueIdentifiedData=[]; 
% NumberOfTRueIdent(1:307)=0;
% thr=0.1;
% x=0; IndexTrueIdentifiedData_thr=[];
% NumberOfTRueIdent_thr(1:307)=0;
% IndexOfEachLandmark=[];
% AmaxOfEachLandmark=[];
% n=0; nII(1:30)=0; Nk(1:276)=0;
% for i=1:size(TestOut,1)
%     i
%     if (TestTags.total.flag(i)=='b') && (GoldTags.total.flag(i)=='b')
%         if (GoldTags.event.part1(i)==TestTags.event.indexpart1(i)) && (GoldTags.event.part2(i)==TestTags.event.indexpart2(i))
%             j=j+1; IndexTrueIdentifiedData(j)=i;
%             if Amax(i)>thr,
%                 x=x+1; IndexTrueIdentifiedData_thr(x)=i;
%                 for k=1:276
%                     if TestTags.event.indexpart1(i)==LandmarkType3_Events(k,1) && TestTags.event.indexpart2(i)==LandmarkType3_Events(k,2)
%                         NumberOfTRueIdent_thr(k+30)=NumberOfTRueIdent_thr(k+30)+1;
%                         Nk(k)=Nk(k)+1;
%                         IndexOfEachLandmark(k+30,Nk(k))=i;
%                         AmaxOfEachLandmark(k+30,Nk(k))=Amax(i);
%                     end
%                 end
%             end
%             for k=1:276
%                 if TestTags.event.indexpart1(i)==LandmarkType3_Events(k,1) && TestTags.event.indexpart2(i)==LandmarkType3_Events(k,2)
%                     NumberOfTRueIdent(k+30)=NumberOfTRueIdent(k+30)+1;
%                 end
%             end
%         end
%     end
%     if (TestTags.total.flag(i)=='s') && (GoldTags.total.flag(i)=='s')
%         if GoldTags.state.index(i)==TestTags.state.index(i)
%             j=j+1; IndexTrueIdentifiedData(j)=i;
%             II=TestTags.state.index(i);
%             NumberOfTRueIdent(II)=NumberOfTRueIdent(II)+1;
%             if Amax(i)>thr
%                 x=x+1; IndexTrueIdentifiedData_thr(x)=i;
%                 NumberOfTRueIdent_thr(II)=NumberOfTRueIdent_thr(II)+1;
%                 nII(II)=nII(II)+1;
%                 IndexOfEachLandmark(II,nII(II))=i;
%                 AmaxOfEachLandmark(II,nII(II))=Amax(i);
%             end
%         end
%     end
%     if GoldTags.total.flag(i)=='n' && TestTags.total.flag(i)=='n'
%         j=j+1;   IndexTrueIdentifiedData(j)=i;
%         NumberOfTRueIdent(307)=NumberOfTRueIdent(307)+1;
%         if Amax(i)>thr
%             x=x+1; IndexTrueIdentifiedData_thr(x)=i;
%             NumberOfTRueIdent_thr(307)=NumberOfTRueIdent_thr(307)+1;
%             n=n+1;
%             IndexOfEachLandmark(307,n)=i;
%             AmaxOfEachLandmark(307,n)=Amax(i);
%         end
%     end
% end 
% save('IndexTrueIdentifiedData','IndexTrueIdentifiedData');
% save('IndexOfEachLandmark','IndexOfEachLandmark');
% save('AmaxOfEachLandmark','AmaxOfEachLandmark');
% 
% %--------------------------------------------------------------------------
% 
% 
