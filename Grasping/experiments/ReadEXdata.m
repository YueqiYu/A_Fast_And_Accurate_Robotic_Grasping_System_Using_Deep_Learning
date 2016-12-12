clc;
clear;

Place1='/home/yueqiyu/Downloads/faster_rcnn-master/experiments/voc_2007_test2/';
Place2='/home/yueqiyu/Downloads/faster_rcnn-master/experiments/voc_2007_test/';

name{1}='Torch';
name{2}='Pill';
name{3}='Cup';
name{4}='Cup2';
name{5}='Bowl';
name{6}='_pr_voc_2007_test';
name{7}='PR Curve for ';
for i=1:1:5
    Tna=[Place1,name{i},name{6}];
    Tna2=[Place2,name{i},name{6}];
    load(Tna);
    recall1{i}=recall;
    pre1{i}=prec;
    ap1(i)=ap;
    ap_auc1(i)=ap_auc;
    recall=[];
    prec=[];
    ap=[];
    ap_auc=[];
    load(Tna2);
    recall2{i}=recall;
    pre2{i}=prec;
    ap2(i)=ap;
    ap_auc2(i)=ap_auc;
    figure(i);
    plot(recall1{i},pre1{i},'-r',recall2{i},pre2{i},'-b');
    legend('Stage1 PR Curve','Stage2 PR Curve','location','SouthWest');
    axis([0 1.01 0 1.01]);
    set(gca,'YTick', 0:0.1:1.01);
    set(gca,'XTick', 0:0.1:1.01);
    title([name{7},name{i}]);
end
