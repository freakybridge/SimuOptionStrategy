% DataManager / DatabaseBackupOld
% v1.3.0.20220113.beta
%      1.首次加入
function DatabaseBackupOldVer(obj, dir_rt)
% 预处理
db_ig_lst = {'1D-ETF', '1D-FUTURE-CU-SHFE', '1D-FUTURE-IF-CFFEX', '1D-FUTURE-M-DCE', '1D-FUTURE-SC-INE', '1D-FUTURE-SR-CZCE', '1D-INDEX', '1D-OPTION-510050-SSE', '1MIN-ETF', ...
    '5MIN-OPTION-510050-SSE', '5MIN-OPTION-510300-SSE', 'Calendar', 'Interest', 'master', 'model', 'msdb',  'tempdb', 'INSTRUMENTS', 'ReportServer$BRIDGE', 'ReportServer$BRIDGETempDB', ...
    'Tushare_calendar', 'Tushare_fund', 'Tushare_index', 'Tushare_interest', '1D-OPTION-510300-SSE', 'ReportServer$BRIDGE_DB', 'ReportServer$BRIDGE_DBTempDB', 'Future_ME_CZC', ...
    'Future_TC_CZC', 'Future_WT_CZC', 'Future_WS_CZC', 'Future_IM_SHF'};
tb_ig_lst = {'CodeList', '000188.SH', 'sysdiagrams'};

% 读取所有数据库
dbs = obj.db.FetchAllDbs();
dbs = setdiff(dbs, db_ig_lst);

% 逐一读取数据
for i = 1 : length(dbs)
    tbs = obj.db.FetchAllTables(dbs{i});
    tbs = setdiff(tbs, tb_ig_lst);
    
    for j = 1 : length(tbs)
        % 读取数据
        curr_db = dbs{i};
        curr_tb = tbs{j};
        
        % 生成资产 / 品种 / 交易所
        loc = strfind(curr_db, '_');
        if (isempty(loc))
            if (strcmp(curr_db, 'Fund'))
                pdt = EnumType.Product.ETF;
                loc = strfind(curr_tb, '.');
                var = curr_tb(1 : loc(1) - 1);
                switch var
                    case '510050'
                        exc = EnumType.Exchange.SSE;
                    case '510300'
                        exc = EnumType.Exchange.SSE;
                    case '159919'
                        exc = EnumType.Exchange.SZSE;
                end
            else
                pdt = EnumType.Product.ToEnum(curr_db);
                loc = strfind(curr_tb, '.');
                var = curr_tb(1 : loc(1) - 1);
                exc = EnumType.Exchange.ToEnum(curr_tb(loc(1) + 1 : end));
            end
        else
            pdt = EnumType.Product.ToEnum(curr_db(1 : loc(1) - 1));
            var = curr_db(loc(1) + 1 : loc(2) - 1);
            exc = EnumType.Exchange.ToEnum(curr_db(loc(2) + 1 : end));
        end
        inv = EnumType.Interval.day;
        
        % 生成合约
        switch pdt
            case {EnumType.Product.ETF, EnumType.Product.Index}
                asset = BaseClass.Asset.Asset.Selector(pdt, var, exc, inv);
            case EnumType.Product.Option
                switch var
                    case {'510050', '510300', '159919'}
                        symbol = curr_tb(1 : strfind(curr_tb, '.') - 1);
                        asset = BaseClass.Asset.Asset.Selector(pdt, var, exc, symbol, 'sec_name', inv, 10000, EnumType.CallOrPut.Call, 999, datestr(now()), datestr(now()));
                    otherwise
                        symbol = curr_tb(1 : strfind(curr_tb, '.') - 1);
                        asset = BaseClass.Asset.Asset.Selector(pdt, var, exc, symbol, 'sec_name', inv, 10000, EnumType.CallOrPut.Call, 999, datestr(now()), datestr(now()), ...
                            'future symbol', 'future sec name', 10000, datestr(now()), datestr(now()), 0.12, 1, 0.5);
                end
                        
            case EnumType.Product.Future
                symbol = curr_tb(1 : strfind(curr_tb, '.') - 1);
                asset = BaseClass.Asset.Asset.Selector(pdt, var, exc, symbol, 'sec_name', inv, 10000, datestr(now()), datestr(now()), 0.12, 1, 0.5);
        end
                
        
        % 读取数据 / 整理数据
        md = obj.db.FetchRawData(curr_db, curr_tb);
        md(:, 1) = [];
        switch pdt
            case EnumType.Product.ETF
                loc = logical(sum(isnan(md), 2));
                md(loc, :) = [];
                md(:, 8 : 9) = md(:, [9, 8]);
                
            case EnumType.Product.Index
                loc = logical(sum(isnan(md), 2));
                md(loc, :) = [];
                md(:, 6 : 7) = md(:, [7, 6]);
                
            case EnumType.Product.Option
                md = md(:, [1 : 10, 20 : 21]);
                md(:, 6 : 7) = md(:, [7, 6]);

            case EnumType.Product.Future
                md(:, [8, 13]) = [];
                md(:, 6 : 7) = md(:, [7, 6]);
                md(isnan(md)) = 0;
            otherwise
                error('unexpected condition');
        end
        
        % 保存
        fprintf('Saving [%s]@[%s], table [%i/%i], database [%i/%i], please wait ...\r', curr_tb, curr_db, j, length(tbs), i, length(dbs));
        asset.MergeMarketData(md);        
        obj.dr.SaveMarketData(asset, dir_rt);
    end
    
end

end