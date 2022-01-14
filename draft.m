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
    
    if (now() >= datenum(opt.GetDateExpire()))       
        fprintf("Loading %s market data, %i/%i, please wait ...\r", info.SYMBOL{:}, i, size(instrus, 1));
        dm.LoadMd(opt, dir_csv, dir_tb);
    end

end


BaseClass.Asset.ETF.Instance.SZSE_159919('5m')