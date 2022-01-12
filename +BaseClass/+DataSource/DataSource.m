% ����Դ����
% v1.2.0.20220105.beta
%       �״����
classdef DataSource
    %DATASOURCEAPI �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    properties (Abstract)
        exchanges;
    end
        
    methods
        function obj = DataSource()
            %DATASOURCEAPI ��������ʵ��
            %   �˴���ʾ��ϸ˵��
        end
    end
    
    
    methods (Abstract)
        % ��ȡ��Ȩ��������
        md = FetchOptionMinData(obj, opt, ts_s, ts_e, inv);
        
        % ��ȡ��Ȩ��Լ�б�
        instrus = FetchOptionChain(obj, opt_s, instru_local);
    end
    
    methods (Abstract, Static)
        % ��ȡapi����ʱ��
        ret = FetchApiDateLimit();
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

