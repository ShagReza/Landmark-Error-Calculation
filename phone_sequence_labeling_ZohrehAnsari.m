%% find phoneme sequence from frame lables using viterbi 
clc
close all
clear all

load RECOG%% RECOG is a cell matrix that each cell contains the output of the network for each frame (each frame in a context). teach row of this matrix relate to one test utterance.

load TransitionMatrix
Transition=Transition./repmat(sum(Transition,2),1,35);  %np=35;


%%
IP=-1;%-2; % Insertion Penalty
GSF=1; %0.0; % Grammer Scale Factor

%%

np = 35;% number of output neurons

% ProbBi1=zeros(np,np)+1/np;
eps=10^-6;
ProbBi1=Transition;
ProbBi2=log(ProbBi1+eps);
% ProbBi2=TransitionMatrix;


eps=10^-6;
SF_36_Phones = {'@','a','e','o','u','i','y','l','m','n','r','b','d','q','g','?','p','t','k','j','#','f','v','s','z','$','*','h','x',',','^','=','+','-','~'} ;
% SF_36_Phones = {'@','a','e','o','u','i','y','l','m','n','r','b','d','q','g','?','p','t','k','j','#','f','v','s','z','$','*','h','x',',','^'} ;
ZT=[1:29,33 33 32 33 34 35 34 32 33 35 30 19 35 15 35 37 30 30 30 30 38];ZT=[ZT,30*ones(1,48)];
ZT([59 60 65 93])=[30 60 30 37];
ZTB=[32 33 34 35 34 32 33 35 33 33];  %bdqg?ptkj#
% ZT=[1:29,20 21 12 13 14 15 16 17 18 19 30 19 19 15 15];ZT=[ZT,30*ones(1,45)];

CS=['@aeouiylmnrbdqg?ptkj#fvsz$*hx ^=+-~CA_'];
CSS=['@aeouiylmnrbdqg?ptkj#fvsz$*hx,^=+-~CA_'];

ACCM = zeros( np , np ) ;
rmdir('Recog_Phones','s');
mkdir('Recog_Phones');

rmdir('Label_Phones','s');
mkdir('Label_Phones');

for n_test = 1 : length(RECOG),
    fidii=fopen(['Recog_Phones/Phones',num2str(n_test),'.rec'],'w');
    
    y_tj=RECOG{n_test,:};
    y_tj=y_tj(:,1:end-1);
%     y_tj= y_tj+abs(repmat(min(y_tj,[],2),1,np)); % making all positive
    y_tj= y_tj./repmat(sum(y_tj,2),1,np);% make them probability
    ybar_tj=log(y_tj);
    
    P_acc = zeros(size(ybar_tj));
    
    %%% t=1 (for first frame)
    P_acc(1,:)=ybar_tj(1,:);
    
    %%% t>1 (for other frames)
    S_prev = zeros(size(ybar_tj));
    T=size(ybar_tj,1);
    for t=2:T, % frame

        for j=1:np, % index of phoneme
            temp1=zeros(1,np);
            for i=1:np,
                temp1(i)=P_acc(t-1,i)+(i~=j)*(IP+GSF*(ProbBi2(i,j)))+ybar_tj(t,j);                
            end
            [P_acc(t,j),S_prev(t,j)]=max(temp1);
            P_acc(t,j)=P_acc(t,j);%+ybar_tj(t,j); 
        end
    end
    PH=zeros(T,1);
    %%% Total-Prob
    [Ptot,PH(end)]=max(P_acc(end,:));
    for t=T-1:-1:1, % frame
        PH(t)=S_prev(t+1,PH(t+1));
    end    
   
    fprintf(fidii,',\n');
    fprintf(fidii,'%s\n', SF_36_Phones{PH(1)});
    for hh=2:size(PH,1),
        if PH(hh)~=PH(hh-1),
            fprintf(fidii,'%s\n', SF_36_Phones{PH(hh)});
        end
    end
    fprintf(fidii,',\n');
    fclose(fidii);
    
%     fprintf('file number (%d) of total (%d) files: %s\n',n_test,length(file_list),strrep(file_list(n_test,1).name,files_extension,'rec'));
end
fclose all
jj=1;
for sno=298:304
    sno
    for sec=1:2
%         if jj1==1
%             if SEC(sno-297)==1
%                 sec=2;
%             else
%                 sec=1;
%             end
%         else
%             sec=SEC(sno-297);
%         end
        eval(['load LHCB/LHCB',num2str(sec),num2str(sno)])
        eval(['load LBL/Z',num2str(sec),num2str(sno)])
        Z=ZT(Z);
        fidout=fopen(['Label_Phones/Phones',num2str(jj),'.lab'],'w');
        fprintf(fidout,'%s\n',CSS(Z(1)));
        for i=12:length(Z)-11
            if Z(i+1)~=Z(i)
                fprintf(fidout,'%s\n',CSS(Z(i)));
            end
        end
        jj=jj+1;
        fclose(fidout);
    end
end
!/usr/local/bin/HResults -T 1 -I Lab1_phone.mlf PhnList.txt -S RecList_phone.txt> Logs/NetPref.txt
% fido=fopen('Logs/NetPref.txt','r');
% fidi=fopen('Logs/NetPref.txt','w');
% p=fread(fido);
% fwrite(fidi,p);
% fclose(fido);
% fclose(fidi);