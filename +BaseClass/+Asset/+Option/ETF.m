% ETF��Ȩ����
% v1.3.0.20220113.beta
%       1.�����Ա����Լ��
%       2.���Ա�ع�
% v1.2.0.20220105.beta
%       �״����
classdef ETF < BaseClass.Asset.Option.Option
    % ����Option����
    properties
        underlying;
    end

    methods
        % ���캯��
        function obj = ETF(ud_var, ud_exc, varargin)
            [symb, snm, inv, sz, cop, k, ldt, edt] = BaseClass.Asset.Option.ETF.CheckArgument(varargin{:});
            underlying = BaseClass.Asset.Asset.Selector(EnumType.Product.ETF, ud_var, ud_exc, inv);
            obj = obj@BaseClass.Asset.Option.Option(symb, snm, inv, sz, cop, k, ldt, edt, underlying);
        end
    end    

    methods (Static)
        % �������
        function [symb, snm, inv, sz, cop, k, ldt, edt] = CheckArgument(varargin)
            if (nargin ~= 8)
                error('ETF option Intialization error, need input "symbol/sec_name/interval/unit/cop/strike/date listed/date expired", please check');
            end

            [symb, snm, inv, sz, cop, k, ldt, edt] = varargin{:};
            if (~isa(symb, 'char') && ~isa(symb, 'string'))
                error('Symbol arugument error, please check');
            end

            if (~isa(snm, 'char') && ~isa(snm, 'string'))
                error('Security name arugument error, please check');
            end

            if (~isa(inv, 'EnumType.Interval'))
                error('Interval arugument error, please check');
            end

            if (~isa(sz, 'double'))
                error('Unit arugument error, please check');
            end

            if (~isa(cop, 'EnumType.CallOrPut'))
                error('CallOrPut arugument error, please check');
            end

            if (~isa(k, 'double'))
                error('Strike arugument error, please check');
            end

            if(~isa(ldt, 'char') && ~isa(ldt, 'string'))
                error('Listed date arugument error, please check');
            end
            ldt = datenum(ldt);

            if (~isa(edt, 'char') && ~isa(edt, 'string'))
                error('Expire date arugument error, please check');
            end
            edt = datenum(edt);
        end
    end
end