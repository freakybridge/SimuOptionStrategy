% 数据源端口 WindApi
% v1.3.0.20220113.beta
%       1.加入Source名称
%       2.FetchXXX输出加入获取状态
%       3.Error显示统一化
%       4.加入成员类型约束
% v1.2.0.20220105.beta
%       首次添加
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
        % 构造函数
        function obj = Wind()
            %WIND 构造此类的实例
            %   此处显示详细说明
            obj = obj@BaseClass.DataSource.DataSource();
            obj.exchanges(EnumType.Exchange.ToString(EnumType.Exchange.SSE)) = 'SH';
            obj.exchanges(EnumType.Exchange.ToString(EnumType.Exchange.SZSE)) = 'SZ';       
            
            % 登录
            obj.api = windmatlab;
            if (obj.api.isconnected())
                fprintf('DataSource %s Ready.\r', obj.name);
            end
        end                
    end
    
    methods (Static)
        % 获取api流量时限
        function ret = FetchApiDateLimit()
            ret = 3 * 365;
        end
    end
    
    
    methods (Hidden)
        function ret= IsErrFatal(obj)
            if (obj.err.code)
                ret = true;
            else
                ret = false;
            end
        end
    end
    
end

