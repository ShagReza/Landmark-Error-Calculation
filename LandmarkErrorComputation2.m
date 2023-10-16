
% Landmark Error Computation
clc,clear all,close all
%--------------------------------------------------------------------------
Name='AllOutOne_TrainWithCntk_LabelType1ValidationType1LandmarkType2_NonLandmarkTag';
Thr=-1000;
Thr2=-1000
TestFile=[Name,'\Net.txt(test).HLast'];
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
 part2=TestOut(:,31:66);
[maxpart1,indexpart1]=max(part2');
part3=TestOut(:,67:102);
[maxpart2,indexpart2]=max(part3');

for i=1:size(TestOut,1)
    if indxx(i)<31 && maxx(i)>Thr
        TestTags.state.flag(i)='s';
        TestTags.state.index(i)=indxx(i);
    else
        TestTags.state.index(i)=0;
        TestTags.state.flag(i)='n'; 
    end
    
    if indxx(i)>30 && indxx(i)<103 && maxx(i)>Thr
        TestTags.event.flag(i)='b';
        TestTags.event.indexpart1(i)=indexpart1(i);
        TestTags.event.indexpart2(i)=indexpart2(i);
    else
        TestTags.event.flag(i)='n'; 
        TestTags.event.indexpart1(i)=0;
        TestTags.event.indexpart2(i)=0;
    end
    
    if indxx(i)<31 && maxx(i)>Thr
        TestTags.total.flag(i)='s';
    elseif indxx(i)>30 && indxx(i)<103 && maxx(i)>Thr && maxpart1(i)>Thr2 && maxpart2(i)>Thr2
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
resultFile=[Name,'\result_landmark_ErComp2.txt'];
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


