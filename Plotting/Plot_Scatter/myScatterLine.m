function myScatterLine(x,y,opt)
% usage:做带有95%CI的散点图
% input：
%    x:自变量
%    y: 因变量
%    opt:options
%% opt
if nargin<3
    opt=struct();
end
% scatter
if ~isfield(opt,'scatterLineStyle');opt.scatterLineStyle='none';end
if ~isfield(opt,'scatterMarker');opt.scatterMarker='o';end
if ~isfield(opt,'MarkerSize');opt.MarkerSize=6;end
if ~isfield(opt,'LineWidth_scatter');opt.LineWidth_scatter=1.5;end
if ~isfield(opt,'scatterMarkerEdgeColor');opt.scatterMarkerEdgeColor=[ 1 .5 0];end
if ~isfield(opt,'scatterMarkerFaceColor');opt.scatterMarkerFaceColor='none';end
% fit line
if ~isfield(opt,'LineWidth_fitLine');opt.LineWidth_fitLine=1.5;end
if ~isfield(opt,'lineColor');opt.lineColor=[ 1 .5 0];end
% plot CI
%      display what
if ~isfield(opt,'plotCI');opt.plotCI=1;end
if ~isfield(opt,'CiLine');opt.CiLine=0;end
if ~isfield(opt,'CiFace');opt.CiFace=1;end
%      CI Line
if ~isfield(opt,'CiLineStyle');opt.CiLineStyle=':';end
if ~isfield(opt,'CiLineWidth');opt.CiLineWidth=.5;end
if ~isfield(opt,'CiLineColor');opt.CiLineColor=[ 1 .5 0];end
%      CI Face
if ~isfield(opt,'CiFaceColor');opt.CiFaceColor=[1 .5 0];end
if ~isfield(opt,'CiFaceAlpha');opt.CiFaceAlpha=.2;end
%   label
if ~isfield(opt,'xlabel');opt.xlabel='';end
if ~isfield(opt,'ylabel');opt.ylabel='';end
%   title
if ~isfield(opt,'title');opt.title='';end

%%
% data prepare
x2=reshape(x,1,numel(x));
y2=reshape(y,1,numel(y));
[x2,index]=sort(x2,'ascend');
y2=y2(index);
[p,s] = polyfit(x2,y2,1);
[yfit,dy] = polyconf(p,x2,s,'predopt','curve');
% scatter
figScatter=plot(x2,y2);
%=====================
xlabel(opt.xlabel,'FontSize',8);
ylabel(opt.ylabel,'FontSize',8);
%=====================
axis([min(x)-mean(x)/10, max(x)+max(x)/10, min(y)-min(y)/10, max(y)+max(y)/10]);
% set(figScatter,XLim,[-0.1,20])
figScatter.Marker=opt.scatterMarker;
figScatter.LineWidth=opt.LineWidth_scatter;
figScatter.MarkerSize=opt.MarkerSize;
figScatter.LineStyle=opt.scatterLineStyle;
figScatter.MarkerEdgeColor=opt.scatterMarkerEdgeColor;
figScatter.MarkerFaceColor=opt.scatterMarkerFaceColor;
% fit line
fitLine=lsline;
fitLine.LineWidth=opt.LineWidth_fitLine;
fitLine.Color=opt.lineColor;
hold on;
% fill 95% CI
if opt.plotCI
    % CI line
    if opt.CiLine
        figFillUp=fill([x2,fliplr(x2)],[yfit+dy,fliplr(yfit+dy)],opt.CiFaceColor);
        figFillLow=fill([x2,fliplr(x2)],[yfit-dy,fliplr(yfit-dy)],opt.CiFaceColor);
        figFillUp.LineStyle=opt.CiLineStyle;
        figFillLow.LineStyle=opt.CiLineStyle;
        figFillUp.EdgeColor=opt.CiLineColor;
        figFillLow.EdgeColor=opt.CiLineColor;
        figFillUp.LineWidth=opt.CiLineWidth;
        figFillLow.LineWidth=opt.CiLineWidth;
    end
    %
    if opt.CiFace
        figFillFace=fill([x2,fliplr(x2)],[yfit-dy,fliplr(yfit+dy)],opt.CiFaceColor);
        figFillFace.FaceColor=opt.CiFaceColor;
        figFillFace.LineStyle='none';
        figFillFace.FaceAlpha=opt.CiFaceAlpha;
    end
end
hold off;
% ax=gca;
% ax.FontSize=15;
% title(opt.title);
box off
end