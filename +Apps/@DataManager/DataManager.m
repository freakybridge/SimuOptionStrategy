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
            obj.AddDs('joinquant', '18162753893', '1101BXue');
            obj.ds = obj.AutoSwitchDataSource();
            
            % 配置根目录
            obj.dir_root = dir_;
        end
        
        % 载入行情 / 载入本地Csv行情 / 载入在线行情
        LoadMd(obj, asset, sw_csv);
        function [md, mk_upd, dt_s, dt_e] = LoadMdViaCsv(obj, asset)
            md = obj.dr.LoadMarketData(asset, obj.dir_root);
            if (~isempty(md))
                [mk_upd, dt_s, dt_e] = obj.NeedUpdate(asset, md(1, 1), md(end, 1));
            else
                [mk_upd, dt_s, dt_e] = obj.NeedUpdate(asset, nan, nan);
            end
        end
        function md = LoadViaDs(obj, asset, dt_s, dt_e)
            while (true)
                [is_err, md] = obj.ds.FetchMarketData(asset.product, asset.symbol, asset.exchange, asset.interval, dt_s, dt_e);
                if (is_err)
                    obj.SetDsFailure();
                    obj.ds.LogOut();
                    obj.ds = [];
                    obj.ds = obj.AutoSwitchDataSource();
                    continue;
                end
                return;
            end
        end
        
        % 载入合约列表
        instrus = LoadChain(obj, pdt, var, exc);
        
        % 载入日历
        cal = LoadCalendar(obj);
        
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
    
    methods (Hidden)
        % 备份老版本数据库
        function DatabaseBackupOldVer(obj, dir_rt, db_tar_prefix)
            % 预处理
            tb_ig_lst = {'CodeList', '000188.SH', 'sysdiagrams'};
            
            % 读取目标数据库
            dbs = obj.db.FetchAllDbs();
            for i = length(dbs) : -1 : 1
                this = dbs{i};
                for j = db_tar_prefix
                    if (contains(this, j{:}))
                        mark = false;
                        break;
                    else
                        mark = true;
                    end
                end
                if (mark)
                    dbs(i)= [];
                end
            end
            
            % 逐一读取数据
            for i = 1 : length(dbs)
                tbs = obj.db.FetchAllTables(dbs{i});
                tbs = setdiff(tbs, tb_ig_lst);
                
                for j = 1 : length(tbs)
                    % 预处理
                    curr_db = dbs{i};
                    curr_tb = tbs{j};
                    
                    % 生成资产 / 品种 / 交易所
                    [pdt, var, exc, symbol] = BasicInfo(curr_db, curr_tb);
                    inv = EnumType.Interval.day;
                    
                    % 生成合约
                    switch pdt
                        case {EnumType.Product.ETF, EnumType.Product.Index}
                            asset = BaseClass.Asset.Asset.Selector(pdt, var, exc, inv);
                        case EnumType.Product.Option
                            asset = BaseClass.Asset.Option.Option.Sample(var, exc, inv, []);
                            
                        case EnumType.Product.Future
                            symbol = curr_tb(1 : strfind(curr_tb, '.') - 1);
                            asset = BaseClass.Asset.Asset.Selector(pdt, var, exc, symbol, 'sec_name', inv, 10000, datestr(now()), datestr(now()), 0.12, 1, 0.5);
                    end
                    asset.symbol = symbol;

                    
                    % 读取数据 / 整理数据
                    md = obj.db.FetchRawData(curr_db, curr_tb);
                    if (isempty(md))
                        continue;
                    end
                    md(:, 1) = [];
                    switch pdt
                        case EnumType.Product.ETF
                            md(logical(sum(isnan(md), 2)), :) = [];
                            
                        case EnumType.Product.Index
                            md(logical(sum(isnan(md), 2)), :) = [];
                            
                        case EnumType.Product.Option
                            md = md(:, [1 : 10, 20 : 21]);
                            
                        case EnumType.Product.Future
                            md(:, [8, 13]) = [];
                            md(isnan(md)) = 0;
                        otherwise
                            error('unexpected condition');
                    end
                    
                    % 保存
                    fprintf('Saving [%s]@[%s], table [%i/%i], database [%i/%i], please wait ...\r', curr_tb, curr_db, j, length(tbs), i, length(dbs));
                    asset.MergeMarketData(md);
                    obj.dr.SaveMarketData(asset, dir_rt);
                end
                
            end
            
            % 基础信息
            function [pdt_, var_, exc_, sym_] = BasicInfo(db_, tb_)
                loc_ = strfind(db_, '_');
                if (isempty(loc_))
                    if (strcmp(db_, 'Fund'))
                        pdt_ = EnumType.Product.ETF;
                        loc_ = strfind(tb_, '.');
                        var_ = tb_(1 : loc_(1) - 1);
                        switch var_
                            case '510050'
                                exc_ = EnumType.Exchange.SSE;
                            case '510300'
                                exc_ = EnumType.Exchange.SSE;
                            case '159919'
                                exc_ = EnumType.Exchange.SZSE;
                        end
                    else
                        pdt_ = EnumType.Product.ToEnum(db_);
                        loc_ = strfind(tb_, '.');
                        var_ = tb_(1 : loc_(1) - 1);
                        exc_ = EnumType.Exchange.ToEnum(tb_(loc_(1) + 1 : end));
                    end
                    sym_ = var_;
                else
                    pdt_ = EnumType.Product.ToEnum(db_(1 : loc_(1) - 1));
                    var_ = db_(loc_(1) + 1 : loc_(2) - 1);
                    exc_ = EnumType.Exchange.ToEnum(db_(loc_(2) + 1 : end));
                    sym_ = tb_;
                end
            end
            
        end
        
        % 清除数据库
        function PurgeDatabase(obj, varargin)
            if (obj.db.PurgeDatabase(varargin{:}))
                disp('Database purge processure accomplished');
            else
                disp('Database purge processure failure, please check.');
            end
        end
        
    end
end

