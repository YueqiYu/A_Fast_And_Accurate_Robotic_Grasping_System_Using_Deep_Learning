clc;
clear;
txtpath='Cup2\Data.txt';%txt文件
ImgPathN='Cup2\';%修改后的xml保存文件夹
%foldername='VOC2007';
Angle=-3;
fir=num2str(Angle);
ImageP='Annotations4\';
fidin=fopen(txtpath,'r');
lastname='begin';
SavedP='Train\';
s=7800;
zz=1;
name='.jpg';
while ~feof(fidin)
     tline=fgetl(fidin);
%      if i==1
%          tline=tline(1,4:end);
%      end
     
     str = regexp(tline,' ','split');
     imagename=[ImgPathN,str{1}];
     img=imread(imagename);
     kuang=[str2double(str{3}),str2double(str{4}),str2double(str{5}),str2double(str{4}),str2double(str{3}),str2double(str{6}),str2double(str{5}),str2double(str{6})];
     [kuang2,pass]=rotate1(imagename,kuang,Angle);
     str{3}=num2str(floor(kuang2(1)));
     str{4}=num2str(floor(kuang2(2)));
     str{5}=num2str(floor(kuang2(3)));
     str{6}=num2str(floor(kuang2(4)));
     pass1=1;
     pass1=pass1&pass;
     if size(str,2)>6
            nu=floor((size(str,2)-6)/5);
            for i=1:1:nu
            kuang=[str2double(str{5*i+3}),str2double(str{5*i+4}),str2double(str{5*i+5}),str2double(str{5*i+4}),str2double(str{5*i+3}),str2double(str{5*i+6}),str2double(str{5*i+5}),str2double(str{5*i+6})]; 
            [kuang2,pass]=rotate1(imagename,kuang,Angle);
            str{5*i+3}=num2str(floor(kuang2(1)));
            str{5*i+4}=num2str(floor(kuang2(2)));
            str{5*i+5}=num2str(floor(kuang2(3)));
            str{5*i+6}=num2str(floor(kuang2(4)));
            pass1=pass1&pass;
            end
     end
      
     if pass1==1
        s=s+1;
        
        tline2=['00',num2str(s),'.jpg'];
        for z=1:1:length(str)-1
        tline2=[tline2,' ',str{z+1}];
        end
        NewLine{zz}=tline2;
        figure(2);
        new_matrix=imrotate(img,Angle,'bilinear','crop');
        imshow(new_matrix);
        rectangle('Position',[kuang2(1,1),kuang2(1,2),kuang2(1,3)-kuang2(1,1),kuang2(1,4)-kuang2(1,2)],'LineWidth',4,'EdgeColor','r');
        na=['00',num2str(s),'.jpg'];
        imwrite(new_matrix,[SavedP,na],'jpg');
        zz=zz+1;
     end     
end
fclose(fidin);
%%???????????????????
fidin1=fopen('test-3.txt','w+');
for j=1:1:size(NewLine,2)
    fprintf(fidin1,'%s\n',NewLine{j});
end
fclose(fidin1);