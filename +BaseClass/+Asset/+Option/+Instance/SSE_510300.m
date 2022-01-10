% 510300基类
% v1.2.0.20220105.beta
%       首次添加
classdef SSE_510300 < BaseClass.Asset.Option.ETF
    properties (Constant)
        ud_symbol = "510300";
        ud_exchange = EnumType.Exchange.SSE;
        tradetimetable = [[930, 1130]; [1300, 1500]];
        tick_size = 0.0001;
        divlst = [ ...
            {'2021/01/18'}, {0.072}; ...
            ];
        strike_type = EnumType.OptionStrikeType.European;
        settle_mode = EnumType.OptionSettleMode.Physical;
    end    
    
    methods
        function obj = SSE_510300(symb, exc, var, sz, inv, snm, cop, k, edt, ldt)
            obj = obj@BaseClass.Asset.Option.ETF(symb, exc, var, sz, inv, snm, cop, k, edt, ldt);
        end        
    end
end
