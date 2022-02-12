% ����Դ�˿� JoinQuantApi
% v1.3.0.20220113.beta
%       1.����Source����
%       2.FetchXXX��������ȡ״̬
%       3.Error��ʾͳһ��
%       4.�����Ա����Լ��
% v1.2.0.20220105.beta
%       �״����
classdef JoinQuant < BaseClass.DataSource.DataSource
    properties (Access = private)
        api windmatlab;
    end
    properties (Constant)
        name char = 'JoinQuant';
    end
    properties (Hidden)
        exchanges containers.Map;
    end

    methods
        % ���캯��
        function obj = JoinQuant()
            %WIND ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj = obj@BaseClass.DataSource.DataSource();

            % ������ת��
            import EnumType.Exchange;
            obj.exchanges(Utility.ToString(Exchange.CFFEX)) = 'CFE';
            obj.exchanges(Utility.ToString(Exchange.CZCE)) = 'CZC';
            obj.exchanges(Utility.ToString(Exchange.DCE)) = 'DCE';
            obj.exchanges(Utility.ToString(Exchange.INE)) = 'INE';
            obj.exchanges(Utility.ToString(Exchange.SHFE)) = 'SHF';
            obj.exchanges(Utility.ToString(Exchange.SSE)) = 'SH';
            obj.exchanges(Utility.ToString(Exchange.SZSE)) = 'SZ';

            % ��¼
            obj.api = windmatlab;
            if (obj.api.isconnected())
                fprintf('DataSource [%s] Ready.\r', obj.name);
            end
        end
    
        % �ǳ�
        function LogOut(~)
        end
    end

    methods (Static, Hidden)
        % ��ȡapi����ʱ��
        function ret = FetchApiDateLimit()
            ret = 3 * 365;
        end
    end

    methods (Hidden)
        % �Ƿ�Ϊ��������
        function ret= IsErrFatal(obj)
            if (obj.err.code)
                ret = true;
            else
                ret = false;
            end
        end

        % ��ȡ���� / �ռ�����
        [is_err, md] = FetchMinMd(obj, symb, exc, inv, ts_s, ts_e, err_fmt);
        [is_err, md] = FetchDailyMd(obj, symb, exc, ts_s, ts_e, fields, err_fmt);
        
        % ��ȡ��������
        [is_err, md] = FetchMdEtf(obj, symb, exc, inv, ts_s, ts_e);
        [is_err, md] = FetchMdFuture(obj, symb, exc, inv, ts_s, ts_e);
        [is_err, md] = FetchMdIndex(obj, symb, exc, inv, ts_s, ts_e);
        [is_err, md] = FetchMdOption(obj, symb, exc, inv, ts_s, ts_e);
        
        % ��ȡ��Ȩ/�ڻ���Լ�б�
        [is_err, ins] = FetchChainOption(obj, opt_s, ins_local);
        [is_err, ins] = FetchChainFuture(obj, fut_s, ins_local);
    end

end

