% DataManager
% v1.2.0.20220105.beta
%      1.修改构造函数，加入参数“数据库驱动” “数据源api"
classdef DataManger
    properties
        db;
        ds;
    end    

    % 公开方法
    methods
        function obj = DataManger(db_driver, ds_api)
            if (~isnan(db_driver))
                obj.db = BaseClass.Database.Database.Selector(db_driver, 'sa', 'bridgeisbest');
            end
            if (~isnan(ds_api))
                obj.ds = BaseClass.DataSource.DataSource.Selector(ds_api, '00256770', '30377546');
            end
        end
        
        LoadMd(obj, ast, dir_csv, dirt_tb);
        LoadMdViaCsv(obj,  ast, dir_csv);
        LoadMdViaDatabase(obj, ast);
        LoadMdViaDataSource(obj, ast);
        LoadMdViaTaobaoExcel(obj, ast, dirt_tb);
        
        SaveMd2Database(obj, ast);
        SaveMd2Csv(obj, ast, dir_csv);
                
    end
    
    % 私有方法
    methods (Access = private)
        ret = IsDataComplete(obj, ast);       
        
    end
end

