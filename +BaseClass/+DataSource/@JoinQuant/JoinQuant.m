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
                err_msg = res.cell{2};
                data = [];
            end
        end
    end

end

