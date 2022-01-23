% FUTURE 期权基类
% v1.3.0.20220113.beta
%       1.首次添加
classdef Future < BaseClass.Asset.Option.Option
    % 父类Option属性
    properties
        underlying;
    end

    methods
        % 构造函数
        function obj = Future(ud_var, ud_exc, varargin)
            [symb, snm, inv, sz, cop, k, ldt, edt, fsymb, fsnm, fsz, fltdt, fepdt, fmgn, ffety, ff] = BaseClass.Asset.Option.Future.CheckArgument(varargin{:});
            underlying = BaseClass.Asset.Asset.Selector(EnumType.Product.Future, ud_var, ud_exc, fsymb, fsnm, inv, fsz, fltdt, fepdt, fmgn, ffety, ff);
            obj = obj@BaseClass.Asset.Option.Option(symb, snm, inv, sz, cop, k, ldt, edt, underlying);
        end
    end    

    methods (Static)
        % 参数检查
        function [symb, snm, inv, sz, cop, k, ldt, edt, fsymb, fsnm, fsz, fltdt, fepdt, fmgn, ffety, ffee] = CheckArgument(varargin)
            if (nargin ~= 16)
                error('Future option Intialization error, need input "symbol/sec_name/interval/unit/cop/strike/date listed/date expired/future symbol/future sec_name/future size/future listed date/future expire date/future margin ratio/future fee type/future fee, please check');
            end

            [symb, snm, inv, sz, cop, k, ldt, edt, fsymb, fsnm, fsz, fltdt, fepdt, fmgn, ffety, ffee] = varargin{:};
            if (~isa(symb, 'char') && ~isa(symb, 'string'))
                error('"Symbol" arugument error, please check');
            end

            if (~isa(snm, 'char') && ~isa(snm, 'string'))
                error('"Security name" arugument error, please check');
            end

            if (~isa(inv, 'EnumType.Interval'))
                error('"Interval" arugument error, please check');
            end

            if (~isa(sz, 'double'))
                error('"Size" arugument error, please check');
            end

            if (~isa(cop, 'EnumType.CallOrPut'))
                error('"CallOrPut" arugument error, please check');
            end

            if (~isa(k, 'double'))
                error('"Strike" arugument error, please check');
            end

            if(~isa(ldt, 'char') && ~isa(ldt, 'string'))
                error('"Listed date" arugument error, please check');
            end
            ldt = datenum(ldt);

            if (~isa(edt, 'char') && ~isa(edt, 'string'))
                error('"Expire date" arugument error, please check');
            end
            edt = datenum(edt);

        end
    end
end