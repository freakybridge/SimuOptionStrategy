% 510050基类
% v1.2.0.20220105.beta
%       首次添加
classdef SSE_510050 < BaseClass.Asset.Option.ETF
    properties (Constant)
        ud_symbol = "510050";
        ud_exchange = EnumType.Exchange.SSE;
        tradetimetable = [[930, 1130]; [1300, 1500]];
        tick_size = 0.0001;
        divlst = [ ...
            {'2016/11/29'}, {0.053}; ...
            {'2017/11/28'}, {0.054}; ...
            {'2018/12/03'}, {0.049}; ...
            {'2019/12/02'}, {0.047}; ...
            {'2020/11/30'}, {0.051}; ...
            {'2021/11/29'}, {0.041}; ...
            ];
        strike_type = EnumType.OptionStrikeType.European;
        settle_mode = EnumType.OptionSettleMode.Physical;
    end    
    
    methods
        function obj = SSE_510050(symb, exc, var, sz, inv, snm, cop, k, edt, ldt)
            obj = obj@BaseClass.Asset.Option.ETF(symb, exc, var, sz, inv, snm, cop, k, edt, ldt);
        end        
    end
end

