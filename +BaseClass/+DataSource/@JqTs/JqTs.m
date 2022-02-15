% 数据源端口 JoinQuant+TushareApi
% v1.3.0.20220113.beta
%       首次添加
classdef JoinQuantTushare < BaseClass.DataSource.DataSource
    properties (Access = private)
        token char;
        api;
    end
    properties (Constant)
        name char = 'Tushare';
    end
    properties (Hidden)
        exchanges containers.Map;
    end
    
    methods
        % 构造函数
        function obj = Tushare(tkn)
            % Tushare 构造此类的实例
            %   此处显示详细说明
            obj = obj@BaseClass.DataSource.DataSource();
            
            % 交易所转换
            import EnumType.Exchange;
            obj.exchanges(Utility.ToString(Exchange.CFFEX)) = '.CFX';
            obj.exchanges(Utility.ToString(Exchange.CZCE)) = '.ZCE';
            obj.exchanges(Utility.ToString(Exchange.DCE)) = '.DCE';
            obj.exchanges(Utility.ToString(Exchange.INE)) = '.INE';
            obj.exchanges(Utility.ToString(Exchange.SHFE)) = '.SHF';
            obj.exchanges(Utility.ToString(Exchange.SSE)) = '.SH';
            obj.exchanges(Utility.ToString(Exchange.SZSE)) = '.SZ';
            
            % 登录
            addpath('.\resource\tushare_matlab_sdk');
            obj.token = tkn;
            obj.api = pro_api(tkn);
            fprintf('DataSource [%s] Ready.\r', obj.name);
        end

        % 登出
        function LogOut(~)
        end
    end
    
    methods (Static, Hidden)
        % 获取api流量时限
        function ret = FetchApiDateLimit()
            ret = 3 * 365;
        end
    end
    
    methods (Hidden)
        % 是否为致命错误
        function ret= IsErrFatal(obj)
            if (obj.err.code)
                ret = true;
            else
                ret = false;
            end
        end
        
        % 获取分钟 / 日级数据
        [is_err, md] = FetchMinMd(obj, symb, exc, inv, ts_s, ts_e, err_fmt);
        [is_err, md] = FetchDailyMd(obj, symb, exc, ts_s, ts_e, func, fields, err_fmt);
        
        % 获取行情数据
        [is_err, md] = FetchMdEtf(obj, symb, exc, inv, ts_s, ts_e);
        [is_err, md] = FetchMdFuture(obj, symb, exc, inv, ts_s, ts_e);
        [is_err, md] = FetchMdIndex(obj, symb, exc, inv, ts_s, ts_e);
        [is_err, md] = FetchMdOption(obj, symb, exc, inv, ts_s, ts_e);
        
        % 获取期权/期货合约列表
        [is_err, ins] = FetchChainOption(obj, opt_s, ins_local);
        [is_err, ins] = FetchChainFuture(obj, fut_s, ins_local);
    end
end

