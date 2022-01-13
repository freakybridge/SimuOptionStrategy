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
        user@char;
        password@char;
        api;
    end
    properties (Constant)
        name@char = 'iFinD';
    end
    properties (Hidden)
        exchanges@containers.Map;
    end
    
    methods
        % 构造函数
        function obj = iFinD(ur, pwd)
            % iFinD 构造此类的实例
            %   此处显示详细说明
            obj = obj@BaseClass.DataSource.DataSource();
            obj.exchanges = containers.Map;
            obj.exchanges(EnumType.Exchange.ToString(EnumType.Exchange.SSE)) = 'SH';
            obj.exchanges(EnumType.Exchange.ToString(EnumType.Exchange.SZSE)) = 'SZ';
            
            % 登录
            obj.user = ur;
            obj.password = pwd;
            obj.err.code = THS_iFinDLogin(ur, pwd);
            if (obj.err.code == 0 || obj.err.code == -201)
                fprintf('DataSource %s@[User:%s] Ready.\r', obj.name, obj.user);
            end            
        end
        
        % 获取期权分钟数据
        function [is_err, md] = FetchOptionMinData(obj, opt, ts_s, ts_e, inv)
            % 确定是否数据超限
            if (datenum(opt.GetDateListed()) < now - obj.FetchApiDateLimit())
                md = [];
                is_err = false;       
                return;
            end
            
            % 下载
            exc = obj.exchanges(EnumType.Exchange.ToString(opt.exchange));
            [md, obj.err.code, dt, ~,~, errmsg, ~, ~] = THS_HF([opt.symbol, '.', exc],'open;high;low;close;amount;volume;openInterest',...
                sprintf('Fill:Previous,Interval:%i',  inv), ...
                datestr(ts_s, 'yyyy-mm-dd HH:MM:SS'), ...
                datestr(ts_e, 'yyyy-mm-dd HH:MM:SS'), ...
                'format:matrix');
            
            % 输出
            if (obj.err.code)
                obj.err.msg = errmsg{:};
                obj.DispErr(sprintf('Fetching option %s market data', opt.symbol));
                md = [];
                is_err = true;      
            else
                md = [datenum(dt), md];
                is_err = false;       
            end
            
        end
        
        % 获取期权合约列表
        function [is_err, ins] = FetchOptionChain(obj, opt_s, ins_local)
            % 获取下载起点终点
            [date_s, date_e] = obj.GetChainUpdateSE(opt_s, ins_local);
            
            % 获取参数
            if (isa(opt_s, 'BaseClass.Asset.Option.Instance.SSE_510050'))
                param = '171002001';
            elseif (isa(opt_s, 'BaseClass.Asset.Option.Instance.SSE_510300'))
                param = '171002002';
            elseif (isa(opt_s, 'BaseClass.Asset.Option.Instance.SZSE_159919'))
                param = '171003006';
            else
                error("Unexpected option class type, please check!");
            end
            
            % 下载合约代码
            symbols = [];
            for i = datenum(date_s) : 15 : datenum(date_e)
                str = sprintf('%s;%s', datestr(i, 'yyyy-mm-dd'), param);
                [data, obj.err.code, errmsg, ~, ~, ~]=THS_DP('block', str,'thscode:Y','format:array');
                if (obj.err.code)
                    obj.err.msg = errmsg{:};
                    obj.DispErr('Fetching option chain error when loading symbols');
                    ins = ins_local;
                    is_err = true;
                    return;                    
                end
                symbols = union(symbols, data);
            end
            symbols = cellfun(@(x) {[x, ',']}, symbols');
            symbols = [symbols{:}];
            symbols(end) = [];
            
            % 提取数据
            [data, obj.err.code, ~,thscode, errmsg, ~, ~, ~] = THS_BD(symbols,'ths_option_short_name_option;ths_contract_type_option;ths_strike_price_option;ths_contract_multiplier_option;ths_listed_date_option;ths_maturity_date_option', ...
                sprintf(';;%s;;;', datestr(now(), 'yyyy-mm-dd')),'format:array');
            
            % 输出
            if (obj.err.code)
                obj.err.msg = errmsg{:};
                obj.DispErr('Fetching option chain failure');
                ins = ins_local;
                is_err = true; 
                
            else
                % 整理数据
                ins = [thscode, data];
                if (~isempty(ins))
                    % 修正新信息
                    for i = 1 : size(ins, 1)
                        tmp = ins{i, 1};
                        loc = strfind(tmp, '.');
                        ins{i, 1} = tmp(1 : loc - 1);
                    end
                    ins(strcmpi(ins(:, 3), '看涨期权'), 3) = deal({'Call'});
                    ins(strcmpi(ins(:, 3), '看跌期权'), 3) = deal({'Put'});
                    ins(:, 6) = cellfun(@(x) {datestr(Utility.DatetimeOffset(datenum(num2str(x), 'yyyymmdd'), opt_s.tradetimetable(1)), 'yyyy-mm-dd HH:MM')}, ins(:, 6));
                    ins(:, 7) = cellfun(@(x) {datestr(Utility.DatetimeOffset(datenum(num2str(x), 'yyyymmdd'), opt_s.tradetimetable(end)), 'yyyy-mm-dd HH:MM')}, ins(:, 7));
                    ins(:, 8) = num2cell(cellfun(@(x) str2double(datestr(x, 'yyyymm')), ins(:, 7)));
                    
                    % 补全信息
                    exc = upper(char(EnumType.Exchange.ToString(opt_s.exchange)));
                    var = char(opt_s.variety);
                    ud_symb = char(opt_s.ud_symbol);
                    ud_product = upper(char(EnumType.Product.ToString(opt_s.ud_product)));
                    ud_exc = upper(char(EnumType.Exchange.ToString(opt_s.ud_exchange)));
                    striketype = Utility.InitCapital(EnumType.OptionStrikeType.ToString(opt_s.strike_type));
                    ticksz = opt_s.tick_size;
                    sttmode = Utility.InitCapital(EnumType.OptionSettleMode.ToString(opt_s.settle_mode));
                    upd_time = datestr(now(), 'yyyy-mm-dd HH:MM');
                    info = {exc, var, ud_symb, ud_product, ud_exc,  striketype, ticksz, sttmode, upd_time};
                    info = repmat(info, size(ins, 1), 1);
                    
                    ins = [ins(:, 1 : 2), info(:, 1 : 5), ins(:, 3), info(:, 6), ins(:, 4 : 5), info(:, 7), ins(:, [8, 6, 7]), info(:, 8 : 9)];
                    ins = cell2table(ins, 'VariableNames', {'SYMBOL','SEC_NAME','EXCHANGE','VARIETY','UD_SYMBOL','UD_PRODUCT','UD_EXCHANGE','CALL_OR_PUT','STRIKE_TYPE','STRIKE','SIZE','TICK_SIZE','DLMONTH','START_TRADE_DATE','END_TRADE_DATE','SETTLE_MODE','LAST_UPDATE_DATE'});
                
                    % 合并
                    if (~isempty(ins_local))
                        [~, loc] = intersect(ins_local(:, 1), ins(:, 1));
                        ins_local(loc, :) = [];
                        ins = [ins_local; ins];
                    end
                    ins = sortrows(ins, 1);
                    
                else
                    ins = ins_local;
                end
                is_err = false;   

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
        function ret= IsErrFatal(obj)
            if (obj.err.code && obj.err.code ~= -201)
                ret = true;
            else
                ret = false;
            end
        end
    end
end

