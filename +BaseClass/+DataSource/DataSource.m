% ����Դ����
% v1.2.0.20220105.beta
%       �״����
classdef DataSource
    %DATASOURCEAPI �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    properties
        err@struct;
    end
    properties (Abstract, Constant)
        name@char;
    end
    properties (Abstract)
        exchanges@containers.Map;
    end
        
    methods
        function obj = DataSource()
            %DATASOURCEAPI ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj.err = struct;
            obj.err.code = 0;
            obj.err.msg = 0;
            obj.err.is_fatal = 0;            
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
        % ��ȡ��Ȩ��������
        [is_err, md] = FetchOptionMinData(obj, opt, ts_s, ts_e, inv);
        
        % ��ȡ��Ȩ��Լ�б�
        [is_err, ins] = FetchOptionChain(obj, opt_s, ins_local);        

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

