%%
%该代码可以做voc2007数据集中的xml文件，
%txt文件每行格式为：000002.jpg dog 44 28 132 121
%即每行由图片名、目标类型、包围框坐标组成，空格隔开
%如果一张图片有多个目标，则格式如下：（比如两个目标）
%000002.jpg dog 44 28 132 121
%000002.jpg car 50 27 140 110
%包围框坐标为左上角和右下角
%作者：小咸鱼_
%CSDN:http://blog.csdn.net/sinat_30071459
%%
clc;
clear;
%注意修改下面四个变量
imgpath='Alll\Train2\';%图像存放文件夹
imgpathN='Alll\JPEGImages4\';
txtpath='test-3_m.txt';%txt文件
xmlpath_new='Alll\Annotations5\';%修改后的xml保存文件夹
foldername='VOC2007';%xml的folder字段名

fidin=fopen(txtpath,'r');
lastname='begin';
j=1;
nameN='Cup2';
while ~feof(fidin)
     tline=fgetl(fidin);
%      if j==1
%          tline=tline(1,4:45);
%      end
    no=6500+j;
    nama=num2str(no);
    fno=[imgpathN,'00',nama,'.jpg'];
    Fnew=['00',nama,'.jpg'];
     str = regexp(tline, ' ','split');
%      str=cell(1,size(str2,2)-1);
%      str{1}=str2{1};
%      for zx=1:1:size(str2,2)-3
%         str{zx+1}=str2{zx+3};
%      end
     filepath=[imgpath,str{1}];
     if exist(filepath,'file')
   %  Fnew=str{1};
     img=imread(filepath);
     [h,w,d]=size(img);
          scale=1;     
       imshow(img);
