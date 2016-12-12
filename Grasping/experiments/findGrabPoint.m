function [tim,GrabPoint,ready]=findGrabPoint(datas,img,dept,Heig,width,center,ObjectID)
ready=0;
dept2=reshape(dept(:,3),[640,480]);
dept3=dept2';
tic;
P=0;
t=0;
if ObjectID==4
    bowlarea=dept3(round((datas(1,2)+(datas(1,4)-datas(1,2))/10)*2):round((datas(1,4)-(datas(1,4)-datas(1,2))/10)*2),round((datas(1,1)+(datas(1,3)-datas(1,1))/10)*2):round((datas(1,3)-(datas(1,3)-datas(1,1))/10)*2));
    bowlarea(isnan(bowlarea))=5;
    [a,b]=min(bowlarea);
    edd=zeros(size(bowlarea));
%     figure
%     imshow(bowlarea);
    Coo=[1+round((datas(1,1)+(datas(1,3)-datas(1,1))/10)*2):length(a)+round((datas(1,1)+(datas(1,3)-datas(1,1))/10)*2)];
    Coo2=b+round((datas(1,2)+(datas(1,4)-datas(1,2))/10)*2);
    
    Q2=center;
    Q1=[320,480];
    for ax=1:1:length(b)        
%             edd(b(ax),ax)=1;
%             P=[ax+round((datas(1,1)+(datas(1,1)-datas(1,2))/10)*2),b(ax)+round((datas(1,2)+(datas(1,2)-datas(1,4))/10)*2)];
%             d(ax)=abs(det([Q2-Q1;P-Q1]))/norm(Q2-Q1);
%             if abs(a(ax)-a(floor(length(a)/2)))<=0.2
%                 d(ax)=10000;
%             end
        P=[Coo(ax),Coo2(ax)];
        d(ax)=abs(det([Q2-Q1;P-Q1]))/norm(Q2-Q1);
        if abs(a(ax)-a(floor(length(a)/2)))>0.2
               d(ax)=10000;
        end
    end
    [aa,bb]=min(d);
%     figure
%     imshow(edd);
%     figure 
%     imshow(dept3);
    hold on
    plot(Coo,Coo2,'r.');
    hold on
    plot(320,480,'r.');
    hold off
%     rectangle('Position',[round(datas(1,1))*2,round(datas(1,2))*2,width*2,Heig*2],'EdgeColor','red');
    GrabPoint=[Coo(bb),Coo2(bb)];
    ready=1;
    tim=0;
    t=toc;
    figure 
    imshow(img);
    hold on
    plot(GrabPoint(1,1),GrabPoint(1,2),'r.');
    hold on
    plot(center(1,1),center(1,2),'r.');
    hold on
    text(double(center(1,1)),double(center(1,2)),'BBox Center');
    hold on
end
if ObjectID==1
%     img2=img((center(1,2)-20):(center(1,2)+20),(floor(center(1,1)-width)):(floor(center(1,1)+width)));
%     img2=medfilt2(img2,[3 3]);
%     img3=medfilt2(img,[3 3]);
%     BW2=edge(img3,'sobel','vertical');
%     BW1=edge(img2,'sobel','vertical');
%     figure(2);
%     imshow(BW1);
%     figure(3);
%     imshow(BW2);
%     rectangle('Position', [center(1,1)-floor(width) center(1,2)-20 floor(2*width) 40],'EdgeColor','red');
%     GrabPoint=[1,1];
      P=0;
%       for j=floor(width):-1:floor(4*width/5)
%           if ~isnan(dept((center(1,2)-1)*640+center(1,1)+j))
%               xx=dept((center(1,2)-1)*640+center(1,1)+j)-dept((center(1,2)-1)*640+center(1,1)-30);
%               if abs(xx)<0.10
%                   P=j;
%                   break;
%               end
%           end
%       end
      %% left or right
      a1=dept(((center(1,2)-1)*640+center(1,1)):((center(1,2)-1)*640+center(1,1)+floor(width/2)),3);
      a2=dept(((center(1,2)-1)*640+center(1,1)-floor(width/2)):((center(1,2)-1)*640+center(1,1)),3);
      a1(isnan(a1))=5;
      a2(isnan(a2))=5;
      x1=find(a1<1);
      x2=find(a2<1);
      if length(x1)<length(x2)%sum(a1)-sum(a2)<=0
        x=dept((center(1,2)-1)*640+center(1,1)+floor(1*width/2):(center(1,2)-1)*640+center(1,1)+floor(width),3);
        x(isnan(x))=[5];
        [Y,I]=min(x);
        acer=I+floor(1*width/2);
        P=acer(1);
      elseif length(x1)>length(x2)%sum(a1)-sum(a2)>0
        x=dept((center(1,2)-1)*640+center(1,1)-floor(width):(center(1,2)-1)*640+center(1,1)-floor(width/2),3);    
        x(isnan(x))=[5];
        [Y,I]=min(x);
        acer=-floor(1*width/2)-(floor(width/2)-I);
        P=acer(1);
      end
      
      if P==0
        ready=0;
        GrabPoint=[1,1];
      else
          ready=1;
        GrabPoint=[center(1,2),center(1,1)+P];
        GrabPoint=[GrabPoint(1,2),GrabPoint(1,1)];
        t=toc;
        fprintf('time for finding point is %d\n',t);
%         figure(2);
%         imshow(dept3);
%         rectangle('Position', [center(1,1)+P-20,center(1,2)-20,40,40],'EdgeColor','red');
%         text(center(1,1)+P-20,center(1,2)-20);
%         figure(3);
%         imshow(img);
        rectangle('Position', [center(1,1)+P-20,center(1,2)-20,40,40],'EdgeColor','red');
      end
% elseif ObjectID==4
%     P=0;
%     jj1=((center(1,2)-1)-floor(Heig*0.5))*640+center(1,1):640:((center(1,2)-1)+floor(Heig*0.5))*640+center(1,1);    
%     a3=dept(jj1,3);
%     a3(isnan(a3))=5;
%     [Y1,I1]=min(a3);
%     acer=I1-floor(length(a3)/2);
%     P=acer(1);
%     ready=1;
%     GrabPoint=[center(1,2)+P,center(1,1)];
%             t=toc;
% fprintf('time for finding point is %d\n',t);
% %     figure(2);
% %     imshow(dept3);
% %     rectangle('Position', [center(1,1),center(1,2)+P-20,40,40],'EdgeColor','red');
% %     figure(3);
% %     imshow(img);
%     rectangle('Position', [center(1,1),center(1,2)+P-20,40,40],'EdgeColor','red');
elseif ObjectID==2||ObjectID==5||ObjectID==6
    x=dept((center(1,2)-1)*640+center(1,1)-floor(width/2):(center(1,2)-1)*640+center(1,1)+floor(width/2),3);  
    x(isnan(x))=[5];
    acer=find(x==min(x))-floor(width/2);
    P=acer(1);
    GrabPoint=[center(1,2),center(1,1)+P];
    ready=1;
    t=toc;
end
tim=t;
end