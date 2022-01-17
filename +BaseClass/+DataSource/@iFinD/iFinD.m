% ����Դ�˿� iFinDApi
% v1.3.0.20220113.beta
%       1.����Source����
%       2.FetchXXX��������ȡ״̬
%       3.Error��ʾͳһ��
%       4.�����Ա����Լ��
% v1.2.0.20220105.beta
%       �״����
classdef iFinD < BaseClass.DataSource.DataSource
    properties (Access = private)
        user char;
        password char;
        api;
    end
    properties (Constant)
        name char = 'iFinD';
    end
    properties (Hidden)
        exchanges containers.Map;
    end
    
    methods
        % ���캯��
        function obj = iFinD(ur, pwd)
            % iFinD ��������ʵ��
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
            obj.user = ur;
            obj.password = pwd;
            obj.err.code = THS_iFinDLogin(ur, pwd);
            if (obj.err.code == 0 || obj.err.code == -201)
                fprintf('DataSource %s@[User:%s] Ready.\r', obj.name, obj.user);
            end
        end
        
        % ��ȡ��Ȩ��������
        function [is_err, md] = FetchOptionMinData(obj, opt, ts_s, ts_e, inv)
            % ȷ���Ƿ����ݳ���
            if (datenum(opt.GetDateListed()) < now - obj.FetchApiDateLimit())
                md = [];
                is_err = false;
                return;
            end
            
            % ����
            exc = obj.exchanges(EnumType.Exchange.ToString(opt.exchange));
            [md, obj.err.code, dt, ~,~, errmsg, ~, ~] = THS_HF([opt.symbol, '.', exc],'open;high;low;close;amount;volume;openInterest',...
                sprintf('Fill:Previous,Interval:%i',  inv), ...
                datestr(ts_s, 'yyyy-mm-dd HH:MM:SS'), ...
                datestr(ts_e, 'yyyy-mm-dd HH:MM:SS'), ...
                'format:matrix');
            
            % ���
            if (obj.err.code)
                obj.err.msg = errmsg{:};
                obj.DispErr(sprintf('Fetching option %s market data', opt.symbol));
                md = [];
                is_err = true;
            else
                md = [datenum(dt), md];
                is_err = false;
            end
            
        end
        
    end
    
    methods (Static)
        % ��ȡapi����ʱ��
        function ret = FetchApiDateLimit()
            ret = 1 * 365;
        end
    end
    
    methods (Hidden)
        % �Ƿ�Ϊ��������
        function ret= IsErrFatal(obj)
            if (obj.err.code && obj.err.code ~= -201)
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

