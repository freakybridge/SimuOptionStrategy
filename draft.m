clear;
clc;

import Apps.DataManager;
import BaseClass.Asset.Asset;
import EnumType.Product;
import EnumType.Exchange;


dm = DataManager('mss', 'sa', 'bridgeisbest');
dir_tb = 'C:\Users\freakybridge\Desktop\taobao';
dir_csv = "E:\OneDrive\hisdata";
dir_rt = "E:\OneDrive\hisdata";

% dm = DataManager('mss', 'sa', 'bridgeinmfc');
% dir_tb = 'C:\Users\dell\Desktop\taobao';
% dir_csv = "D:\OneDrive\hisdata";
% dir_rt = "D:\OneDrive\hisdata";
% 
% db_ig_lst = {'1D-ETF', '1D-FUTURE-CU-SHFE', '1D-FUTURE-IF-CFFEX', '1D-FUTURE-M-DCE', '1D-FUTURE-SC-INE', '1D-FUTURE-SR-CZCE', '1D-INDEX', '1D-OPTION-510050-SSE', '1MIN-ETF', ...
%     '5MIN-OPTION-510050-SSE', '5MIN-OPTION-510300-SSE', 'Calendar', 'Interest', 'master', 'model', 'msdb',  'tempdb', 'INSTRUMENTS', 'ReportServer$BRIDGE', 'ReportServer$BRIDGETempDB', ...
%     'Tushare_calendar', 'Tushare_fund', 'Tushare_index', 'Tushare_interest', '1D-OPTION-510300-SSE', 'ReportServer$BRIDGE_DB', 'ReportServer$BRIDGE_DBTempDB', 'Future_ME_CZC', ...
%     'Future_TC_CZC', 'Future_WT_CZC', 'Future_WS_CZC'};
% tb_ig_lst = {'CodeList', '000188.SH'};
% dm.DatabaseBackup('C:\Users\freakybridge\Desktop\Backup', db_ig_lst, tb_ig_lst);
% dm.DatabaseRestore(dir_rt, '1D');



for i = 1 : 2
    if (i == 1)
        product = Product.Option;
        variety = '510050';
        exchange = Exchange.SSE;
    else
        product = Product.Option;
        variety = '510300';
        exchange = Exchange.SSE;
    end
    
    
    instrus = dm.LoadChain(product, variety, exchange, dir_rt);
    for j = 1 : size(instrus, 1)
        info = instrus(j, :);
        opt = Asset.Selector(product, variety, exchange, ...
            info.SYMBOL{:}, ...
            info.SEC_NAME{:}, ...
            EnumType.Interval.min5, ...
            info.SIZE, ...
            EnumType.CallOrPut.ToEnum(info.CALL_OR_PUT{:}), ...
            info.STRIKE, ...
            info.START_TRADE_DATE{:}, ...
            info.END_TRADE_DATE{:});
        
        fprintf("Loading [%s.%s]'s quetos, [%i/%i], please wait ...\r", info.SYMBOL{:}, info.EXCHANGE{:}, j, size(instrus, 1));
        dm.LoadMd(opt, dir_csv, dir_tb);
    end
end


ttt = BaseClass.Asset.Option.Instance.SHFE_AU('symbol', 'sec name', EnumType.Interval.min5, 1000, EnumType.CallOrPut.Call, 3.55, datestr(now()), datestr(now), ...
    'future symbol', 'future sec_name', 1000, datestr(now()), datestr(now()), 0.12, 1, 3.5);

ttt = BaseClass.Asset.Option.Instance.DCE_PG('symbol', 'sec name', EnumType.Interval.min5, 1000, EnumType.CallOrPut.Call, 3.55, datestr(now()), datestr(now), ...
    'future symbol', 'future sec_name', 1000, datestr(now()), datestr(now()), 0.12, 1, 3.5);

ttt = BaseClass.Asset.Option.Instance.CFFEX_IO('symbol', 'sec name', EnumType.Interval.min5, 1000, EnumType.CallOrPut.Call, 3.55, datestr(now()), datestr(now));





