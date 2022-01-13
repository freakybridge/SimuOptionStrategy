% 510300基类
% v1.3.0.20220113.beta
%       加入成员类型约束
% v1.2.0.20220105.beta
%       首次添加
classdef SSE_510300 < BaseClass.Asset.Option.ETF
    properties (Constant)
        ud_symbol@char = "510300";
        ud_exchange@EnumType.Exchange = EnumType.Exchange.SSE;
        tradetimetable@double = [[930, 1130]; [1300, 1500]];
        tick_size@double = 0.0001;
        divlst@cell = [ ...
            {'2021/01/18'}, {0.072}; ...
            ];
        strike_type@EnumType.OptionStrikeType = EnumType.OptionStrikeType.European;
        settle_mode@EnumType.OptionSettleMode = EnumType.OptionSettleMode.Physical;
        date_ini@char = '2019-12-23';
    end
    
    methods
        function obj = SSE_510300(symb, exc, var, sz, inv, snm, cop, k, ldt, edt)
            obj = obj@BaseClass.Asset.Option.ETF(symb, exc, var, sz, inv, snm, cop, k, ldt, edt);
        end
    end
end
