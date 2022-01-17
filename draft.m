clear;
clc;

import Apps.DataManager;
import BaseClass.Asset.Option.Option;


% dm = DataManager('mss', 'sa', 'bridgeisbest');
% dir_tb = 'C:\Users\freakybridge\Desktop\taobao';
% dir_csv = "E:\OneDrive\hisdata";
% dir_rt = "E:\OneDrive\hisdata";

dm = DataManager('mss', 'sa', 'bridgeinmfc');
dir_tb = 'D:\desktop\taobao';
dir_csv = "D:\OneDrive\hisdata";
dir_rt = "D:\OneDrive\hisdata";


variety = '510300';
exchange = 'sse';
instrus = dm.LoadOptChain(variety, exchange, dir_rt);
for i = 1 : size(instrus, 1)
    info = instrus(i, :);    
    opt = Option.Selector( ...
        info.SYMBOL{:}, ...
        info.EXCHANGE{:}, ...
        info.VARIETY{:}, ...
        info.SIZE, '5m', ...
        info.SEC_NAME{:}, ...
        info.CALL_OR_PUT{:}, ...
        info.STRIKE, ...
        info.START_TRADE_DATE{:}, ...
        info.END_TRADE_DATE{:});
    
    fprintf("Loading %s market data, %i/%i, please wait ...\r", info.SYMBOL{:}, i, size(instrus, 1));
    dm.LoadMd(opt, dir_csv, dir_tb);
end


ds = BaseClass.DataSource.iFinD('meyqh051', '266742')
inv = EnumType.Interval.day;
ts_s = '2022-01-06 9:30';
ts_e = '2022-01-13 10:00';
[mark, md] = dm.ds.FetchMarketData(EnumType.Product.Etf, '510050', EnumType.Exchange.SSE, inv, ts_s, ts_e);
[mark, md] = dm.ds.FetchMarketData(EnumType.Product.Index, '000300', EnumType.Exchange.SSE, inv, ts_s, ts_e);
[mark, md] = dm.ds.FetchMarketData(EnumType.Product.Future, 'SR205', EnumType.Exchange.CZCE, inv, ts_s, ts_e);
[mark, md] = dm.ds.FetchMarketData(EnumType.Product.Future, 'M2205', EnumType.Exchange.DCE, inv, ts_s, ts_e);
[mark, md] = dm.ds.FetchMarketData(EnumType.Product.Future, 'SC2203', EnumType.Exchange.INE, inv, ts_s, ts_e);
[mark, md] = dm.ds.FetchMarketData(EnumType.Product.Future, 'CU2204', EnumType.Exchange.SHFE, inv, ts_s, ts_e);
[mark, md] = dm.ds.FetchMarketData(EnumType.Product.Future, 'IF2203', EnumType.Exchange.CFFEX, inv, ts_s, ts_e);
[mark, md] = dm.ds.FetchMarketData(EnumType.Product.Option, '10003776', EnumType.Exchange.SSE, inv, ts_s, ts_e);


