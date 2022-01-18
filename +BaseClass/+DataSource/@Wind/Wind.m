% ����Դ�˿� WindApi
% v1.3.0.20220113.beta
%       1.����Source����
%       2.FetchXXX��������ȡ״̬
%       3.Error��ʾͳһ��
%       4.�����Ա����Լ��
% v1.2.0.20220105.beta
%       �״����
classdef Wind < BaseClass.DataSource.DataSource
    properties (Access = private)
        api windmatlab;
    end
    properties (Constant)
        name char = 'Wind';
    end
    properties (Hidden)
        exchanges containers.Map;
    end

    methods
        % ���캯��
        function obj = Wind()
            %WIND ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj = obj@BaseClass.DataSource.DataSource();

            % ������ת��
            import EnumType.Exchange;
            obj.exchanges(Exchange.ToString(Exchange.CFFEX)) = 'CFE';
            obj.exchanges(Exchange.ToString(Exchange.CZCE)) = 'CZC';
            obj.exchanges(Exchange.ToString(Exchange.DCE)) = 'DCE';
            obj.exchanges(Exchange.ToString(Exchange.INE)) = 'INE';
            obj.exchanges(Exchange.ToString(Exchange.SHFE)) = 'SHF';
            obj.exchanges(Exchange.ToString(Exchange.SSE)) = 'SH';
            obj.exchanges(Exchange.ToString(Exchange.SZSE)) = 'SZ';

            % ��¼
            obj.api = windmatlab;
            if (obj.api.isconnected())
                fprintf('DataSource [%s] Ready.\r', obj.name);
            end
        end
    end

    methods (Static)
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
    end

end

