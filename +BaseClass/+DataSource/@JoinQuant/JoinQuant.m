% ����Դ�˿� JoinQuantApi
% v1.3.0.20220113.beta
%       1.�״����
classdef JoinQuant < BaseClass.DataSource.DataSource
    properties (Access = private)
        url char = 'https://dataapi.joinquant.com/apis';
        token char;
    end
    properties (Constant)
        name char = 'JoinQuant';
    end
    properties (Hidden)
        exchanges containers.Map;
    end

    methods
        % ���캯��
        function obj = JoinQuant(ur, pwd)
            % JoinQuant ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj = obj@BaseClass.DataSource.DataSource();

            % ������ת��
            import EnumType.Exchange;
            obj.exchanges(Utility.ToString(Exchange.CFFEX)) = 'CCFX';
            obj.exchanges(Utility.ToString(Exchange.CZCE)) = 'XZCE';
            obj.exchanges(Utility.ToString(Exchange.DCE)) = 'XDCE';
            obj.exchanges(Utility.ToString(Exchange.INE)) = 'XINE';
            obj.exchanges(Utility.ToString(Exchange.SHFE)) = 'XSGE';
            obj.exchanges(Utility.ToString(Exchange.SSE)) = 'XSHG';
            obj.exchanges(Utility.ToString(Exchange.SZSE)) = 'XSHE';

            % ��¼
            options = weboptions('RequestMethod', 'post', 'MediaType', 'application/json');
            body = struct('method', 'get_token', 'mob', ur, 'pwd', pwd);
            obj.token = webwrite(obj.url, body, options);
            if (~contains(obj.token, 'error'))
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

