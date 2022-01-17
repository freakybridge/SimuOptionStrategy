% 数据源端口 iFinDApi
% v1.3.0.20220113.beta
%       1.加入Source名称
%       2.FetchXXX输出加入获取状态
%       3.Error显示统一化
%       4.加入成员类型约束
% v1.2.0.20220105.beta
%       首次添加
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
        % 构造函数
        function obj = iFinD(ur, pwd)
            % iFinD 构造此类的实例
            %   此处显示详细说明
            obj = obj@BaseClass.DataSource.DataSource();
            
            % 交易所转换
            import EnumType.Exchange;
            obj.exchanges(Exchange.ToString(Exchange.CFFEX)) = 'CFE';
            obj.exchanges(Exchange.ToString(Exchange.CZCE)) = 'CZC';
            obj.exchanges(Exchange.ToString(Exchange.DCE)) = 'DCE';
            obj.exchanges(Exchange.ToString(Exchange.INE)) = 'SHF';
            obj.exchanges(Exchange.ToString(Exchange.SHFE)) = 'SHF';
            obj.exchanges(Exchange.ToString(Exchange.SSE)) = 'SH';
            obj.exchanges(Exchange.ToString(Exchange.SZSE)) = 'SZ';
            
            % 登录
            obj.user = ur;
            obj.password = pwd;
            obj.err.code = THS_iFinDLogin(ur, pwd);
            if (obj.err.code == 0 || obj.err.code == -201)
                fprintf('DataSource %s@[User:%s] Ready.\r', obj.name, obj.user);
            end
        end
                
    end
    
    methods (Static)
        % 获取api流量时限
        function ret = FetchApiDateLimit()
            ret = 1 * 365;
        end
    end
    
    methods (Hidden)
        % 是否为致命错误
        function ret= IsErrFatal(obj)
            if (obj.err.code && obj.err.code ~= -201)
                ret = true;
            else
                ret = false;
            end
        end
        
        % 获取分钟 / 日级数据
        [is_err, md] = FetchMinMd(obj, symb, exc, inv, ts_s, ts_e, err_fmt);
        [is_err, md] = FetchDailyMd(obj, symb, exc, ts_s, ts_e, fields, params, err_fmt);
    end
end

