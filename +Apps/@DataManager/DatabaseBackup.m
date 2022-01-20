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
    
    for j = 1 : length(dbs)
        % 读取数据
        curr_db = dbs{i};
        curr_tb = tbs{j};
        md = obj.db.FetchRawData(curr_db, curr_tb);
        
        % 生成资产 / 品种 / 交易所
        loc = strfind(curr_db, '_');
        if (isempty(loc))
            if (strcmp(curr_db, 'Fund'))
                pdt = EnumType.Product.ETF;
                loc = strfind(curr_tb, '.');
                var = curr_tb(1 : loc(1) - 1);
                exc = [];
            else
                pdt = EnumType.Product.ToEnum(curr_db);
                loc = strfind(curr_tb, '.');
                var = curr_tb(1 : loc(1) - 1);
                exc = EnumType.Exchange.ToEnum(curr_tb(loc(1) + 1 : end);
            end
        else
            pdt = EnumType.Product.ToEnum(curr_db(1 : loc(1) - 1));
            var = curr_db(loc(1) + 1 : loc(2) - 1);
            exc = EnumType.Exchange.ToEnum(curr_db(loc(2) + 1 : end));
        end
        
        
        
        
        
        asset
        obj.db.LoadMarketData(asset);
        % 整理数据
        obj.dr.SaveMarketData(asset, dir_rt);
    end
    
    
    
end


end