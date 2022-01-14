% 510300 ETF类
% v1.3.0.20220113.beta
%       首次添加
classdef (Sealed) SSE_510300 < BaseClass.Asset.ETF.ETF
    
    % 父类Asset属性
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SSE;
        variety char = '510300';
        tradetimetable double = [[930, 1130]; [1300, 1500]];
        tick_size double = 0.001;
        date_ini char = '2012/05/04';
    end
    
    % 父类ETF属性
    properties (Constant)
        divlst cell = [ ...
            {'2021/01/18'}, {0.072}; ...
            ];
    end
    
    % 构造函数
    methods
        function obj = SSE_510300(inv)
            obj = obj@BaseClass.Asset.ETF.ETF('510300', '华泰柏瑞沪深300ETF', inv, 100);
        end
    end
    
end

