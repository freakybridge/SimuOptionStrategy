% DataManager / DatabaseBackup
% v1.3.0.20220113.beta
%      1.�״μ���
function DatabaseBackup(obj, dir_rt, db_ig_lst, tb_ig_lst)

% ��ȡ�������ݿ�
dbs = obj.db.FetchAllDbs();
dbs = setdiff(dbs, db_ig_lst);

% ��һ��ȡ����
for i = 1 : length(dbs)
    tbs = obj.db.FetchAllTables(dbs{i});
    tbs = setdiff(tbs, tb_ig_lst);
    
    for j = 1 : length(dbs)
        curr_db = dbs{i};
        curr_tb = db{j};
        
        
        
        asset
        obj.db.LoadMarketData(asset);
        % ��������
        obj.dr.SaveMarketData(asset, dir_rt);
    end
    
    
    
end


end