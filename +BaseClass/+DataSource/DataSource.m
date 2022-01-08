% 数据源基类
% v1.2.0.20220105.beta
%       首次添加
classdef DataSource
    %DATASOURCEAPI 此处显示有关此类的摘要
    %   此处显示详细说明
    properties (Abstract)
        exchanges;
    end
        
    methods
        function obj = DataSource()
            %DATASOURCEAPI 构造此类的实例
            %   此处显示详细说明
        end
    end
    
    
    methods (Abstract)
        % 获取期权分钟数据
        md = FetchOptionMinData(obj, symb, exc, ts_s, ts_e, inv);
    end
    
    methods (Abstract, Static)
        % 获取api流量时限
        ret = FetchApiDateLimit();
    end
    
    methods (Static)
        % 反射器
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

