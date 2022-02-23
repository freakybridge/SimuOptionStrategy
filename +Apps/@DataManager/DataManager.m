% DataManager
% v1.3.0.20220113.beta
%      1.���Լ�������Լ��
% v1.2.0.20220105.beta
%      1.�޸Ĺ��캯����������������ݿ������� ������Դapi"
classdef DataManager < handle
    properties (Access = private)
        db  BaseClass.Database.Database = BaseClass.Database.Database.Selector('mss', 'sa', 'bridgeisbest');
        ds  BaseClass.DataSource.DataSource= BaseClass.DataSource.DataSource.Selector('wind', nan, nan);
        dr  Apps.DataRecorder = Apps.DataRecorder();
        
        ds_pool struct;
        ds_pointer(1, 1) double;
        dir_root char;
    end
    
    % ��������
    methods
        % ���캯��
        function obj = DataManager(dir_, db_driver, db_ur, db_pwd)
            % �������ݿ�
            obj.db = BaseClass.Database.Database.Selector(db_driver, db_ur, db_pwd);
            
            % ��������Դ
            obj.AddDs('wind', nan, nan);
            obj.AddDs('ifind', 'merqh001', '146457');
            obj.AddDs('ifind', 'meyqh051', '266742');
            obj.AddDs('ifind', 'meyqh052', '193976');
            obj.AddDs('ifind', 'meyqh055', '913742');
            obj.AddDs('ifind', '00256770', '30377546');
            obj.AddDs('joinquant', '18162753893', '1101BXue');
            obj.ds = obj.AutoSwitchDataSource();
            
            % ���ø�Ŀ¼
            obj.dir_root = dir_;
        end
        
        % �������� / ���뱾��Csv���� / ������������
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
        
        % �����Լ�б�
        instrus = LoadChain(obj, pdt, var, exc);
        
        % ��������
        cal = LoadCalendar(obj);
        
        % �������ݿ�
        DatabaseBackup(obj, dir_sav);
        
        % ���ݿ⻹ԭ
        DatabaseRestore(obj, dir_bak);
        
        % ���³���
        Update(obj);
    end
    
    methods (Access = private)
        % �Ա���������
        LoadMdViaTaobaoExcel(obj, asset, dir_tb);
        
        % ��ӱ�ѡ����Դ
        function AddDs(obj, nm, usr, pwd)
            tmp = struct;
            tmp.source = nm;
            tmp.user = usr;
            tmp.password = pwd;
            tmp.status = nan; % nanδ��ʼ����0����������-1��������
            if (isempty(obj.ds_pool))
                obj.ds_pool = tmp;
            else
                obj.ds_pool(end + 1) = tmp;
            end
        end
        
        % ��ѡ��������Դ
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
        
        % ��������Դ����
        function SetDsFailure(obj)
            obj.ds_pool(obj.ds_pointer).status = -1;
        end
        
        % �ж��Ƿ���Ҫ����
        function [mark, dt_s, dt_e] = NeedUpdate(obj, asset, md_s, md_e)
            % ��ȡ�������� / ��ȡ�������
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
                % ������
                % ȷ����������յ�
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
                
                %  �ж����
                if (md_s - dt_s_o >= 1)
                    dt_s = dt_s_o;
                else
                    dt_s = md_e;
                end
                
                % �ж��յ�
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
                
                % �ж��Ƿ����
                if (dt_s == dt_e && dt_e == md_e)
                    mark = false;
                else
                    mark = true;
                end
                
            else
                % ������
                % ȷ���������
                if (asset.product == EnumType.Product.ETF || asset.product == EnumType.Product.Index)
                    dt_s = datenum(asset.GetDateInit());
                elseif (asset.product == EnumType.Product.Future || asset.product == EnumType.Product.Option)
                    dt_s =  datenum(asset.GetDateListed());
                else
                    error('Unexpected "product" for update start point determine, please check.');
                end
                
                % ȷ�������յ�
                dt_e = last_trade_date + 15 / 24;
                mark = true;
            end
            
        end
    end
    
    methods (Hidden)
        % �����ϰ汾���ݿ�
        function DatabaseBackupOldVer(obj, dir_rt, db_tar_prefix)
            % Ԥ����
            tb_ig_lst = {'CodeList', '000188.SH', 'sysdiagrams'};
            
            % ��ȡĿ�����ݿ�
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
            
            % ��һ��ȡ����
            for i = 1 : length(dbs)
                tbs = obj.db.FetchAllTables(dbs{i});
                tbs = setdiff(tbs, tb_ig_lst);
                
                for j = 1 : length(tbs)
                    % Ԥ����
                    curr_db = dbs{i};
                    curr_tb = tbs{j};
                    
                    % �����ʲ� / Ʒ�� / ������
                    [pdt, var, exc, symbol] = BasicInfo(curr_db, curr_tb);
                    inv = EnumType.Interval.day;
                    
                    % ���ɺ�Լ
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

                    
                    % ��ȡ���� / ��������
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
                    
                    % ����
                    fprintf('Saving [%s]@[%s], table [%i/%i], database [%i/%i], please wait ...\r', curr_tb, curr_db, j, length(tbs), i, length(dbs));
                    asset.MergeMarketData(md);
                    obj.dr.SaveMarketData(asset, dir_rt);
                end
                
            end
            
            % ������Ϣ
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
        
        % ������ݿ�
        function PurgeDatabase(obj, varargin)
            if (obj.db.PurgeDatabase(varargin{:}))
                disp('Database purge processure accomplished');
            else
                disp('Database purge processure failure, please check.');
            end
        end
        
    end
end

