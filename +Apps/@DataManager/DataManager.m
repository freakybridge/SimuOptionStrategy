% DataManager
% v1.3.0.20220113.beta
%      1.���Լ�������Լ��
% v1.2.0.20220105.beta
%      1.�޸Ĺ��캯����������������ݿ������� ������Դapi"
classdef DataManager < handle
    properties
        db	BaseClass.Database.Database = BaseClass.Database.Database.Selector('mss', 'sa', 'bridgeisbest');
        ds	BaseClass.DataSource.DataSource= BaseClass.DataSource.DataSource.Selector('wind', nan, nan);
    end    
    properties (Access = private)
        ds_pool struct;
        ds_pointer(1, 1) double;
    end

    % ��������
    methods
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
    end
    
    % �������
    methods
        LoadMd(obj, ast, dir_csv, dirt_tb);
        LoadMdViaCsv(obj,  ast, dir_csv);
        LoadMdViaDatabase(obj, ast);
        LoadMdViaDataSource(obj, ast);
        LoadMdViaTaobaoExcel(obj, ast, dirt_tb);        
        
        ret = SaveMd2Database(obj, ast);
        ret = SaveMd2Csv(obj, ast, dir_csv);                
        ret = IsMdComplete(obj, ast);       
    end
    
    % ��Լ�б����
    methods
        instrus = LoadOptChain(obj, var, exc, dir_);
        instrus = LoadOptChainViaDb(obj, var, exc);
        instrus = LoadOptChainViaDs(obj, var, exc, instru_local);
        instrus = LoadOptChainViaExcel(obj, var, exc, dir_);
        
        ret = SaveOptChain2Db(obj, var, exc, instrus);
        ret = SaveOptChain2Excel(obj, var, exc, instrus, dir_);
        ret = IsInstruNeedUpdate(obj, instrus);
    end
    
    % ��������
    methods
        cal = LoadCal(obj);
        cal = LoadCalViaDs(obj);
        cal = LoadCalViaDb(obj);
        cal = LoadCalViaExcel(obj, dir_);
        
        ret = SaveCal2Db(obj);
        ret = SaveCal2Excel(obj, dir_);
    end
    
    methods (Access = private)
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

