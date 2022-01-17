% ����Դ����
% v1.3.0.20220113.beta
%      1.�����Ա����Լ��
%      2.�����������
%      3.�������ܽṹ
% v1.2.0.20220105.beta
%       �״����
classdef DataSource
    % DataSource �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    properties
        err struct = struct('code', 0, 'msg', '', 'is_fatal', false);
    end
    properties (Abstract, Constant)
        name char;
    end
    properties (Abstract)
        exchanges containers.Map;
    end
        
    methods
        % ���캯��
        function obj = DataSource()
            % DataSource ��������ʵ��
            %   �˴���ʾ��ϸ˵��        
        end
        
        % ��������
        function [is_err, md] = FetchMarketData(obj, pdt, symb, exc, inv, ts_s, ts_e)
            switch pdt
                case EnumType.Product.Etf
                    [is_err, md] = obj.FetchMdEtf(symb, exc, inv, ts_s, ts_e);
                    
                case EnumType.Product.Future
                    [is_err, md] = obj.FetchMdFuture(symb, exc, inv, ts_s, ts_e);
                    
                case EnumType.Product.Index
                    [is_err, md] = obj.FetchMdIndex(symb, exc, inv, ts_s, ts_e);
                    
                case EnumType.Product.Option
                    [is_err, md] = obj.FetchMdOption(symb, exc, inv, ts_s, ts_e);
                    
                otherwise
                    error('Unexpected "product" for fetching data, please check.');
            end
                    
        end
                
        % ��ȡ������Ϣ
        function [err_id, err_msg, is_fatal] = GetErrInfo(obj)
            err_id = obj.err.code;
            err_msg = obj.err.msg;
            is_fatal = obj.IsErrFatal();
        end
                
        % ���������Ϣ
        function DispErr(obj, usr_ht)
            fprintf('%s ERROR: %s, [code: %d] [msg: %s], please check. \r', obj.name, usr_ht, obj.err.code, obj.err.msg);
        end
        
    end
    
    
    methods (Abstract)
        % ��ȡ��������
        cal = FetchCalendar(obj);
        
        % ��ȡ��������
        [is_err, md] = FetchMdEtf(obj, symb, exc, inv, ts_s, ts_e);
        [is_err, md] = FetchMdFuture(obj, symb, exc, inv, ts_s, ts_e);
        [is_err, md] = FetchMdIndex(obj, symb, exc, inv, ts_s, ts_e);
        [is_err, md] = FetchMdOption(obj, symb, exc, inv, ts_s, ts_e);
        
        % ��ȡ��Ȩ/�ڻ���Լ�б�
        [is_err, ins] = FetchChainOption(obj, opt_s, ins_local);        
        [is_err, ins] = FetchChainFuture(obj, fut_s, ins_local);        
    end
    
    methods (Abstract, Static)
        % ��ȡapi����ʱ��
        ret = FetchApiDateLimit();
    end
    
    methods (Abstract, Hidden)
        % �жϴ����Ƿ�����
        ret = IsErrFatal(obj)        
    end
    
    methods (Static)
        % ������
        function obj = Selector(api, user, pwd)
            switch EnumType.DataSourceSupported.ToEnum(api)
                case EnumType.DataSourceSupported.iFinD
                    obj = BaseClass.DataSource.iFinD(user, pwd);
                case EnumType.DataSourceSupported.Wind
                    obj = BaseClass.DataSource.Wind();
                    
                otherwise
                    error("Unsupported datasource api, please check.");
            end
        end
    end
    
    
    % �ڲ�����
    methods (Access = protected)
        % ��ȡ��Լ���������յ�
        function [date_s, date_e] = GetChainUpdateSE(~, asset_s, instru_local)
            if (isempty(instru_local))
                date_s = asset_s.GetDateInit();
            else
                date_s = unique(instru_local.LAST_UPDATE_DATE);
                date_s = date_s{:};
            end
            date_s = datestr(date_s, 'yyyy-mm-dd');
            date_e = datestr(now(), 'yyyy-mm-dd');
        end
        
    end
end

