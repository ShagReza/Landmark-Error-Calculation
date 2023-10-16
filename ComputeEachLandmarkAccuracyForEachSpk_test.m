
        % Compute each landmark accuracy for each speaker
        %---------------------------------------------------

%for i=1:numfiles
%load file name (train)
% load gold file
%load landmark name
%Compute output of file
%for i=1:Nfile  count and index each frame with landmark
% COunt true identification of each landmark
% write results whit name and index of landmark
%finally make a list and do it for all test files
% do train files seperately and follow all above steps
%Its better to do with Alloutone not Soft Out!!!!
%--------------------------------------------------------------------------l



%--------------------------------------------------------------------------l
clc,clear all,close all
NetOutputFile='Net_1298.txt.HLast';
LandmarkPath='D:\ShaghayeghUni\AfterPropozal\Step1-EventLandmark\Programs\MyPrograms\EventExtraction\Landmarks\Landmarks1298.mat';
load(LandmarkPath);
GoldLandmarks=Landmarks.EventStateTag_LandmarksType3;
load('LandmarkType3_Events.mat');
%--------------------------------------------------------------------------l



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
NumLandmarksStates(1:30)=0;
TrueIdentifiedLandmarksStates(1:30)=0;
NumLandmarksEvents(1:size(LandmarkType3_Events,1))=0;
TrueIdentifiedLandmarksEvents(1:size(LandmarkType3_Events,1))=0;
for i=1:size(GoldLandmarks,2)
    if GoldLandmarks{1,i}=='s'
        NumLandmarksStates(GoldLandmarks{3,i})=NumLandmarksStates(GoldLandmarks{3,i})+1;
        if TestTags.total.flag(i)=='s' && TestTags.state.index(i)==GoldLandmarks{3,i}
            TrueIdentifiedLandmarksStates(GoldLandmarks{3,i})=TrueIdentifiedLandmarksStates(GoldLandmarks{3,i})+1;
        end
    elseif GoldLandmarks{1,i}=='e'
        for j=1:size(LandmarkType3_Events,1)
            if LandmarkType3_Events(j,1)==GoldLandmarks{3,i}{1,1}{1,1}  && LandmarkType3_Events(j,2)==GoldLandmarks{3,i}{1,1}{1,2}
                NumLandmarksEvents(j)=NumLandmarksEvents(j)+1;
                Jindex=j;
            end
        end
        if TestTags.total.flag(i)=='b' && TestTags.event.indexpart1(i)==LandmarkType3_Events(Jindex,1) && TestTags.event.indexpart2(i)==LandmarkType3_Events(Jindex,2)
            TrueIdentifiedLandmarksEvents(Jindex)=TrueIdentifiedLandmarksEvents(Jindex)+1;
        end
    end
end

%--------------------------------------------------------------------------

EachLandmarkAccuracy{1}.name='1298';
EachLandmarkAccuracy{1}.NumLandmarksStates=NumLandmarksStates;
EachLandmarkAccuracy{1}.TrueIdentifiedLandmarksStates=TrueIdentifiedLandmarksStates;
EachLandmarkAccuracy{1}.PercentState=TrueIdentifiedLandmarksStates./(NumLandmarksStates+0.000001);
EachLandmarkAccuracy{1}.NumLandmarksEvents=NumLandmarksEvents;
EachLandmarkAccuracy{1}.TrueIdentifiedLandmarksEvents=TrueIdentifiedLandmarksEvents;
EachLandmarkAccuracy{1}.PercentEvent=TrueIdentifiedLandmarksEvents./(NumLandmarksEvents+0.000001);

%--------------------------------------------------------------------------
% % Writing Results
% fid=fopen('EachLandmarkAccuracyForEachSpeaker.txt','w');
% Name='dddd'; %!!!!!!!!!!!!
% fprintf(fid,'SpeakerName: %s\n',Name);
% for i=1:30
%     if NumLandmarksStates(i)>0
%         fprintf(fid,'State[%d]:%.2f, ',i,TrueIdentifiedLandmarksStates(i)/NumLandmarksStates(i));
%     else
%        fprintf(fid,'State [%d]:%s','NotExist');
%     end
% end
% fclose(fid);
%--------------------------------------------------------------------------





