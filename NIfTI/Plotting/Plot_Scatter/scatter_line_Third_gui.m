function scatter_line_Third_gui()
%交互式绘制散点图
%email:lichao19870617@gmail.com
%please feel free to contact me
close all
fig = figure('Name','请输入自变量和应变量',...
    'MenuBar','none', ...
    'Toolbar','none', ...
    'NumberTitle','off', ...
    'Resize', 'off', ...
    'Position',[500,500,420,130]); %X,Y then Width, Height
set(fig, 'Color', ([50,200,50] ./255));
% 标识面板
xp=-90;yp=5;
%input
uipanel('Title','自变量x:','BackgroundColor','white','Units','Pixels','Position',[100+xp 85+yp 350 20]);
uipanel('Title','应变量y:','BackgroundColor','white','Units','Pixels','Position',[100+xp 45+yp 350 20]);
% load
uipanel('Title','load','BackgroundColor','white','Units','Pixels','Position',[470+xp 80+yp 30 30]);
% 控制面板
%input
x=uicontrol('Style','edit','HorizontalAlignment','left','String','','Position',[150+xp 80+yp 300 30]);
y=uicontrol('Style','edit','HorizontalAlignment','left','String','','Position',[150+xp 40+yp 300 30]);
% load
uicontrol('Style','PushButton','HorizontalAlignment','left','String','','Position',[470+xp 80+yp 30 15],...
    'Callback',@load_data);
% 点击运行
uicontrol('Style','PushButton','BackgroundColor','[ 1 .3 .3]','HorizontalAlignment','center','String','Run',...
    'Position',[300+xp yp 30 30],...
    'Callback',{@scatter_linearfit,[x,y]});

    function load_data(~,~)
        [file_name1,path_source1,~] = uigetfile({'*.xlsx;*.xls;*.txt','All Image Files';...
            '*.*','All Files'},'MultiSelect','on','需要上载的数据');
        try
        data=xlsread(fullfile(path_source1,file_name1));
        catch
         data=load((fullfile(path_source1,file_name1)));
        end
        x=double(data(:,1));
        y=double(data(:,2));
        % 点击运行
        uicontrol('Style','PushButton','BackgroundColor','[ 1 .3 .3]','HorizontalAlignment','center','String','Run',...
            'Position',[300+xp yp 30 30],...
            'Callback',{@scatter_linearfit,[x,y]});
    end

%% ===================散点图及最小二乘拟合直线======================
    function scatter_linearfit(~,~,uis)
        % 获取x和y的值
        try
            x1=str2num(get(uis(1),'String'));
            y1=str2num(get(uis(2),'String'));
        catch
            x1=uis(:,1);
            y1=uis(:,2);
        end
        x1=reshape(x1,numel(x1),1);
        y1=reshape(y1,numel(y1),1);
        % 散点图和拟合直线
        %% fig=figure;
        global  scatter_plot
        global line_fit
        global line_low
        global line_up
        x2=reshape(x1,1,numel(x1));
        y2=reshape(y1,1,numel(y1));
        [x2,index]=sort(x2,'ascend');
        y2=y2(index);
        fig=figure;
        [p,s] = polyfit(x2,y2,1);
        [yfit,dy] = polyconf(p,x2,s,'predopt','curve');
        fig_fill=fill([x2,fliplr(x2)],[yfit-dy,fliplr(yfit+dy)],[0.8706 0.9216 0.9804]);%填充CI
        fig_fill.EdgeColor='k';fig_fill.FaceColor='r';fig_fill.LineStyle='none';
        fig_fill.FaceAlpha=0.3;
        line_fit=line(x2,yfit,'color','r');
        hold on;
        scatter_plot=scatter(x1,y1,50,'Marker','o',...
            'MarkerEdgeColor','k','MarkerFaceColor','w','LineWidth',2);
        axis([min(x1),max(x1),-Inf,Inf]);
        box off;
        line_low=line(x1,yfit-dy,'color','r','linestyle','--');
        line_up=line(x1,yfit+dy,'color','r','linestyle','--');
        set(line_fit,'LineWidth',2,'LineStyle','-','Color','k');
        set(line_low,'LineWidth',2,'LineStyle','none','Color','k');
        set(line_up,'LineWidth',2,'LineStyle','none','Color','k');
