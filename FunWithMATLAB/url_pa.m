[sourcefile, status] = urlread(sprintf('http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/000001/type/S.phtml?year=%d&season=%d', year));

[datefile, date_tokens]= regexp(sourcefile, 'Õü¾ÈÕß*?');

sourcefile(3028)
