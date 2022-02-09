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
            obj.ds = obj.AutoSwitchDataSource();

            % ���ø�Ŀ¼
            obj.dir_root = dir_;
        end

        % ��������
        LoadMd(obj, asset, sw_csv);

        % �����Լ�б�
        instrus = LoadChain(obj, pdt, var, exc);

        % ��������
        cal = LoadCalendar(obj);

        % ��������

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

end

