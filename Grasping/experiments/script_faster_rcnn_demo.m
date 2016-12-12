function script_faster_rcnn_demo()
close all;
clc;
clear mex;
clear is_valid_handle; % to clear init_key
run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'startup'));
%% -------------------- CONFIG --------------------
opts.caffe_version          = 'caffe_faster_rcnn';
opts.gpu_id                 = auto_select_gpu;
active_caffe_mex(opts.gpu_id, opts.caffe_version);

opts.per_nms_topN           = 6000;
opts.nms_overlap_thres      = 0.7;
opts.after_nms_topN         = 300;
opts.use_gpu                = true;

opts.test_scales            = 600;

%% -------------------- INIT_MODEL --------------------
%model_dir                   = fullfile(pwd, 'output', 'faster_rcnn_final', 'faster_rcnn_VOC0712_vgg_16layers'); %% VGG-16
model_dir                   = fullfile(pwd, 'output', 'faster_rcnn_final', 'faster_rcnn_VOC2007_ZF'); %% ZF
%model_dir                   = fullfile(pwd, 'output3', 'faster_rcnn_VOC2007_ZF'); %% ZF
proposal_detection_model    = load_proposal_detection_model(model_dir);

proposal_detection_model.conf_proposal.test_scales = opts.test_scales;
proposal_detection_model.conf_detection.test_scales = opts.test_scales;
if opts.use_gpu
    proposal_detection_model.conf_proposal.image_means = gpuArray(proposal_detection_model.conf_proposal.image_means);
    proposal_detection_model.conf_detection.image_means = gpuArray(proposal_detection_model.conf_detection.image_means);
end

% caffe.init_log(fullfile(pwd, 'caffe_log'));
% proposal net
rpn_net = caffe.Net(proposal_detection_model.proposal_net_def, 'test');
rpn_net.copy_from(proposal_detection_model.proposal_net);
% fast rcnn net
fast_rcnn_net = caffe.Net(proposal_detection_model.detection_net_def, 'test');
fast_rcnn_net.copy_from(proposal_detection_model.detection_net);

% set gpu/cpu
if opts.use_gpu
    caffe.set_mode_gpu();
else
    caffe.set_mode_cpu();
end     
%%---------initiate ROS-------------------------------
%rosinit('10.7.34.70');
rosinit();
pause(1);
%% -------------------- WARM UP --------------------
% the first run will be slower; use an empty image to warm up

for j = 1:2 % we warm up 2 times
    im = uint8(ones(240, 320, 3)*128);
    if opts.use_gpu
        im = gpuArray(im);
    end
    [boxes, scores]             = proposal_im_detect(proposal_detection_model.conf_proposal, rpn_net, im);
    aboxes                      = boxes_filter([boxes, scores], opts.per_nms_topN, opts.nms_overlap_thres, opts.after_nms_topN, opts.use_gpu);
    if proposal_detection_model.is_share_feature
        [boxes, scores]             = fast_rcnn_conv_feat_detect(proposal_detection_model.conf_detection, fast_rcnn_net, im, ...
            rpn_net.blobs(proposal_detection_model.last_shared_output_blob_name), ...
            aboxes(:, 1:4), opts.after_nms_topN);
    else
        [boxes, scores]             = fast_rcnn_im_detect(proposal_detection_model.conf_detection, fast_rcnn_net, im, ...
            aboxes(:, 1:4), opts.after_nms_topN);
    end
end
Kinect_rgb = rossubscriber('/camera/rgb/image_color');
Kinect_depth = rossubscriber('/camera/depth_registered/points');
chatpub1 = rospublisher('/joint1_controller/command','std_msgs/Float64');
chatpub2 = rospublisher('/joint2_controller/command','std_msgs/Float64');
chatpub3 = rospublisher('/joint3_controller/command','std_msgs/Float64');
chatpub4 = rospublisher('/joint4_controller/command','std_msgs/Float64');
chatpub5 = rospublisher('/joint5_controller/command','std_msgs/Float64');
chatpub6 = rospublisher('/joint6_controller/command','std_msgs/Float64');
chatpub7 = rospublisher('/joint7_controller/command','std_msgs/Float64');
msg1 = rosmessage(chatpub1);
msg2 = rosmessage(chatpub2);
msg3 = rosmessage(chatpub3);
msg4 = rosmessage(chatpub4);
msg5 = rosmessage(chatpub5);
msg6 = rosmessage(chatpub6);
msg7 = rosmessage(chatpub7);



