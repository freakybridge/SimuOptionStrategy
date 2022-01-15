% ����Դ����
% v1.3.0.20220113.beta
%      1.�����Ա����Լ��
%      2.�����������
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
        function obj = DataSource()
            % DataSource ��������ʵ��
            %   �˴���ʾ��ϸ˵��        
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
        [is_err, md] = FetchEtfMinData(obj, etf, ts_s, ts_e, inv);
        [is_err, md] = FetchEtfDayData(obj, ind, ts_s, ts_e, inv);
        [is_err, md] = FetchIndexMinData(obj, ind, ts_s, ts_e, inv);
        [is_err, md] = FetchIndexDayData(obj, ind, ts_s, ts_e, inv);
        [is_err, md] = FetchFutureMinData(obj, fut, ts_s, ts_e, inv);
        [is_err, md] = FetchFutureDayData(obj, fut, ts_s, ts_e, inv);
        [is_err, md] = FetchOptionMinData(obj, opt, ts_s, ts_e, inv);
        [is_err, md] = FetchOptionDayData(obj, opt, ts_s, ts_e, inv);
        
        % ��ȡ��Ȩ/�ڻ���Լ�б�
        [is_err, ins] = FetchOptionChain(obj, opt_s, ins_local);        
        [is_err, ins] = FetchFutureChain(obj, opt_s, ins_local);        
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

