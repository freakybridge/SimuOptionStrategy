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
        instrus = FetchOptionChain(obj, var, exc_ud, exc_opt, instru_local, date_s, date_e);
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
end

