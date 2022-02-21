% 数据源端口 JoinQuantApi
% v1.3.0.20220113.beta
%       1.首次添加
classdef JoinQuant < BaseClass.DataSource.DataSource
    properties (Access = private)
        user char;
        password char;
        py_directory char;
        dir_home char = cd;
        dir_sdk char = '.\resource\jqdata_matlab_sdk';
        url char = 'https://dataapi.joinquant.com/apis';
        token char;
        calendar double;
    end
    properties (Constant)
        name char = 'JoinQuant';
    end
    properties (Hidden)
        exchanges containers.Map;
    end

    methods
        % 构造函数
        function obj = JoinQuant(ur, pwd, py_dir_)
            % JoinQuant 构造此类的实例
            %   此处显示详细说明
            obj = obj@BaseClass.DataSource.DataSource();
            obj.user = ur;
            obj.password = pwd;
            obj.py_directory = py_dir_;

            % 交易所转换
            import EnumType.Exchange;
            obj.exchanges(Utility.ToString(Exchange.CFFEX)) = 'CCFX';
            obj.exchanges(Utility.ToString(Exchange.CZCE)) = 'XZCE';
            obj.exchanges(Utility.ToString(Exchange.DCE)) = 'XDCE';
            obj.exchanges(Utility.ToString(Exchange.INE)) = 'XINE';
            obj.exchanges(Utility.ToString(Exchange.SHFE)) = 'XSGE';
            obj.exchanges(Utility.ToString(Exchange.SSE)) = 'XSHG';
            obj.exchanges(Utility.ToString(Exchange.SZSE)) = 'XSHE';

            % check python environment
            try
                pyenv('Version', obj.py_directory);
            catch
            end
            fprintf('DataSource [%s] Ready.\r', obj.name);
            obj.ImportFunc();

        end

        % 登出
        function LogOut(~)
        end
    end

    methods (Static, Hidden)
        % 获取api流量时限
        function ret = FetchApiDateLimit()
            ret = inf * 365;
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
        [is_err, md] = FetchDailyMd(obj, symb, exc, ts_s, ts_e, fields, err_fmt);

        % 获取行情数据
        [is_err, md] = FetchMdEtf(obj, symb, exc, inv, ts_s, ts_e);
        [is_err, md] = FetchMdFuture(obj, symb, exc, inv, ts_s, ts_e);
        [is_err, md] = FetchMdIndex(obj, symb, exc, inv, ts_s, ts_e);
        [is_err, md] = FetchMdOption(obj, symb, exc, inv, ts_s, ts_e);

        % 获取期权/期货合约列表
        [is_err, ins] = FetchChainOption(obj, opt_s, ins_local);
        [is_err, ins] = FetchChainFuture(obj, fut_s, ins_local);
    end

    methods (Access = 'private')
        % import module
        function ImportFunc(obj)
            cd(obj.dir_sdk);
            import py.api.*;
            cd(obj.dir_home);
        end

        % analysis api result
        function [is_err, err_code, err_msg, data] = AnalysisApiResult(~, res)
            is_err = res.cell{1};
            if (~is_err)
                err_code = 0;
                err_msg = '';
                buffer = res.cell{3};
                data = cell(length(buffer{1}), size(buffer, 2));
                for i = 1 : size(buffer, 2)
                    switch class(buffer{i}{1})
                        case 'py.str'
                            val = cellfun(@char, cell(buffer{i}), 'UniformOutput', false);
                        case 'double'
                            val = cell(buffer{i});
                        case 'py.int'
                            val = num2cell(cellfun(@(x) x.double, cell(buffer{i})));
                        otherwise
                            error('Unexpected type, pelase check.')
                    end
                    data(:, i) = val;
                end
            else
                err_code = -1;
                err_msg = char(res.cell{2});
                data = [];
            end
        end
        
        % 计算下载行数
        function rows = CalcFetchingRows(obj, ts_s, ts_e, inv, exc)
            % 确定系数
            switch inv
                case EnumType.Interval.min1
                    multi = 60;
                    
                case EnumType.Interval.min5
                    multi = 12;
                    
                case EnumType.Interval.day
                    rows = 0;
                    return;
                    
                otherwise
                    error('Unexpected "interval" for fetching rows caculation, please check.');
            end
            
            % 判断交易日个数
            if (isempty(obj.calendar))
                [~, obj.calendar] = obj.FetchCalendar();
            end
            tdays = obj.calendar(obj.calendar(:, 1) >= str2double(datestr(ts_s, 'yyyymmdd')) & obj.calendar(:, 1) <= str2double(datestr(ts_e, 'yyyymmdd')), :);
            tdays = sum(tdays(:, 2));
            
            % 计算
            switch exc
                case {EnumType.Exchange.SSE, EnumType.Exchange.SZSE}
                    hours = 4;
                case {EnumType.Exchange.CZCE, EnumType.Exchange.DCE, EnumType.Exchange.INE, EnumType.Exchange.SHFE, EnumType.Exchange.DCE}
                    hours = 10;
                case EnumType.Exchange.CFFEX
                    hours = 5;
                otherwise
                    error('Unexpected "exchange" for fetching rows caculation, please check.');
            end
            rows = multi * hours * tdays;
        end
    end

end

