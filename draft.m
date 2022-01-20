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

% db_ig_lst = {'1D-ETF', '1D-FUTURE-CU-SHFE', '1D-FUTURE-IF-CFFEX', '1D-FUTURE-M-DCE', '1D-FUTURE-SC-INE', '1D-FUTURE-SR-CZCE', '1D-INDEX', '1D-OPTION-510050-SSE', '1MIN-ETF', ...
%     '5MIN-OPTION-510050-SSE', '5MIN-OPTION-510300-SSE', 'Calendar', 'Interest', 'master', 'model', 'msdb',  'tempdb', 'INSTRUMENTS'};
% tb_ig_lst = {'CodeList'};
% dm.DatabaseBackup('C:\Users\dell\Desktop', db_ig_lst, tb_ig_lst);

for i = 1 : 2
    if (i == 1)
        product = Product.Option;
        variety = '510300';
        exchange = 'sse';
    else
        product = Product.Option;
        variety = '510050';
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
        
        fprintf("Loading [%s.%s]'s market data, %i/%i, please wait ...\r", info.SYMBOL{:}, info.EXCHANGE{:}, j, size(instrus, 1));
        dm.LoadMd(opt, dir_csv, dir_tb);
    end
end


a = BaseClass.Asset.Asset.Selector(EnumType.Product.ETF, EnumType.Exchange.SSE, '510050', '5m');
a = BaseClass.Asset.Asset.Selector(EnumType.Product.ETF, EnumType.Exchange.SSE, '510300', '5m');
a = BaseClass.Asset.Asset.Selector(EnumType.Product.ETF, EnumType.Exchange.SZSE, '159919', '5m');

