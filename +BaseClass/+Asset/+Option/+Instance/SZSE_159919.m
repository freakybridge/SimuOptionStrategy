% 159919基类
% v1.3.0.20220113.beta
%       加入成员类型约束
% v1.2.0.20220105.beta
%       首次添加
classdef SZSE_159919 < BaseClass.Asset.Option.ETF
    properties (Constant)
        ud_symbol@char = "159919";
        ud_exchange@EnumType.Exchange = EnumType.Exchange.SSE;
        tradetimetable@double = [[930, 1130]; [1300, 1500]];
        tick_size@double = 0.0001;
        divlst@cell = [ ...
            {'2020/08/16'}, {0.0700}; ...
            {'2021/09/13'}, {0.1520}; ...
            ];
        strike_type@EnumType.OptionStrikeType = EnumType.OptionStrikeType.European;
        settle_mode@EnumType.OptionSettleMode = EnumType.OptionSettleMode.Physical;
        date_ini@char = '2019-12-23';
    end
    
    methods
        function obj = SZSE_159919(symb, exc, var, sz, inv, snm, cop, k, ldt, edt)
            obj = obj@BaseClass.Asset.Option.ETF(symb, exc, var, sz, inv, snm, cop, k, ldt, edt);
        end
    end
end
