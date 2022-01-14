% 上证50指数
% v1.3.0.20220113.beta
%       首次添加
classdef (Sealed) SSE_000016 < BaseClass.Asset.Index.Index
    
    % 父类Asset属性
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SSE;
        variety char = '000016';
        tradetimetable double = [[930, 1130]; [1300, 1500]];
        tick_size double = 0.01;
        date_ini char = '2004/01/12';
    end
    
    methods
        function obj = SSE_000016(inv)
            obj = obj@BaseClass.Asset.Index.Index('000016', '上证50指数', inv, 1);
        end
    end
end