%         fig_legend=legend('CI = 95%','fitting line','Location','northeastoutside');
        legend('boxoff');
        set(gca,'FontSize',30);
        % 线和点的框架面板
        fig_scatter = figure('Name','设置线和点',...
            'MenuBar','none', ...
            'Toolbar','none', ...
            'NumberTitle','off', ...
            'Resize', 'off', ...
            'Position',[10,400,250,300]); %X,Y then Width, Height
        set(fig_scatter, 'Color', ([50,200,50] ./255));
        % 线和点的设置标识面板
        xp=0;yp=80;
        %column 1
        uipanel('Title','线型','BackgroundColor','white','Units','Pixels','Position',[10+xp,150+yp,100,40]);
        uipanel('Title','线宽','BackgroundColor','white','Units','Pixels','Position',[10+xp 80+yp 100 40]);
        uipanel('Title','线颜色','BackgroundColor','white','Units','Pixels','Position',[10+xp 10+yp 100 40]);
        uipanel('Title','保存散点图','BackgroundColor','white','Units','Pixels','Position',[10+xp -60+yp 100 40]);
        %column 2
        uipanel('Title','点型','BackgroundColor','white','Units','Pixels','Position',[120+xp,150+yp,100,40]);
        uipanel('Title','点大小','BackgroundColor','white','Units','Pixels','Position',[120+xp 80+yp 100 40]);
        uipanel('Title','点边颜色','BackgroundColor','white','Units','Pixels','Position',[120+xp 10+yp 100 40]);
        uipanel('Title','点面颜色','BackgroundColor','white','Units','Pixels','Position',[120+xp -60+yp 100 40]);
        % 线和点的控制面板
        % column1
        uicontrol('Style', 'popup','String', {'-','--',':','-.'},'Position', [10+xp,155+yp,80,20],...
            'Callback',@ControlFigure_line);
        uicontrol('Style', 'slider','Min',1,'Max',20,'Value',2,'Position', [10+xp,80+yp,80,20],...
            'Callback',@ControlFigure_line);
        uicontrol('Style', 'popup','String', {'r','g','b','y','m','c','w','k','free_color'},'Position', [10+xp,15+yp,80,20],...
            'Callback',@ControlFigure_line);
        uicontrol('Style','PushButton','BackgroundColor','white','HorizontalAlignment','center','String','',...
            'Position',[10+xp,-60+yp,100,25],...
            'Callback',{@save_figure,fig});%保存散点图
        % column2
        uicontrol('Style', 'popup','String', {'o','*','.','+','x','s','d','h','>','<'},'Position', [120+xp,155+yp,80,20],...
            'Callback',@ControlFigure_dot);
        uicontrol('Style', 'slider','Min',10,'Max',5000,'Value',20,'Position', [120+xp,80+yp,80,20],...
            'Callback',@ControlFigure_dot);
        uicontrol('Style', 'popup','String',{'r','g','b','y','m','c','k','free_color'},'Position',[120+xp,15+yp,80,20],...
            'Callback',@ControlFigure_dot);
        uicontrol('Style', 'popup','String',{'r','g','b','y','m','c','k','w','free_color'},'Position',[120+xp -55+yp 80 20],...
            'Callback',@ControlFigure_dot);
    end
%% ====================调整线=====================================
    function ControlFigure_line(setting,~)
        strings = arrayfun(@(x) get(x,'String'),setting,'UniformOutput',false);
        global line_fit
        global line_low
        global line_up
        if numel(strings{1})==4
            line_fit.LineStyle=setting.String{setting.Value};
%             line_low.LineStyle=setting.String{setting.Value};
%             line_up.LineStyle=setting.String{setting.Value};
        elseif numel(strings{1})>4
            if strcmp(setting.String{setting.Value},'free_color')
                free_color('lineColor');
            else
                line_fit.Color=setting.String{setting.Value};
                line_low.Color=setting.String{setting.Value};
                line_up.Color=setting.String{setting.Value};
            end
        else
            line_fit.LineWidth=setting.Value;
            line_low.LineWidth=setting.Value;
            line_up.LineWidth=setting.Value;
        end
    end
