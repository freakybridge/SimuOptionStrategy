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
    
    methods (Static)
        ret = TransferTaobaoExcel(dir_hm, dir_tb, dir_sav);        
        
        function Database2Md(ast)
            obj.db.LoadMarketData(ast);
        end
        function ret = Md2Database(ast)
            ret = obj.db.SaveMarketData(ast);
        end
        
        DataSource2Md();
        Csv2Md(dir_in, ast);        
        ret = Md2Csv(dir_out, ast);
    end
end

