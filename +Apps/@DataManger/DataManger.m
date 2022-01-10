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
        function obj = DataManger(db_driver, db_ur, db_pwd, ds_api, ds_ur, ds_pwd)
            if (~isnan(db_driver))
                obj.db = BaseClass.Database.Database.Selector(db_driver, db_ur, db_pwd);
            end
            if (~isnan(ds_api))
                obj.ds = BaseClass.DataSource.DataSource.Selector(ds_api, ds_ur, ds_pwd);
            end
        end
        
        LoadMd(obj, ast, dir_csv, dirt_tb);
        LoadMdViaCsv(obj,  ast, dir_csv);
        LoadMdViaDatabase(obj, ast);
        LoadMdViaDataSource(obj, ast);
        LoadMdViaTaobaoExcel(obj, ast, dirt_tb);
        
        SaveMd2Database(obj, ast);
        SaveMd2Csv(obj, ast, dir_csv);
                
        ret = IsDataComplete(obj, ast);      
                
    end
    
end

