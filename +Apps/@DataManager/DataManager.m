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

        ds_pool struct;
        ds_pointer(1, 1) double;
        dir_root char;
    end

    % 公开方法
    methods
        % 构造函数
        function obj = DataManager(dir_, db_driver, db_ur, db_pwd)
            % 配置数据库
            obj.db = BaseClass.Database.Database.Selector(db_driver, db_ur, db_pwd);
            
            % 配置数据源
            obj.AddDs('wind', nan, nan);
            obj.AddDs('ifind', 'merqh001', '146457');
            obj.AddDs('ifind', 'meyqh051', '266742');
            obj.AddDs('ifind', 'meyqh052', '193976');
            obj.AddDs('ifind', 'meyqh055', '913742');
            obj.AddDs('ifind', '00256770', '30377546');
            obj.ds = obj.AutoSwitchDataSource();

            % 配置根目录
            obj.dir_root = dir_;
        end

        % 载入行情
        LoadMd(obj, asset);

        % 载入合约列表
        instrus = LoadChain(obj, pdt, var, exc);

        % 载入日历
        cal = LoadCalendar(obj);

        % 更新数据

        % 备份数据库
        DatabaseBackupOldVer(obj, dir_rt)
        DatabaseBackup(obj, dir_sav);

        % 数据库还原
        DatabaseRestore(obj, dir_bak);

        % 更新程序
        Update(obj);
    end

    methods (Access = private)
        % 淘宝载入行情
        LoadMdViaTaobaoExcel(obj, asset, dir_tb);

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