%% -------------------- TESTING --------------------
running_time = [];
j=1;
k=1;
while(k~=0)
imag_rgb=receive(Kinect_rgb);
imag_depth=receive(Kinect_depth);
img=readImage(imag_rgb);
dept=readXYZ(imag_depth);
imag=imresize(img,0.5);
%im_names = {'0011.jpg'};%, '004545.jpg', '000542.jpg', '000456.jpg', '001150.jpg'};
% these images can be downloaded with fetch_faster_rcnn_final_model.m



    
    im = imag;
    
    if opts.use_gpu
        im = gpuArray(im);

    end
    
    % test proposal
    th = tic();
    [boxes, scores]             = proposal_im_detect(proposal_detection_model.conf_proposal, rpn_net, im);
    t_proposal = toc(th);
    th = tic();
    aboxes                      = boxes_filter([boxes, scores], opts.per_nms_topN, opts.nms_overlap_thres, opts.after_nms_topN, opts.use_gpu);
    t_nms = toc(th);
    
    % test detection
    th = tic();
    if proposal_detection_model.is_share_feature
        [boxes, scores]             = fast_rcnn_conv_feat_detect(proposal_detection_model.conf_detection, fast_rcnn_net, im, ...
            rpn_net.blobs(proposal_detection_model.last_shared_output_blob_name), ...
            aboxes(:, 1:4), opts.after_nms_topN);
    else
        [boxes, scores]             = fast_rcnn_im_detect(proposal_detection_model.conf_detection, fast_rcnn_net, im, ...
            aboxes(:, 1:4), opts.after_nms_topN);
    end
    t_detection = toc(th);
    
    fprintf('%d (%dx%d): time %.3fs (resize+conv+proposal: %.3fs, nms+regionwise: %.3fs)\n', j, ...
        size(im, 2), size(im, 1), t_proposal + t_nms + t_detection, t_proposal, t_nms+t_detection);
    running_time(end+1) = t_proposal + t_nms + t_detection;
    
    % visualize
    classes = proposal_detection_model.classes;
    boxes_cell = cell(length(classes), 1);
    thres = 0.85;
    jk=1;
    for i = 1:length(boxes_cell)
        boxes_cell{jk} = [boxes(:, (1+(i-1)*4):(i*4)), scores(:, i)];
        boxes_cell{jk} = boxes_cell{i}(nms(boxes_cell{i}, 0.3), :);
        
        I = boxes_cell{jk}(:, 5) >= thres;
        boxes_cell{jk} = boxes_cell{jk}(I, :);
        jk=jk+1;
    end
   boxes_cell{3}=[0,0,0.1,0.1,0.99];
    figure(j);
    showboxes(im, boxes_cell, classes, 'voc');
    pause(0.5);
fprintf('mean time: %.3fs\n', mean(running_time));
inde=find(~cellfun(@isempty,boxes_cell));
has=0;
kiss=1;
totalll=0;
if length(inde)==0
    has=0;
else
kkk=1;
kkk=double(kkk);

for i=1:1:size(inde,1)
    resu=0;
    resu=inde(i,1);
    if resu~=0
       Objt(kkk)=resu;
       kkk=kkk+1;
    end
end
    has=1;
    fprintf('found class of %.0f targets\n',kkk-1);
end
if has==1
     figure;
imshow(img);
hold on;
for ob=1:1:kkk-1
    if Objt(ob)==3
            continue;
        else
        datas=boxes_cell{Objt(ob)};
        center(1,1)=(datas(1,1)+datas(1,3))/2;
        center(1,2)=(datas(1,2)+datas(1,4))/2;
        widt=round(datas(1,3)-datas(1,1));
        Heig=round(datas(1,4)-datas(1,2));
        center(1,1)=round(center(1,1)*2);
        center(1,2)=round(center(1,2)*2);
        rectangle('Position',[round(datas(1,1))*2,round(datas(1,2))*2,widt*2,Heig*2],'EdgeColor','red');
        plot(center(1,1),center(1,2),'r.','markersize',15);
        hold on
        text(double(center(1,1)),double(center(1,2)),'bounding box center');
        hold on
    end
