clear;
clc;

import Apps.DataManager;
import BaseClass.Asset.Option.Option;


dm = DataManager('mss', 'sa', 'bridgeisbest');
dir_tb = 'C:\Users\freakybridge\Desktop\taobao';
dir_csv = "E:\OneDrive\hisdata";
dir_rt = "E:\OneDrive\hisdata";

% dm = DataManager('mss', 'sa', 'bridgeinmfc');
% dir_tb = 'D:\desktop\taobao';
% dir_csv = "D:\OneDrive\hisdata";
% dir_rt = "D:\OneDrive\hisdata";


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


opt = Option.Selector( ...
    info.SYMBOL{:}, ...
    info.EXCHANGE{:}, ...
    info.VARIETY{:}, ...
    info.SIZE, '1d', ...
    info.SEC_NAME{:}, ...
    info.CALL_OR_PUT{:}, ...
    info.STRIKE, ...
    info.START_TRADE_DATE{:}, ...
    info.END_TRADE_DATE{:});


ts_s = opt.GetDateListed();
ts_e = opt.GetDateExpire();

ret = dm.ds.FetchMinMdOption(opt, ts_s, ts_e, 5);


idx = BaseClass.Asset.Index.Instance.SSE_000001('1m');
ts_s = '2022-01-13 09:30';
ts_e = '2022-01-13 10:30';
[ttt, md] = dm.ds.FetchMinMdIndex(idx, ts_s, ts_e, 5);


idx = BaseClass.Asset.ETF.Instance.SSE_510050('1m');
ts_s = '2022-01-13 09:30';
ts_e = '2022-01-13 10:30';
[ttt, md] = dm.ds.FetchMinMdEtf(idx, ts_s, ts_e, 5);


idx = BaseClass.Asset.Future.Instance.CZCE_SR('sr205', 'aaa', '5m', 10, now, 0.12, 1, 2);
ts_s = '2022-01-13 09:30';
ts_e = '2022-01-13 10:30';
[ttt, md] = dm.ds.FetchMinMdFuture(idx, ts_s, ts_e, 5);