%% ====================调整点=====================================
    function ControlFigure_dot(setting,~)
        strings = arrayfun(@(x) get(x,'String'),setting,'UniformOutput',false);
        global scatter_plot
        if numel(strings{1})==10
            scatter_plot.Marker=setting.String{setting.Value};
        elseif numel(strings{1})==9
            if strcmp(setting.String{setting.Value},'free_color')
                free_color('MarkerFaceColor');
            else
                scatter_plot.MarkerFaceColor=setting.String{setting.Value};
            end
        elseif numel(strings{1})==8
            if strcmp(setting.String{setting.Value},'free_color')
                free_color('MarkerEdgeColor');
            else
                scatter_plot.MarkerEdgeColor=setting.String{setting.Value};
            end
        else
            scatter_plot.SizeData =setting.Value;
        end
    end

%% =====================自由设定颜色===============================
    function free_color(which)
        char=which;
        fig_freecolor_name=char;
        % 根据不同的设置，调整位置和名称
        if strcmp(char,'lineColor')
            try
                close lineColor
            catch
            end
            position_value=[1000,530,250,200];
            fig_freecolor = figure('Name',fig_freecolor_name,...
                'MenuBar','none', ...
                'Toolbar','none', ...
                'NumberTitle','off', ...
                'Resize', 'off', ...
                'Position',position_value); %X,Y then Width, Height
            set(fig_freecolor, 'Color', ([50,200,50] ./255));
            % 面板1
            uipanel('Title','R','BackgroundColor','white','Units','Pixels','Position',[10,150,220,30]);
            uipanel('Title','G','BackgroundColor','white','Units','Pixels','Position',[10,100,220,30]);
            uipanel('Title','B','BackgroundColor','white','Units','Pixels','Position',[10,50,220,30]);
            % 控制1
            uicontrol('Style', 'slider','Min',0,'Max',255,'Value',10,'Position', [10,150,200,15],...
                'Callback',@obtain_FreeColor_Line_R);
            uicontrol('Style', 'slider','Min',0,'Max',255,'Value',10,'Position', [10,100,200,15],...
                'Callback',@obtain_FreeColor_Line_G);
            uicontrol('Style', 'slider','Min',0,'Max',255,'Value',10,'Position', [10,50,200,15],...
                'Callback',@obtain_FreeColor_Line_B);
        elseif strcmp(char,'MarkerFaceColor')
            try
                close MarkerFaceColor
            catch
            end
            position_value=[1000,290,250,200];
            fig_freecolor = figure('Name',fig_freecolor_name,...
                'MenuBar','none', ...
                'Toolbar','none', ...
                'NumberTitle','off', ...
                'Resize', 'off', ...
                'Position',position_value); %X,Y then Width, Height
            set(fig_freecolor, 'Color', ([50,200,50] ./255));
            % 面板2
            uipanel('Title','R','BackgroundColor','white','Units','Pixels','Position',[10,150,220,30]);
            uipanel('Title','G','BackgroundColor','white','Units','Pixels','Position',[10,100,220,30]);
            uipanel('Title','B','BackgroundColor','white','Units','Pixels','Position',[10,50,220,30]);
            % 控制2
            uicontrol('Style', 'slider','Min',0,'Max',255,'Value',10,'Position', [10,150,200,15],...
                'Callback',@obtain_FreeColor_Face_R);
            uicontrol('Style', 'slider','Min',0,'Max',255,'Value',10,'Position', [10,100,200,15],...
                'Callback',@obtain_FreeColor_Face_G);
            uicontrol('Style', 'slider','Min',0,'Max',255,'Value',10,'Position', [10,50,200,15],...
                'Callback',@obtain_FreeColor_Face_B);
        else
            try
                close MarkerEdgeColor
            catch
            end
            position_value=[1000,50,250,200];
            fig_freecolor = figure('Name',fig_freecolor_name,...
                'MenuBar','none', ...
                'Toolbar','none', ...
                'NumberTitle','off', ...
                'Resize', 'off', ...
                'Position',position_value); %X,Y then Width, Height
            set(fig_freecolor, 'Color', ([50,200,50] ./255));
            % 面板3
            uipanel('Title','R','BackgroundColor','white','Units','Pixels','Position',[10,150,220,30]);
            uipanel('Title','G','BackgroundColor','white','Units','Pixels','Position',[10,100,220,30]);
            uipanel('Title','B','BackgroundColor','white','Units','Pixels','Position',[10,50,220,30]);
            % 控制3
            uicontrol('Style', 'slider','Min',0,'Max',255,'Value',10,'Position', [10,150,200,15],...
                'Callback',@obtain_FreeColor_Edge_R);
            uicontrol('Style', 'slider','Min',0,'Max',255,'Value',10,'Position', [10,100,200,15],...
                'Callback',@obtain_FreeColor_Edge_G);
            uicontrol('Style', 'slider','Min',0,'Max',255,'Value',10,'Position', [10,50,200,15],...
                'Callback',@obtain_FreeColor_Edge_B);
        end
    end

