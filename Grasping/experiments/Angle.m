function [y,z,tr2,tr3,t1,t2,t3,t4,go]=Angle(ObjectID,Ox,Oy,Oz,Tx,Tz)

%% calculate the object location with respect to the base of hand
%test_point=[2;-1;2;1];
GT_point=[2;2;0;1];
Point_Old=[Ox;Oy;Oz;1];
fprintf('x: %.3f y: %.3f z: %.3f under camera coordinate system\n',Point_Old(1,1),Point_Old(2,1),Point_Old(3,1));


% Trans_Z=[0,1,0,0;-1,0,0,0;0,0,1,0;0,0,0,1];
% Trans_Y=[cos(2*pi/3),0,-sin(2*pi/3),0;0,1,0,0;sin(2*pi/3),0,cos(2*pi/3),0;0,0,0,1];
% Trans=[1,0,0,0;0,1,0,0;0,0,1,0,;Tx,0.02,Tz,1];
% New1=Point_Old*Trans_Z;
% New2=New1*Trans_Y;
% New3=New2*Trans;
Trans_Z=[0,1,0,0;-1,0,0,0;0,0,1,0;0,0,0,1];
Trans_Y=[cos(2*pi/3),0,sin(2*pi/3),0;0,1,0,0;-sin(2*pi/3),0,cos(2*pi/3),0;0,0,0,1];
Trans=[1,0,0,-0.125;0,1,0,0.02;0,0,1,0.27;0,0,0,1];
New1=Trans_Z*Point_Old;
New2=Trans_Y*New1;
New3=Trans*New2;
Point_New=New3;
%% calculate the angles
Point_New(1,1)=Point_New(1,1);
Point_New(3,1)=Point_New(3,1)+0.07;%-0.16;
Point_New(2,1)=Point_New(2,1)-0.02;
if ObjectID==4
Point_New(1,1)=Point_New(1,1)+0.05;
Point_New(3,1)=Point_New(3,1)-0.02;%-0.16;
Point_New(2,1)=Point_New(2,1)-0.04;
end
fprintf('x: %.3f y: %.3f z: %.3f under World coordinate system\n',Point_New(1,1),Point_New(2,1),Point_New(3,1));
t1=atan(Point_New(2,1)/Point_New(1,1));
 syms x y;
  R1=((Point_New(1,1)+0.04)^2+Point_New(2,1)^2)^(1/2);
  R2=Point_New(3,1);

 Height=Point_New(3,1)-0.09;
 z=Point_New(3,1);
 y=Point_New(2,1);
 if Height<0
    inverse=1;
 elseif Height>=0
    inverse=0;
 end
Length=R1-0.04*(3^(1/2));
d=Height^2+Length^2+0.0008;    %%
fprintf( 'd is :%.4f\n',d );
D=(0.173^2+0.188^2-d)/(2*0.173*0.188);
if D^2>=1
    go=1;
     t1=0;
     fprintf( 'Cannot reach!!!' );
 tr2=0;
 tr3=0;    
 t2=0;
 t3=0;
 t4=0;
else 
    go=0;

T_temp1=atan2(((1-D^2)^(1/2)),D);
X(1,1)=pi-T_temp1;
Beta=atan2(Height,Length);
Alpha=atan2(0.188*sin(X(1,1)),0.173+0.188*cos(X(1,1)));
Y(1,1)=Beta+Alpha;
if inverse==1;
    Y(1,1)=Beta+Alpha-pi/6;
elseif inverse==0
    Y(1,1)=Y(1,1)-(pi/6);
end 
s=0;

     if (d>=0.04)&&(d<=0.14)
        s=1;
        go=0;
     else
         s=0;
         go=1;
     end
 if s==0
     fprintf( 'Cannot reach!!!' );
     t1=0;
     t2=0;
     t3=0;
     t4=0;
     tr2=0;
     tr3=0;
 else
     %% calculate ready position
    LengthR=Length-0.05;
    HeightR=Height+0.06;
    if ObjectID==4
        LengthR=Length;
        HeightR=Height+0.06;
    end
    d2=HeightR^2+LengthR^2+0.0008;    %%
    D2=(0.173^2+0.188^2-d2)/(2*0.173*0.188);
    T_temp2=atan2(((1-D2^2)^(1/2)),D2);
    X2(1,1)=pi-T_temp2;
    Beta2=atan2(HeightR,LengthR);
    Alpha2=atan2(0.188*sin(X2(1,1)),0.173+0.188*cos(X2(1,1)));
    Y2(1,1)=Beta2+Alpha2;
    if inverse==1;
        Y2(1,1)=Beta2+Alpha2-pi/6;
    elseif inverse==0
        Y2(1,1)=Y2(1,1)-(pi/6);
    end 
    tr2=Y2(1,1)/pi*180;
    tr3=X2(1,1)/pi*180;
    if tr3<=-99
        tr3=-99;
    elseif tr3>99
        tr3=99;
    end
    t3=X(s,1);
    t2=Y(s,1)/pi*180;
    t4=0;
    t1=-t1/pi*180;
    t3=t3/pi*180;
    if t3>99
        t3=99;
    elseif t3<-99
        t3=-99;
    end
 end
end

end