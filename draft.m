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

