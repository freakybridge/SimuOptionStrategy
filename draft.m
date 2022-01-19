clear;
clc;

import Apps.DataManager;
import BaseClass.Asset.Option.Option;
import EnumType.Product;


% dm = DataManager('mss', 'sa', 'bridgeisbest');
% dir_tb = 'C:\Users\freakybridge\Desktop\taobao';
% dir_csv = "E:\OneDrive\hisdata";
% dir_rt = "E:\OneDrive\hisdata";

dm = DataManager('mss', 'sa', 'bridgeinmfc');
dir_tb = 'C:\Users\dell\Desktop\taobao';
dir_csv = "D:\OneDrive\hisdata";
dir_rt = "D:\OneDrive\hisdata";

for i = 1 : 2
    if (i == 1)
        product = Product.Option;
        variety = '510050';
        exchange = 'sse';
    else
        product = Product.Option;
        variety = '510300';
        exchange = 'sse';
    end
    
    
    instrus = dm.LoadChain(product, variety, exchange, dir_rt);
    for j = 1 : size(instrus, 1)
        info = instrus(j, :);
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
        
        fprintf("Loading %s market data, %i/%i, please wait ...\r", info.SYMBOL{:}, j, size(instrus, 1));
        dm.LoadMd(opt, dir_csv, dir_tb);
    end
end


variety = '510300';
exchange = 'sse';
instrus = dm.db.LoadChainOption(variety, exchange);
er = BaseClass.ExcelReader();
er.SaveChain(EnumType.Product.Option, variety, exchange, instrus, 'C:\Users\dell\Desktop\');
tt = er.LoadChain(EnumType.Product.Option, variety, exchange, 'C:\Users\dell\Desktop\');



ts_s = '2022-01-6 9:30';
ts_e = '2022-01-13 10:00';
% dm.ds = BaseClass.DataSource.iFinD('meyqh055', '913742');
ds = BaseClass.DataSource.Wind();

asset = BaseClass.Asset.ETF.Instance.SSE_510050('1d');
[mark, md] = ds.FetchMarketData(asset.product, asset.symbol, asset.exchange, asset.interval, ts_s, ts_e);
asset.MergeMarketData(md);
er.SaveMarketData(asset, "C:\Users\dell\Desktop\");
er.LoadMarketData(asset, "C:\Users\dell\Desktop\");


asset = BaseClass.Asset.Option.Instance.SSE_510050('10003776', 'abc', '1d', 10000, 'c', 3.0, now(), now());
[mark, md] = ds.FetchMarketData(asset.product, asset.symbol, asset.exchange, asset.interval, ts_s, ts_e);
asset.MergeMarketData(md);
er.SaveMarketData(asset, "C:\Users\dell\Desktop\");
er.LoadMarketData(asset, "C:\Users\dell\Desktop\");



asset = BaseClass.Asset.Index.Instance.SSE_000016('1d');
[mark, md] = ds.FetchMarketData(asset.product, asset.symbol, asset.exchange, asset.interval, ts_s, ts_e);
asset.MergeMarketData(md);
er.SaveMarketData(asset, "C:\Users\dell\Desktop\");
er.LoadMarketData(asset, "C:\Users\dell\Desktop\");


asset = BaseClass.Asset.Future.Instance.DCE_M('M2205', 'abc', '1d', 10, now(), 0.1, 1, 5);
[mark, md] = ds.FetchMarketData(asset.product, asset.symbol, asset.exchange, asset.interval, ts_s, ts_e);
asset.MergeMarketData(md);
er.SaveMarketData(asset, "C:\Users\dell\Desktop\");
er.LoadMarketData(asset, "C:\Users\dell\Desktop\");


asset = BaseClass.Asset.Future.Instance.CZCE_SR('SR205', 'abc', '1d', 10, now(), 0.1, 1, 5);
[mark, md] = dm.ds.FetchMarketData(asset.product, asset.symbol, asset.exchange, asset.interval, ts_s, ts_e);
asset.MergeMarketData(md);
dm.db.SaveMarketData(asset);
dm.db.LoadMarketData(asset);


asset = BaseClass.Asset.Future.Instance.SHFE_CU('CU2205', 'abc', '1d', 10, now(), 0.1, 1, 5);
[mark, md] = dm.ds.FetchMarketData(asset.product, asset.symbol, asset.exchange, asset.interval, ts_s, ts_e);
asset.MergeMarketData(md);
dm.db.SaveMarketData(asset);
dm.db.LoadMarketData(asset);
open(asset.md);

asset = BaseClass.Asset.Future.Instance.INE_SC('SC2205', 'abc', '1d', 10, now(), 0.1, 1, 5);
[mark, md] = dm.ds.FetchMarketData(asset.product, asset.symbol, asset.exchange, asset.interval, ts_s, ts_e);
asset.MergeMarketData(md);
dm.db.SaveMarketData(asset);
dm.db.LoadMarketData(asset);
open(asset.md);

asset = BaseClass.Asset.Future.Instance.CFFEX_IF('IF2203', 'abc', '1d', 10, now(), 0.1, 1, 5);
[mark, md] = dm.ds.FetchMarketData(asset.product, asset.symbol, asset.exchange, asset.interval, ts_s, ts_e);
asset.MergeMarketData(md);
dm.db.SaveMarketData(asset);
dm.db.LoadMarketData(asset);
open(asset.md);