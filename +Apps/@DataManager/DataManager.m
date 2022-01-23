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
    end    
    properties (Access = private)
        ds_pool struct;
        ds_pointer(1, 1) double;
    end

    % ��������
    methods
        % ���캯��
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

        % ��������
        LoadMd(obj, asset, dir_csv, dirt_tb);

        % �����Լ�б�
        instrus = LoadChain(obj, pdt, var, exc, dir_);

        % ��������

        % �������ݿ⣨�ϸ�ʽ��
        DatabaseBackupOldVer(obj, dir_rt)
        
        % ���ݿ⻹ԭ
        DatabaseRestore(obj, dir_rt, prefix);
    end
    
    methods (Access = private)
        % �������
        LoadMdViaDataSource(obj, asset);
        LoadMdViaTaobaoExcel(obj, asset, dirt_tb);               
        ret = IsMdComplete(obj, asset);       

        % ��Լ�б����
        instrus = LoadChainViaDs(obj, pdt, var, exc, instru_local);
        ret = IsInstruNeedUpdate(obj, instrus);

        % ��������
        cal = LoadCal(obj);
        cal = LoadCalViaDs(obj);
        cal = LoadCalViaDb(obj);
        cal = LoadCalViaExcel(obj, dir_);        
        ret = SaveCal2Db(obj);
        ret = SaveCal2Excel(obj, dir_);

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
    end
    
end