%% =======================RGB====================================
% Line
    function obtain_FreeColor_Line_R(color,~)
        global line_fit
        global line_low
        global line_up
        values_R = arrayfun(@(x) get(x,'Value'),color);
        line_fit.Color(1)=values_R./255;
        line_low.Color(1)=values_R./255;
        line_up.Color(1)=values_R./255;
    end

    function obtain_FreeColor_Line_G(color,~)
        global line_fit
        global line_low
        global line_up
        values_G = arrayfun(@(x) get(x,'Value'),color);
        line_fit.Color(2)=values_G./255;
        line_low.Color(2)=values_G./255;
        line_up.Color(2)=values_G./255;
    end

    function obtain_FreeColor_Line_B(color,~)
        global line_fit
        global line_low
        global line_up
        values_B = arrayfun(@(x) get(x,'Value'),color);
        line_fit.Color(3)=values_B./255;
        line_low.Color(3)=values_B./255;
        line_up.Color(3)=values_B./255;
    end

% Face
    function obtain_FreeColor_Face_R(color,~)
        global scatter_plot
        values_R = arrayfun(@(x) get(x,'Value'),color);
        scatter_plot.MarkerFaceColor(1)=values_R./255;
    end

    function obtain_FreeColor_Face_G(color,~)
        global scatter_plot
        values_G = arrayfun(@(x) get(x,'Value'),color);
        scatter_plot.MarkerFaceColor(2)=values_G./255;
    end

    function obtain_FreeColor_Face_B(color,~)
        global scatter_plot
        values_B = arrayfun(@(x) get(x,'Value'),color);
        scatter_plot.MarkerFaceColor(3)=values_B./255;
    end
% Edge
    function obtain_FreeColor_Edge_R(color,~)
        global scatter_plot
        values_R = arrayfun(@(x) get(x,'Value'),color);
        scatter_plot.MarkerEdgeColor(1)=values_R./255;
    end

    function obtain_FreeColor_Edge_G(color,~)
        global scatter_plot
        values_G = arrayfun(@(x) get(x,'Value'),color);
        scatter_plot.MarkerEdgeColor(2)=values_G./255;
    end

    function obtain_FreeColor_Edge_B(color,~)
        global scatter_plot
        values_B = arrayfun(@(x) get(x,'Value'),color);
        scatter_plot.MarkerEdgeColor(3)=values_B./255;
    end
end

%% ====================save figure================================
function save_figure(~,~,fig)
outdir = uigetdir({},'Path of results');
cd(outdir);
fig.Visible = 'off';
fig.Position=[10   10   1500   800];
print(fig,'-dtiff','-r600','Scatter_Plot600dpi');
print(fig,'-dtiff','-r300','Scatter_Plot300dpi');
fig.Position=[50   50   800   500];
fig.Visible = 'on';
end
