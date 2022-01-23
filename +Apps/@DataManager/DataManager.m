% DataManager
% v1.3.0.20220113.beta
%      1.属性加入类型约束
% v1.2.0.20220105.beta
%      1.修改构造函数，加入参数“数据库驱动” “数据源api"
classdef DataManager < handle
    properties (Access = private)
        db  BaseClass.Database.Database = BaseClass.Database.Database.Selector('mss', 'sa', 'bridgeisbest');
        ds  BaseClass.DataSource.DataSource= BaseClass.DataSource.DataSource.Selector('wind', nan, nan);
        dr  Apps.DataRecorder = Apps.DataRecorder();
    end    
    properties (Access = private)
        ds_pool struct;
        ds_pointer(1, 1) double;
    end

    % 公开方法
    methods
        % 构造函数
        function obj = DataManager(db_driver, db_ur, db_pwd)
            if (~isnan(db_driver))
                obj.db = BaseClass.Database.Database.Selector(db_driver, db_ur, db_pwd);
            end
            
            obj.AddDs('wind', nan, nan);
            obj.AddDs('ifind', 'merqh001', '146457');
            obj.AddDs('ifind', 'meyqh051', '266742');
            obj.AddDs('ifind', 'meyqh052', '193976');
            obj.AddDs('ifind', 'meyqh055', '913742');
            obj.AddDs('ifind', '00256770', '30377546');
            obj.ds = obj.AutoSwitchDataSource();
        end

        % 载入行情
        LoadMd(obj, asset, dir_csv, dirt_tb);

        % 载入合约列表
        instrus = LoadChain(obj, pdt, var, exc, dir_);

        % 更新数据

        % 备份数据库（老格式）
        DatabaseBackupOldVer(obj, dir_rt)
        
        % 数据库还原
        DatabaseRestore(obj, dir_rt, prefix);
    end
    
    methods (Access = private)
        % 行情管理
        LoadMdViaDataSource(obj, asset);
        LoadMdViaTaobaoExcel(obj, asset, dirt_tb);               
        ret = IsMdComplete(obj, asset);       

        % 合约列表管理
        instrus = LoadChainViaDs(obj, pdt, var, exc, instru_local);
        ret = IsInstruNeedUpdate(obj, instrus);

        % 日历管理
        cal = LoadCal(obj);
        cal = LoadCalViaDs(obj);
        cal = LoadCalViaDb(obj);
        cal = LoadCalViaExcel(obj, dir_);        
        ret = SaveCal2Db(obj);
        ret = SaveCal2Excel(obj, dir_);

        % 添加备选数据源
        function AddDs(obj, nm, usr, pwd)
            tmp = struct;
            tmp.source = nm;
            tmp.user = usr;
            tmp.password = pwd;
            tmp.status = nan; % nan未初始化，0正常工作，-1致命错误                          
            if (isempty(obj.ds_pool))
                obj.ds_pool = tmp;
            else
                obj.ds_pool(end + 1) = tmp;
            end  
        end
        
        % 入选可用数据源
        function ret = AutoSwitchDataSource(obj)
            loc = find(isnan([obj.ds_pool.status]), 1, 'first');
            if (loc)
                obj.ds_pointer = loc;
                this = obj.ds_pool(loc);
                this.status = 0;
                ret = BaseClass.DataSource.DataSource.Selector(this.source, this.user, this.password);
                obj.ds_pool(loc) = this;
            else
                error("All dataSource failure, please check.");
            end   
        end
        
        % 设置数据源故障
        function SetDsFailure(obj)
            obj.ds_pool(obj.ds_pointer).status = -1;
        end
    end
    
end

