clc;
clear;
trainImgStr = '2016_11';  
trainImgDir = dir([trainImgStr,'\*']);  
structGT = {};  
fid=fopen('Data.txt','w+');
for i = 1:length(trainImgDir)  
    if(strcmp(trainImgDir(i).name,'.') || strcmp(trainImgDir(i).name,'..'))  
        continue;  
    else  
        im = imread([trainImgStr,'\',trainImgDir(i).name]); 
        [h,w,c]=size(im);
        if h>490
            im=imresize(im,0.2);
        end
        h1 = imshow(im);  
        h2 = imrect(gca);  
        position = wait(h2);
        position(3:4)=position(1:2)+position(3:4);
        h3 = imrect(gca);  
        position2 = wait(h3);
        position2(3:4)=position2(1:2)+position2(3:4);
        position = round(position);  
        position2 = round(position2);  
        GT.boxes = position;
        GT.boxes2 = position2;
        GT.img = trainImgDir(i).name; 
        if i>9
            imwrite(im,['0000',num2str(i),'.jpg'],'jpg');
            name=['0000',num2str(i),'.jpg'];
        else
            imwrite(im,['00000',num2str(i),'.jpg'],'jpg');
            name=['00000',num2str(i),'.jpg'];
        end

        fprintf(fid,[name,' bowl ',num2str(position,'% d'),' bowl ',num2str(position2,'% d'),'\n']);
       
        structGT = [structGT,GT];  
    end  
end  
        fclose(fid);
        close();

 
save('structGT','structGT');  