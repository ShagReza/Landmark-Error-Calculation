
        % Compute each landmark accuracy for each speaker
        %---------------------------------------------------


clc,clear all,close all
load('LandmarkType3_Events.mat');



%--------------------------------------------------------------------------
NetOutputFile='NetTrain.txt.HLast';
load('IndexTrain.mat')
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
%--------------
for i=1:size(TestOut,1)
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
LandmarkPath='D:\ShaghayeghUni\AfterPropozal\Step1-EventLandmark\Programs\MyPrograms\EventExtraction\Landmarks';
load('SmalFarsdatTrainNames_train.mat');
Index1=0;Index2=0; x=0;
for k=1:length(SmalFarsdatTrainNames_train)
    k
    NameTrain=SmalFarsdatTrainNames_train(k);
    load([LandmarkPath,'\Landmarks',NameTrain{1,1},'.mat']);
    GoldLandmarks=Landmarks.EventStateTag_LandmarksType3;
    Index1=Index2+1;
    Index2=IndexTrain(k);
    %     TrainFlag= !!(Index1:Index2);
    %     TrainState=!!(Index1:Index2);
    %     TrainEventPart1=!!(Index1:Index2);
    %     TrainEventPart2=!!(Index1:Index2);
    %------------
    
    NumLandmarksStates(1:30)=0;
    TrueIdentifiedLandmarksStates(1:30)=0;
    NumLandmarksEvents(1:size(LandmarkType3_Events,1))=0;
    TrueIdentifiedLandmarksEvents(1:size(LandmarkType3_Events,1))=0;
    for i=1:size(GoldLandmarks,2)
        if GoldLandmarks{1,i}=='s'
            x=x+1;
            NumLandmarksStates(GoldLandmarks{3,i})=NumLandmarksStates(GoldLandmarks{3,i})+1;
            if TestTags.total.flag(x)=='s' && TestTags.state.index(x)==GoldLandmarks{3,i}
                TrueIdentifiedLandmarksStates(GoldLandmarks{3,i})=TrueIdentifiedLandmarksStates(GoldLandmarks{3,i})+1;
            end
        elseif GoldLandmarks{1,i}=='e'
            x=x+1;
            for j=1:size(LandmarkType3_Events,1)
                if LandmarkType3_Events(j,1)==GoldLandmarks{3,i}{1,1}{1,1}  && LandmarkType3_Events(j,2)==GoldLandmarks{3,i}{1,1}{1,2}
                    NumLandmarksEvents(j)=NumLandmarksEvents(j)+1;
                    Jindex=j;
                end
            end
            if TestTags.total.flag(x)=='b' && TestTags.event.indexpart1(x)==LandmarkType3_Events(Jindex,1) && TestTags.event.indexpart2(x)==LandmarkType3_Events(Jindex,2)
                TrueIdentifiedLandmarksEvents(Jindex)=TrueIdentifiedLandmarksEvents(Jindex)+1;
            end
        elseif GoldLandmarks{1,i}=='n'
             x=x+1;
        end
    end
    %-----------------
    EachLandmarkAccuracy{k}.name=NameTrain;
    EachLandmarkAccuracy{k}.NumLandmarksStates=NumLandmarksStates;
    EachLandmarkAccuracy{k}.TrueIdentifiedLandmarksStates=TrueIdentifiedLandmarksStates;
    EachLandmarkAccuracy{k}.PercentState=TrueIdentifiedLandmarksStates./(NumLandmarksStates+0.000001);
    EachLandmarkAccuracy{k}.NumLandmarksEvents=NumLandmarksEvents;
    EachLandmarkAccuracy{k}.TrueIdentifiedLandmarksEvents=TrueIdentifiedLandmarksEvents;
    EachLandmarkAccuracy{k}.PercentEvent=TrueIdentifiedLandmarksEvents./(NumLandmarksEvents+0.000001);
end
save('EachLandmarkAccuracy','EachLandmarkAccuracy');
%--------------------------------------------------------------------------
% % Writing Results
fid=fopen('EachLandmarkAccuracyForEachSpeaker.txt','w');
for k=1:183%length(SmalFarsdatTrainNames_train)
    NameTrain=SmalFarsdatTrainNames_train(k);
    fprintf(fid,'\n\nSpeakerName: %s\n',NameTrain{1,1});
    fprintf(fid,'MeanState:%.2f,         ',mean((EachLandmarkAccuracy{1,k}.PercentState+EachLandmarkAccuracy{1,k+297}.PercentState)/2)); 
    for i=1:30      
        fprintf(fid,'State[%d]:%.2f, ',i,((EachLandmarkAccuracy{1,k}.PercentState(i)+EachLandmarkAccuracy{1,k+297}.PercentState(i))/2));        
    end
end

for k=1:183%length(SmalFarsdatTrainNames_train)
    NameTrain=SmalFarsdatTrainNames_train(k);
    fprintf(fid,'\n\nSpeakerName: %s\n',NameTrain{1,1});
    A=(EachLandmarkAccuracy{1,k}.PercentEvent+EachLandmarkAccuracy{1,k+297}.PercentEvent)/2;
    a=find(A~=0);
    fprintf(fid,'MeanEvent:%.2f,         ',mean(A(a))); 
    for i=1:276      
        fprintf(fid,'Event[%d]:%.2f, ',i,((EachLandmarkAccuracy{1,k}.PercentEvent(i)+EachLandmarkAccuracy{1,k+297}.PercentEvent(i))/2));        
    end
end
fclose(fid);
%--------------------------------------------------------------------------





