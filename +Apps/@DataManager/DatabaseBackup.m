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
        curr_db = dbs{i};
        curr_tb = db{j};
        
        
        
        asset
        obj.db.LoadMarketData(asset);
        % 整理数据
        obj.dr.SaveMarketData(asset, dir_rt);
    end
    
    
    
end


end