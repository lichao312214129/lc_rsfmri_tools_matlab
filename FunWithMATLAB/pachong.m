clc;
clear;
warning off;
year=2017;

for season = 1:4
%     [sourcefile, status] = urlread(sprintf(['http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid.phtml?year=%d&jidu=%d'], year,season));
%     fprintf('抓取%d年%d季度的数据中...', year, season)
    if ~status%判断数据是否全部读取成功
        error('出问题了哦，请检查\n')
    end
    expr1 = '\s+(\d\d\d\d-\d\d-\d\d)\s*';    %要提取的模式，（）中为要提取的内容
    [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');   %match返回整个匹配类型，token返回（）标记的位置，都为元胞类型
    date = cell(size(date_tokens));%创建一个等大的元胞数组
    for idx = 1:length(date_tokens)
        date{idx} = date_tokens{idx}{1};    %将日期写入
    end
    expr2 = '<div align="center">(\d*\.?\d*)</div>';
    [datafile, data_tokens] = regexp(sourcefile, expr2, 'match', 'tokens'); %从源文件中获取目标数据
    data = zeros(size(data_tokens));%产生和数据相同长度的0
    for idx = 1:length(data_tokens)
        data(idx) = str2double(data_tokens{idx}{1});       %转变数据类型后存入data中
    end
    
    data = reshape(data, 6, length(data)/6 )'; %重排，根据源代码的显示，将不同定义的数据排成六列
    items={'日期' '开盘价' '最高价' '收盘价' '最低价' '交易量' '交易金额'};
    sheet = sprintf('第%d季度', season); %工作表名称
    xlswrite('D:/data', items, sheet)
    xlswrite('D:/data', date' , sheet,'A2'); %在第一列写入日期
    range = sprintf('B2:%s%d',char(double('B')+size(data,2)-1), size(data,1)+1); %从源文件中获取的目标数据的放置范围
    xlswrite('D:/data', data, sheet, range);
    fprintf('完成!\n')
end


fprintf('全部完成！数据保存在D盘的data表格中，请注意查看！\n')