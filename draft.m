clear;
clc;
dm = Apps.DataManager('mss', 'sa', 'bridgeisbest', 'wind', 'merqh001', '146457');
dir_tb = 'C:\Users\freakybridge\Desktop\taobao';
dir_csv = 'C:\Users\freakybridge\Desktop\taobao\final';
dir_rt = "E:\OneDrive\hisdata";


variety = '510050';
exchange = 'sse';
instrus = dm.LoadOptChain("510050", "SSE", dir_rt);
for i = 1 : size(instrus, 1)
    info = instrus(i, :);    
    opt = BaseClass.Asset.Option.Option.Selector( ...
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

