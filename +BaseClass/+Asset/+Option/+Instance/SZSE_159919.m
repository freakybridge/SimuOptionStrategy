% 159919基类
% v1.2.0.20220105.beta
%       首次添加
classdef SZSE_159919 < BaseClass.Asset.Option.ETF
    properties (Constant)
        ud_symbol = "159919";
        ud_exchange = EnumType.Exchange.SSE;
        tradetimetable = [[930, 1130]; [1300, 1500]];
        tick_size = 0.0001;
        divlst = [ ...
            {'2020/08/16'}, {0.0700}; ...
            {'2021/09/13'}, {0.1520}; ...
            ];
        strike_type = EnumType.OptionStrikeType.European;
        settle_mode = EnumType.OptionSettleMode.Physical;
    end    
    
    methods
        function obj = SZSE_159919(symb, exc, var, sz, inv, snm, cop, k, ldt, edt)
            obj = obj@BaseClass.Asset.Option.ETF(symb, exc, var, sz, inv, snm, cop, k, ldt, edt);
        end
    end
end
