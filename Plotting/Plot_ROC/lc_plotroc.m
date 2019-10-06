function auc = lc_plotroc(outputs, targets, opt)
% Plot ROC and return auc value
% Inputs:
% 	outputs: predict labels
% 	targets: ground truth labels (0 or 1)
% AUTHOR: Li Chao
%%
% input
if exist('opt', 'var') && ~isfield(opt,'roc_type')
    opt.roc_type='-';
end

if exist('opt', 'var') && ~isfield(opt,'line_color')
    opt.line_color=[1 0.5 0];
end

if exist('opt', 'var') && ~isfield(opt,'marker_edge_color')
    opt.marker_edge_color=opt.line_color;
end

if exist('opt', 'var') && ~isfield(opt,'line_width')
    opt.line_width=2.5;
end

if exist('opt', 'var') && ~isfield(opt,'marker_size')
    opt.marker_size=3;
end

if exist('opt', 'var') && ~isfield(opt,'marker_face_color')
    opt.marker_face_color='w';
end

%
pos_num = sum(targets==1);
neg_num = sum(targets==0);

nsubj=size(targets,1);
[~,idx]=sort(outputs);
targets=targets(idx);
xaxis=zeros(nsubj+1,1);
yaxis=zeros(nsubj+1,1);
auc=0;
xaxis(1)=1;yaxis(1)=1;

for i=2:nsubj
    TP=sum(targets(i:nsubj)==1);FP=sum(targets(i:nsubj)==0);
    xaxis(i)=FP/neg_num;
    yaxis(i)=TP/pos_num;
    auc=auc+(yaxis(i)+yaxis(i-1))*(xaxis(i-1)-xaxis(i))/2;
end

xaxis(nsubj+1)=0;yaxis(nsubj+1)=0;
auc=auc+yaxis(nsubj)*xaxis(nsubj)/2;

if exist('opt', 'var')
    plot(xaxis,yaxis,opt.roc_type,'color',opt.line_color,...
        'LineWidth',opt.line_width,...
        'MarkerSize',opt.marker_size,...
        'MarkerEdgeColor',opt.marker_edge_color,...
        'MarkerFaceColor',opt.marker_face_color);
else
    plot(xaxis,yaxis,'LineWidth',2);
end

set(gca,'LineWidth',2.5);  % axis line width
set(gca,'Fontsize',15);  % axis font size
xlabel('False Positive Rate');
ylabel('True Positive Rate');
axis([-0.05 1 0 1]);
box off
end
