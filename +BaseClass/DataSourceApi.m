classdef DataSourceApi
    %DATASOURCEAPI �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    properties (Abstract)
        exchanges;
    end
        
    methods
        function obj = DataSourceApi()
            %DATASOURCEAPI ��������ʵ��
            %   �˴���ʾ��ϸ˵��
        end
    end
    
    
    methods (Abstract)
        % ��ȡ��Ȩ��������
        md = FetchOptionMinData(obj, symb, exc, ts_s, ts_e, inv);
    end
    
    methods (Abstract, Static)
        % ��ȡapi����ʱ��
        ret = FetchApiDateLimit();
    end
end

