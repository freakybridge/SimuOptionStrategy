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
        % ��ȡ����
        curr_db = dbs{i};
        curr_tb = tbs{j};
        md = obj.db.FetchRawData(curr_db, curr_tb);
        
        % �����ʲ� / Ʒ�� / ������
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
        % ��������
        obj.dr.SaveMarketData(asset, dir_rt);
    end
    
    
    
end


end