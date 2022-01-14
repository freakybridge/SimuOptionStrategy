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


variety = '510050';
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
BaseClass.Asset.Future.Instance.INE_SC('SC2205', '原油期货2205', '5m', 1000, now(), 0.12, 1, 2 / 10000)
BaseClass.Asset.Future.Instance.CFFEX_IF('IF2203', '沪深300股指期货2203', '5m', 300, now(), 0.12, 1, 2 / 10000)
BaseClass.Asset.Future.Instance.CZCE_SR('SR209', '郑糖2209', '5m', 10, now(), 0.12, 1, 2 / 10000)
BaseClass.Asset.Future.Instance.DCE_M('M2209', '豆粕2205', '5m', 10, now(), 0.12, 1, 2 / 10000)
BaseClass.Asset.Future.Instance.SHFE_CU('CU2205', '沪铜2205', '5m', 10, now(), 0.12, 1, 2 / 10000)