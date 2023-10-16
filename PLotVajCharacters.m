
 A=Landmarks.EventStateTag_LandmarksType3(2,:);
 A=cell2mat(A);
 C=Landmarks.labels;
 D=['@','a','e','o','u','i','y','l','m','n','r','b','d','q','g','?','p','t','k','j','#','f','v','s','z','$','*','h','x','-','1','2','3','4','5','6'];
 CC=D(C);
 
 M=(Landmarks.EventStateTag_LandmarksType3);
 
 j=0;
 St=[];
 Ev=[];
 for i=260:290
     j=j+1;
     if A(i)>0.5 && strcmp(M{1,i},'s')
         hold on,plot(j,A(i),'*b')
         St(j)=A(i);
         Ev(j)=0.5;
     elseif A(i)>0.5 && strcmp(M{1,i},'e')
         hold on,plot(j,A(i),'<r')
         Ev(j)=A(i);
         St(j)=0.5; 
     else
        Ev(j)=0.5; 
        St(j)=0.5;
     end
     hold on,text(j,1.02,CC(i))
 end
 
i=1:31
 hold on,plot(i,St,'-*b')
  hold on,plot(i,Ev,'-<r')
  ylim([0.45 1.05])