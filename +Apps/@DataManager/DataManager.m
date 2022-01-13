% DataManager
% v1.2.0.20220105.beta
%      1.修改构造函数，加入参数“数据库驱动” “数据源api"
classdef DataManager
    properties
        db;
        ds;
    end    
    properties (Access = private)
        ds_pool;
    end

    % 公开方法
    methods
        function obj = DataManager(db_driver, db_ur, db_pwd)
            if (~isnan(db_driver))
                obj.db = BaseClass.Database.Database.Selector(db_driver, db_ur, db_pwd);
            end
            
            obj.ds_pool = obj.AddDs('wind', nan, nan);
            obj.ds_pool(end + 1) = obj.AddDs('ifind', 'merqh001', '146457');
            obj.ds_pool(end + 1) = obj.AddDs('ifind', 'meyqh051', '266742');
            obj.ds_pool(end + 1) = obj.AddDs('ifind', 'meyqh052', '193976');
            obj.ds_pool(end + 1) = obj.AddDs('ifind', 'meyqh055', '913742');
            obj.ds_pool(end + 1) = obj.AddDs('ifind', '00256770', '30377546');
        end
    end
    
    methods
        LoadMd(obj, ast, dir_csv, dirt_tb);
        LoadMdViaCsv(obj,  ast, dir_csv);
        LoadMdViaDatabase(obj, ast);
        LoadMdViaDataSource(obj, ast);
        LoadMdViaTaobaoExcel(obj, ast, dirt_tb);        
        
        ret = SaveMd2Database(obj, ast);
        ret = SaveMd2Csv(obj, ast, dir_csv);                
        ret = IsMdComplete(obj, ast);       
                
        instrus = LoadOptChain(obj, var, exc, dir_);
        instrus = LoadOptChainViaDb(obj, var, exc);
        instrus = LoadOptChainViaDs(obj, var, exc, instru_local);
        instrus = LoadOptChainViaExcel(obj, var, exc, dir_);
        
        ret = SaveOptChain2Db(obj, var, exc, instrus);
        ret = SaveOptChain2Excel(obj, var, exc, instrus, dir_);
        ret = IsInstruNeedUpdate(obj, instrus);
    end
    
    methods (Access = private)
        % 添加数据源
        function ret = AddDs(obj, nm, usr, pwd)
            ret = struct;
            ret.source = nm;
            ret.user = usr;
            ret.password = pwd;
            ret.status = nan; % nan未初始化，0正常工作，-1致命错误            
        end
        
        ds = AutoSwitchDataSource(obj);        
    end
    
end

