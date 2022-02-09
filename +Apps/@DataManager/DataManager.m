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
        LoadMd(obj, asset, sw_csv);

        % 载入合约列表
        instrus = LoadChain(obj, pdt, var, exc);

        % 载入日历
        cal = LoadCalendar(obj);

        % 更新数据

        % 备份数据库
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
        
        % 判定是否需要更新
        function [mark, dt_s, dt_e] = NeedUpdate(obj, asset, md_s, md_e)
            % 读取交易日历 / 获取最后交易日
            persistent cal;
            if (isempty(cal))
                cal = obj.LoadCalendar();
            end
            if hour(now()) >= 15
                td = now();
            else
                td = now() - 1;
            end
            last_trade_date = find(cal(:, 5) <= td, 1, 'last');
            last_trade_date = cal(find(cal(1 : last_trade_date, 2) == 1, 1, 'last'), 5);
            
            if (~isnan(md_s + md_e))
                % 有行情
                % 确定理论起点终点
                if (asset.product == EnumType.Product.ETF)
                    dt_s_o = datenum(asset.GetDateInit()) + 40;
                    dt_e_o = last_trade_date + 15 / 24;
                elseif (asset.product == EnumType.Product.Index)
                    dt_s_o = datenum(asset.GetDateInit());
                    dt_e_o = last_trade_date + 15 / 24;
                elseif (asset.product == EnumType.Product.Future || asset.product == EnumType.Product.Option)
                    dt_s_o =  datenum(asset.GetDateListed());
                    dt_e_o = datenum(asset.GetDateExpire());
                    if (dt_e_o > last_trade_date)
                        dt_e_o = last_trade_date + 15 / 24;
                    end
                else
                    error('Unexpected "product" for update start point determine, please check.');
                end
                                
                %  判定起点
                if (md_s - dt_s_o >= 1)
                    dt_s = dt_s_o;
                else
                    dt_s = md_e;
                end
                
                % 判定终点
                if (asset.interval == EnumType.Interval.min1 || asset.interval == EnumType.Interval.min5)
                    if (dt_e_o - md_e < 15 / 60 / 24)
                        dt_e = md_e;
                    else
                        dt_e = dt_e_o;
                    end
                    
                elseif (asset.interval == EnumType.Interval.day)
                    dt_e_o = floor(dt_e_o);
                    if (dt_e_o - md_e < 1)
                        dt_e = md_e;
                    else
                        dt_e = dt_e_o;
                    end
                else
                    error("Unexpected 'interval' for market data accomplished judgement, please check.");
                end
                
                % 判定是否更新
                if (dt_s == dt_e && dt_e == md_e)
                    mark = false;
                else
                    mark = true;
                end
                
            else
                % 无行情
                % 确定更新起点
                if (asset.product == EnumType.Product.ETF || asset.product == EnumType.Product.Index)
                    dt_s = datenum(asset.GetDateInit());
                elseif (asset.product == EnumType.Product.Future || asset.product == EnumType.Product.Option)
                    dt_s =  datenum(asset.GetDateListed());
                else
                    error('Unexpected "product" for update start point determine, please check.');
                end
                
                % 确定更新终点
                dt_e = last_trade_date + 15 / 24;
                mark = true;
            end
            
        end
    end

end

