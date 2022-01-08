% DataManager
% v1.2.0.20220105.beta
%      1.修改构造函数，加入参数“数据库驱动” “数据源api"
classdef DataManger
    properties
        db;
        ds;
    end    

    
    methods
        function obj = DataManger(db_driver, ds_api)
            if (~isnan(db_driver))
                obj.db = BaseClass.Database.Database.Selector(db_driver, 'sa', 'bridgeisbest');
            end
            if (~isnan(ds_api))
                obj.ds = BaseClass.DataSource.DataSource.Selector(ds_api, '00256770', '30377546');
            end
        end
        
    end
    
    methods 
        
        ret = TransferTaobaoExcel(obj, dir_hm, dir_tb, dir_sav);        
        
        LoadMdViaCsv(obj, ast);
        LoadMdViaDatabase(obj, ast);
        LoadMdViaDataSource(obj, ast);
        
        SaveMd2Database(obj, ast);
        SaveMd2Csv(obj, dir_in, ast);
        
    end
end