end
end
if has==1
%  figure;
% imshow(img);
% hold on;
    for ob=1:1:kkk-1
        if Objt(ob)==3
            continue;
        else
        fprintf('starting from 1st object of class %.0f target\n',ob);
        datas=boxes_cell{Objt(ob)};
        center(1,1)=(datas(1,1)+datas(1,3))/2;
        center(1,2)=(datas(1,2)+datas(1,4))/2;
        widt=datas(1,3)-datas(1,1);
        center(1,1)=round(center(1,1)*2);
        center(1,2)=round(center(1,2)*2);
        distance=dept((center(1,2)-1)*640+center(1,1),:);
        objectID=Objt(ob);
        dept2=reshape(dept(:,3),[640,480]);
        dept3=dept2';
        Heig=datas(1,4)-datas(1,2);
        ready=1;
        if Objt(ob)==1||Objt(ob)==4
               kiss=kiss+1;
            [tim,GrabPoint,ready]=findGrabPoint(datas,img,dept,Heig,widt,center,objectID);
            distance=dept((GrabPoint(1,2)-1)*640+GrabPoint(1,1),:);
            totalll=totalll+tim;
            meant=totalll/kiss;
            fprintf('time for finding point is %d\n',meant);
             plot(GrabPoint(1,1),GrabPoint(1,2),'r+','markersize',150);
             hold on
             text(double(GrabPoint(1,1)),double(GrabPoint(1,2)),'\leftarrow grasping Point');
             hold off;
        end
        if Objt(ob)==2||Objt(ob)==5||Objt(ob)==6
            [tim,GrabPoint,ready]=findGrabPoint(datas,img,dept,Heig,widt,center,objectID);
            kiss=kiss+1;
            distance=dept((GrabPoint(1,1)-1)*640+GrabPoint(1,2),:);
             totalll=totalll+tim;
            meant=totalll/kiss;
            fprintf('time for finding point is %d\n',meant);
%             figure
%             imshow(img);
%             rectangle('Position',[GrabPoint(1,2)-40,GrabPoint(1,1)-20,80,40],'EdgeColor','red');
%             figure
%             imshow(dept3);
            rectangle('Position',[GrabPoint(1,2)-40,GrabPoint(1,1)-20,80,40],'EdgeColor','red');
            plot(GrabPoint(1,2),GrabPoint(1,1),'r+','markersize',15);
            hold on
            text(double(GrabPoint(1,2)),double(GrabPoint(1,1)),'\leftarrow grasping Point');
            hold off
        end

if sum(isnan([distance(1,1) distance(1,2) distance(1,3)]))==0
[y,z,tr2,tr3,t1,t2,t3,t4,go]=Angle(objectID,distance(1,1),distance(1,2),distance(1,3),-0.125,0.27);%0.55*cos(pi/6),-0.55*sin(pi/6));
fprintf('target center is: %.3f %.3f\n The distance is %.3f under camera coordinate system\n',distance(1,1),distance(1,2),distance(1,3));
fprintf('Angles for 1-4 are: %.3f %.3f %.3f %.3f\n',t1,t2,t3,t4);
if (go==0&&ready==1)||(t2<-60&&t3>60)

% initialize arm
fprintf('Initializing arm...\n');
msg1.Data = 1.2;
msg2.Data = 0;
msg3.Data = -0;
msg4.Data = -1.2;
msg5.Data =1.2;
msg6.Data = 0;
msg7.Data = 0.1;
send(chatpub7,msg7);
pause(2);
send(chatpub4,msg4);
send(chatpub5,msg5);
pause(2);
send(chatpub2,msg2);
send(chatpub3,msg3);
pause(4);
send(chatpub1,msg1);
send(chatpub6,msg6);
% ---ready position----
if t1<=0&&z<=0
    msg1.Data = -t1/180*pi-8/180*pi;
    if Objt(ob)==6
        msg1.Data=-t1/180*pi-8/180*pi;
    end
end
if t1<=0&&z>0
    msg1.Data = -t1/180*pi-9/180*pi;
end
if (t1>0)&&(z<0)
    msg1.Data = -t1/180*pi-3/180*pi;
end
if (t1>0)&&(z>=0)
    msg1.Data = -t1/180*pi-7/180*pi;
        if Objt(ob)==6
            msg1.Data=-t1/180*pi-6/180*pi;
        end
end
        if Objt(ob)==4
            msg6.Data = 0;
        else
            msg6.Data = 0;
        end
    if objectID==4
        msg1.Data = -t1/180*pi-10/180*pi;
    end