%       imwrite(img,fno,'jpg');
      rectangle('Position',[str2double(str{3})*scale,str2double(str{4})*scale,(str2double(str{5})-str2double(str{3}))*scale,(str2double(str{6})-str2double(str{4}))*scale],'LineWidth',4,'EdgeColor','r');
        str{3}=num2str(floor(str2num(str{3})*scale));
        str{4}=num2str(floor(str2num(str{4})*scale));
        str{5}=num2str(floor(str2num(str{5})*scale));
        str{6}=num2str(floor(str2num(str{6})*scale));
      if size(str,2)>6
          nu=floor((size(str,2)-6)/5);
            for i=1:1:nu
                rectangle('Position',[str2double(str{5*i+3})*scale,str2double(str{5*i+4})*scale,(str2double(str{5*i+5})-str2double(str{5*i+3}))*scale,(str2double(str{5*i+6})-str2double(str{5*i+4}))*scale],'LineWidth',4,'EdgeColor','b');
                str{5*i+3}=num2str(floor(str2num(str{5*i+3})*scale));
                str{5*i+4}=num2str(floor(str2num(str{5*i+4})*scale));
                str{5*i+5}=num2str(floor(str2num(str{5*i+5})*scale));
                str{5*i+6}=num2str(floor(str2num(str{5*i+6})*scale));
            end
      end
      str{1}=str{1};
     pause(0.1);
        if strcmp(str{1},lastname)%如果文件名相等，只需增加object
           object_node=Createnode.createElement('object');
           Root.appendChild(object_node);
           node=Createnode.createElement('name');
           node.appendChild(Createnode.createTextNode(sprintf('%s',nameN)));
           object_node.appendChild(node);
          
           node=Createnode.createElement('pose');
           node.appendChild(Createnode.createTextNode(sprintf('%s','Unspecified')));
           object_node.appendChild(node);
          
           node=Createnode.createElement('truncated');
           node.appendChild(Createnode.createTextNode(sprintf('%s','0')));
           object_node.appendChild(node);

           node=Createnode.createElement('difficult');
           node.appendChild(Createnode.createTextNode(sprintf('%s','0')));
           object_node.appendChild(node);
          
           bndbox_node=Createnode.createElement('bndbox');
           object_node.appendChild(bndbox_node);

           node=Createnode.createElement('xmin');
           node.appendChild(Createnode.createTextNode(sprintf('%s',num2str(str{3}))));
           bndbox_node.appendChild(node);

           node=Createnode.createElement('ymin');
           node.appendChild(Createnode.createTextNode(sprintf('%s',num2str(str{4}))));
           bndbox_node.appendChild(node);

           node=Createnode.createElement('xmax');
           node.appendChild(Createnode.createTextNode(sprintf('%s',num2str(str{5}))));
           bndbox_node.appendChild(node);

           node=Createnode.createElement('ymax');
           node.appendChild(Createnode.createTextNode(sprintf('%s',num2str(str{6}))));
           bndbox_node.appendChild(node);
        else %如果文件名不等，则需要新建xml
  %        copyfile(filepath, 'JPEGImages');
            %先保存上一次的xml
           if exist('Createnode','var')
              tempname=lastname;
              tempname=strrep(tempname,'.jpg','.xml');
              xmlwrite(tempname,Createnode);   
           end
            
            
            Createnode=com.mathworks.xml.XMLUtils.createDocument('annotation');
            Root=Createnode.getDocumentElement;%根节点
            node=Createnode.createElement('folder');
            node.appendChild(Createnode.createTextNode(sprintf('%s',foldername)));
            Root.appendChild(node);
            node=Createnode.createElement('filename');
            node.appendChild(Createnode.createTextNode(sprintf('%s',str{1})));
            Root.appendChild(node);
            source_node=Createnode.createElement('source');
            Root.appendChild(source_node);
            node=Createnode.createElement('database');
            node.appendChild(Createnode.createTextNode(sprintf('My Database')));
            source_node.appendChild(node);
            node=Createnode.createElement('annotation');
            node.appendChild(Createnode.createTextNode(sprintf('VOC2007')));
            source_node.appendChild(node);

           node=Createnode.createElement('image');
           node.appendChild(Createnode.createTextNode(sprintf('flickr')));
           source_node.appendChild(node);

           node=Createnode.createElement('flickrid');
           node.appendChild(Createnode.createTextNode(sprintf('NULL')));
           source_node.appendChild(node);
           owner_node=Createnode.createElement('owner');
           Root.appendChild(owner_node);
           node=Createnode.createElement('flickrid');
           node.appendChild(Createnode.createTextNode(sprintf('NULL')));
           owner_node.appendChild(node);

           node=Createnode.createElement('name');
           node.appendChild(Createnode.createTextNode(sprintf('xiaoxianyu')));
           owner_node.appendChild(node);
           size_node=Createnode.createElement('size');
           Root.appendChild(size_node);

          node=Createnode.createElement('width');
          node.appendChild(Createnode.createTextNode(sprintf('%s',num2str(w))));
          size_node.appendChild(node);

          node=Createnode.createElement('height');
          node.appendChild(Createnode.createTextNode(sprintf('%s',num2str(h))));
          size_node.appendChild(node);

         node=Createnode.createElement('depth');
         node.appendChild(Createnode.createTextNode(sprintf('%s',num2str(d))));
         size_node.appendChild(node);
         
          node=Createnode.createElement('segmented');
          node.appendChild(Createnode.createTextNode(sprintf('%s','0')));
          Root.appendChild(node);
          object_node=Createnode.createElement('object');
          Root.appendChild(object_node);
          node=Createnode.createElement('name');
          node.appendChild(Createnode.createTextNode(sprintf('%s',nameN)));
          object_node.appendChild(node);
          
          node=Createnode.createElement('pose');
          node.appendChild(Createnode.createTextNode(sprintf('%s','Unspecified')));
          object_node.appendChild(node);
          
          node=Createnode.createElement('truncated');
          node.appendChild(Createnode.createTextNode(sprintf('%s','0')));
          object_node.appendChild(node);

          node=Createnode.createElement('difficult');
          node.appendChild(Createnode.createTextNode(sprintf('%s','0')));
          object_node.appendChild(node);
          
          bndbox_node=Createnode.createElement('bndbox');
          object_node.appendChild(bndbox_node);

         node=Createnode.createElement('xmin');
         node.appendChild(Createnode.createTextNode(sprintf('%s',num2str(str{3}))));
         bndbox_node.appendChild(node);

         node=Createnode.createElement('ymin');
         node.appendChild(Createnode.createTextNode(sprintf('%s',num2str(str{4}))));
         bndbox_node.appendChild(node);

        node=Createnode.createElement('xmax');
        node.appendChild(Createnode.createTextNode(sprintf('%s',num2str(str{5}))));
        bndbox_node.appendChild(node);

        node=Createnode.createElement('ymax');
        node.appendChild(Createnode.createTextNode(sprintf('%s',num2str(str{6}))));
        bndbox_node.appendChild(node);
        if size(str,2)>6
            nu=floor((size(str,2)-6)/5);
            for i=1:1:nu
          object_node=Createnode.createElement('object');
          Root.appendChild(object_node);
          node=Createnode.createElement('name');
          node.appendChild(Createnode.createTextNode(sprintf('%s',nameN)));
          object_node.appendChild(node);
          
          node=Createnode.createElement('pose');
          node.appendChild(Createnode.createTextNode(sprintf('%s','Unspecified')));
          object_node.appendChild(node);
          
          node=Createnode.createElement('truncated');
          node.appendChild(Createnode.createTextNode(sprintf('%s','0')));
          object_node.appendChild(node);

          node=Createnode.createElement('difficult');
          node.appendChild(Createnode.createTextNode(sprintf('%s','0')));
          object_node.appendChild(node);
          
          bndbox_node=Createnode.createElement('bndbox');
          object_node.appendChild(bndbox_node);

         node=Createnode.createElement('xmin');
         node.appendChild(Createnode.createTextNode(sprintf('%s',num2str(str{5*i+3}))));
         bndbox_node.appendChild(node);

         node=Createnode.createElement('ymin');
         node.appendChild(Createnode.createTextNode(sprintf('%s',num2str(str{5*i+4}))));
         bndbox_node.appendChild(node);

        node=Createnode.createElement('xmax');
        node.appendChild(Createnode.createTextNode(sprintf('%s',num2str(str{5*i+5}))));
        bndbox_node.appendChild(node);

        node=Createnode.createElement('ymax');
        node.appendChild(Createnode.createTextNode(sprintf('%s',num2str(str{5*i+6}))));
        bndbox_node.appendChild(node);
            end
        end
       lastname=str{1};
        end
        %处理最后一行
        if feof(fidin)
            tempname=lastname;
            tempname=strrep(tempname,'.jpg','.xml');
            xmlwrite(tempname,Createnode);
        end
         j=j+1;
     end
end
fclose(fidin);

file=dir(pwd);
for i=1:length(file)
   if length(file(i).name)>=4 && strcmp(file(i).name(end-3:end),'.xml')
    fold=fopen(file(i).name,'r');
    fnew=fopen([xmlpath_new file(i).name],'w');
    line=1;
    while ~feof(fold)
        tline=fgetl(fold);
        if line==1
           line=2;
           continue;
        end
        expression = '   ';
        replace=char(9);
        newStr=regexprep(tline,expression,replace);
        fprintf(fnew,'%s\n',newStr);
    end
    fprintf('已处理%s\n',file(i).name);
    fclose(fold);
    fclose(fnew);
	delete(file(i).name);
   end
end
