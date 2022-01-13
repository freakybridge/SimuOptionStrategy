% 数据源端口 WindApi
% v1.2.0.20220105.beta
%       首次添加
classdef Wind < BaseClass.DataSource.DataSource
    properties (Access = private)
        api;
    end
    properties (Constant)
        name = 'Wind';
    end
    properties (Hidden)        
        exchanges;
    end
    
    methods
        % 构造函数
        function obj = Wind()
            %WIND 构造此类的实例
            %   此处显示详细说明
            obj = obj@BaseClass.DataSource.DataSource();
            obj.exchanges = containers.Map;
            obj.exchanges(EnumType.Exchange.ToString(EnumType.Exchange.SSE)) = 'SH';
            obj.exchanges(EnumType.Exchange.ToString(EnumType.Exchange.SZSE)) = 'SZ';       
            
            % 登录
            obj.api = windmatlab;
            if (obj.api.isconnected())
                fprintf('DataSource %s Ready.\r', obj.name);
            end
        end
                       
        % 获取期权分钟数据
        function [is_err, md] = FetchOptionMinData(obj, opt, ts_s, ts_e, inv)
            % 确定是否数据超限
            if (datenum(opt.GetDateListed()) < now - obj.FetchApiDateLimit())
                md = [];
                return;
            end
            
            % 下载
            exc = obj.exchanges(EnumType.Exchange.ToString(opt.exchange));
            [md, ~, ~, dt, obj.err.code, ~] = obj.api.wsi([opt.symbol, '.', exc], 'open,high,low,close,amt,volume,oi', ...
                datestr(ts_s, 'yyyy-mm-dd HH:MM:SS'), datestr(ts_e, 'yyyy-mm-dd HH:MM:SS'), sprintf('BarSize=%i',  inv));

            % 输出
            if (obj.err.code)
                obj.err.msg = md{:};
                obj.DispErr(sprintf('Fetching option %s market data', opt.symbol));
                md = [];
                is_err = true;      
            else
                md = [dt, md];
                is_err = false;                
            end
        end
        
        % 获取期权合约列表
        function [is_err, ins] = FetchOptionChain(obj, opt_s, ins_local)
            % 获取下载起点终点
            [date_s, date_e] = obj.GetChainUpdateSE(opt_s, ins_local);
            
            % 下载           
            exc_ud = obj.exchanges(EnumType.Exchange.ToString(opt_s.ud_exchange));
            exc_opt = lower(EnumType.Exchange.ToString(opt_s.exchange));
            str = sprintf('startdate=%s;enddate=%s;exchange=%s;windcode=%s.%s;status=all;field=wind_code,sec_name,call_or_put,exercise_price,contract_unit,listed_date,expire_date', ...
                date_s, date_e, exc_opt, opt_s.variety, exc_ud);
            [ins, ~, ~, ~, obj.err.code, ~] = obj.api.wset('optioncontractbasicinfo', str);

            % 整理输出
            if (obj.err.code)
                obj.err.msg = ins{:};
                obj.DispErr('Fetching option chain failure');
                ins = ins_local;
                is_err = true;      
                
            else
                if isa(ins, 'cell')
                    % 存在新合约，合并本地合约
                    % 修正新信息
                    ins(strcmpi(ins(:, 3), '认购'), 3) = deal({'Call'});
                    ins(strcmpi(ins(:, 3), '认沽'), 3) = deal({'Put'});
                    ins(:, 6) = arrayfun(@(x) {datestr(x, 'yyyy-mm-dd HH:MM')}, Utility.DatetimeOffset(ins(:, 6), opt_s.tradetimetable(1)));
                    ins(:, 7) = arrayfun(@(x) {datestr(x, 'yyyy-mm-dd HH:MM')}, Utility.DatetimeOffset(ins(:, 7), opt_s.tradetimetable(end)));
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
                    % 无最新合约
                    ins = ins_local;
                end
                is_err = false;   
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

