% DataManager / DatabaseBackup
% v1.3.0.20220113.beta
%      1.首次加入
function DatabaseBackup(obj, dir_rt, db_ig_lst, tb_ig_lst)

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
        
        % 生成合约
        switch pdt
            case {EnumType.Product.ETF, EnumType.Product.Index}
                asset = BaseClass.Asset.Asset.Selector(pdt, var, exc, '1d');
            case EnumType.Product.Option
                symbol = curr_tb(1 : strfind(curr_tb, '.') - 1);
                asset = BaseClass.Asset.Asset.Selector(pdt, var, exc, symbol, 'sec_name', '1d', 10000, 'c', 999, datestr(now()), datestr(now()));
            case EnumType.Product.Future
                disp(1234);

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
        end
        
        % 保存
        fprintf('Saving [%s]@[%s], table [%i/%i], database [%i/%i], please wait ...\r', curr_tb, curr_db, j, length(tbs), i, length(dbs));
        asset.MergeMarketData(md);        
        obj.dr.SaveMarketData(asset, dir_rt);
    end
    
end

end