if objectID==1
        msg1.Data = -t1/180*pi-5/180*pi;
end
msg2.Data = tr2/180*pi;
msg3.Data = -tr2/180*pi;
msg4.Data = tr3/180*pi+4/180*pi;
msg5.Data = -tr3/180*pi-4/180*pi;
%msg6.Data = t4/180*pi;
msg7.Data = 0.1;
send(chatpub7,msg7);
send(chatpub1,msg1);
pause(4);
send(chatpub2,msg2);
send(chatpub3,msg3);
pause(2);
send(chatpub4,msg4);
send(chatpub5,msg5);
pause(5);
send(chatpub6,msg6);
%% ---start grabbing----
msg2.Data = t2/180*pi;
msg3.Data = -t2/180*pi;
msg4.Data = t3/180*pi;
msg5.Data = -t3/180*pi;

if t1<0
    msg4.Data = t3/180*pi-3/180*pi;
    msg5.Data = -t3/180*pi+3/180*pi;
end
if z<=0
    msg4.Data = t3/180*pi-12/180*pi;
    msg5.Data = -t3/180*pi+12/180*pi;

end
if objectID~=4&&objectID~=2
    msg4.Data = t3/180*pi-2/180*pi;
    msg5.Data = -t3/180*pi+2/180*pi;
end
if objectID==4
    msg4.Data = t3/180*pi-8/180*pi;
    msg5.Data = -t3/180*pi+8/180*pi;
end
pause(1);
send(chatpub2,msg2);
send(chatpub3,msg3);
pause(0.2);
send(chatpub4,msg4);
send(chatpub5,msg5);
msg7.Data = 1.0;
if objectID==4||objectID==1
    msg7.Data = 1.2;
end
send(chatpub6,msg6);
pause(2);
send(chatpub7,msg7);
pause(3);
%% get back
msg1.Data = -1.3;
msg2.Data = 0.1;
msg3.Data = -0.1;
msg4.Data = 0.1;
msg5.Data = -0.1;
msg7.Data = 0.1;

send(chatpub2,msg2);
send(chatpub3,msg3);
pause(2);
send(chatpub4,msg4);
send(chatpub5,msg5);
pause(2);
send(chatpub1,msg1);
pause(4);
send(chatpub6,msg6);
send(chatpub7,msg7);
%% go back
msg1.Data = 1.3;
msg2.Data = 0;
msg3.Data = -0;
msg4.Data = -0;
msg5.Data = 0;
msg6.Data = 0;
msg7.Data = 0.1;
send(chatpub7,msg7);
pause(2);
send(chatpub4,msg4);
send(chatpub5,msg5);
pause(3);
send(chatpub2,msg2);
send(chatpub3,msg3);
pause(4);
send(chatpub1,msg1);
send(chatpub6,msg6);
else
    fprintf(' too far to reach\n');
end
end
        end
    end
    has=0;
end
j=j+1;
kk = waitforbuttonpress; 
 key = get(gcf,'CurrentKey');
    if(strcmp (key , 'return'))
        k=0;
    else k=1;
    end


end
caffe.reset_all(); 
clear mex;
end

function proposal_detection_model = load_proposal_detection_model(model_dir)
    ld                          = load(fullfile(model_dir, 'model'));
    proposal_detection_model    = ld.proposal_detection_model;
    clear ld;
    
    proposal_detection_model.proposal_net_def ...
                                = fullfile(model_dir, proposal_detection_model.proposal_net_def);
    proposal_detection_model.proposal_net ...
                                = fullfile(model_dir, proposal_detection_model.proposal_net);
    proposal_detection_model.detection_net_def ...
                                = fullfile(model_dir, proposal_detection_model.detection_net_def);
    proposal_detection_model.detection_net ...
                                = fullfile(model_dir, proposal_detection_model.detection_net);
    
end

function aboxes = boxes_filter(aboxes, per_nms_topN, nms_overlap_thres, after_nms_topN, use_gpu)
    % to speed up nms
    if per_nms_topN > 0
        aboxes = aboxes(1:min(length(aboxes), per_nms_topN), :);
    end
    % do nms
    if nms_overlap_thres > 0 && nms_overlap_thres < 1
        aboxes = aboxes(nms(aboxes, nms_overlap_thres, use_gpu), :);       
    end
    if after_nms_topN > 0
        aboxes = aboxes(1:min(length(aboxes), after_nms_topN), :);
    end
end
