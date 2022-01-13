% 数据源基类
% v1.2.0.20220105.beta
%       首次添加
classdef DataSource
    %DATASOURCEAPI 此处显示有关此类的摘要
    %   此处显示详细说明
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
            %DATASOURCEAPI 构造此类的实例
            %   此处显示详细说明
            obj.err = struct;
            obj.err.code = 0;
            obj.err.msg = 0;
            obj.err.is_fatal = 0;            
        end
        
        % 获取错误信息
        function [err_id, err_msg, is_fatal] = GetErrInfo(obj)
            err_id = obj.err.code;
            err_msg = obj.err.msg;
            is_fatal = obj.IsErrFatal();
        end
        
        
        % 输出错误信息
        function DispErr(obj, usr_ht)
            fprintf('%s ERROR: %s, [code: %d] [msg: %s], please check. \r', obj.name, usr_ht, obj.err.code, obj.err.msg);
        end
        
    end
    
    
    methods (Abstract)
        % 获取期权分钟数据
        [is_err, md] = FetchOptionMinData(obj, opt, ts_s, ts_e, inv);
        
        % 获取期权合约列表
        [is_err, ins] = FetchOptionChain(obj, opt_s, ins_local);        

    end
    
    methods (Abstract, Static)
        % 获取api流量时限
        ret = FetchApiDateLimit();
    end
    
    methods (Abstract, Hidden)
        % 判断错误是否致命
        ret = IsErrFatal(obj)        
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
    
    
    % 内部方法
    methods (Access = protected)
        % 获取合约表更新起点终点
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

