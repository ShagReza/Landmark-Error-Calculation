clc,clear all,close all

WithoutTwoRepeatedSetences=1; %!!!!!!!!!!!!!!!!!!!!!!!!
load('LandmarkType3_Events.mat')
LandmarksType3=mat2str(LandmarkType3_Events);
LandmarksType3(1)=';'; LandmarksType3(end)=';';

mainpath='D:\Shapar\ShaghayeghUni\AfterPropozal\Step1-EventLandmark\Programs\MyPrograms\EventExtraction';
load([mainpath,'\TestBabaiName.mat']);
Error=[];
bb=0;
I=zeros(60,10);
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
    for X=1:60
        j=0; k=0; I30=[];
        for i=1:length(Vaj)-1
            if Vaj(i)==30 && Vaj(i+1)==30
                k=k+1;
            elseif Vaj(i)==30 && Vaj(i+1)~=30 && k>X
                j=j+1; I30(j)=i+1;
            else
                k=0;
            end
        end
        if length(I30)==10
            'ooooo'
            X=60;
            break
        end
    end
    if length(I30)==10
        I(ntest,1:10)=I30;
    end
end



%File 15/ 1125
I15=[143,431,632,931,1281,1931,2380,2594,2943,3294];
I(15,:)=I15;
%File 37/1225
I37=[136,261,459,697,1009,1217,1609,1746,1926,2404];
I(37,:)=I37;
%File 46
I46=[214,557,907,1146,1468,1886,2196,2489,3139,3390];
I(46,:)=I46;



I30=I;
save('I30','I30');



