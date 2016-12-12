function [kuang2,pass]=rotate1(imagename,kuang,Angle)
img=imread(imagename);

Angle=Angle/180*pi;
%%
[m,n,hc] = size(img);  
s=1;
figure(1);
imshow(img);
kuang=kuang.*s;
 rectangle('Position',[kuang(1,1),kuang(1,2),kuang(1,3)-kuang(1,1),kuang(1,6)-kuang(1,2)],'LineWidth',4,'EdgeColor','r');
 test=[959;539;1];
T2 = [1,0,-n/2;0,1,-m/2;0,0,1];  %x、y轴平移值原点  
T3 = [1,0,n/2;0,1,m/2;0,0,1];    %x、y轴反平移  
   
T1 = [cos(Angle),sin(Angle),0;-sin(Angle),cos(Angle),0;0,0,1];%旋转变换  
T = T3*T1*T2;                  %P_new = P_old*T2*T1*T3  顺序不能错了 
M1=T*[kuang(1,1);kuang(1,2);1];
M2=T*[kuang(1,3);kuang(1,4);1];
M3=T*[kuang(1,5);kuang(1,6);1];
M4=T*[kuang(1,7);kuang(1,8);1];

x=[M1(1,1),M2(1,1),M3(1,1),M4(1,1)];
y=[M1(2,1),M2(2,1),M3(2,1),M4(2,1)];
kuang2=[min(x),min(y),max(x),max(y)]; 
if min(x)<0||min(y)<0||max(x)>n||max(y)>m
    pass=0;
    kuang2=[0,0,0,0];
else
    pass=1;
    kuang2=[min(x),min(y),max(x),max(y)]; 
end
end