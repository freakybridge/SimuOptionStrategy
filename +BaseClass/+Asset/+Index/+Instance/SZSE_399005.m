% 中小100指数
% v1.3.0.20220113.beta
%       首次添加
classdef (Sealed) SZSE_399005< BaseClass.Asset.Index.Index
    
    % 父类Asset属性
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SZSE;
        variety char = '399005';
        tradetimetable double = [[930, 1130]; [1300, 1500]];
        tick_size double = 0.01;
        date_ini char = '2006/01/24';
    end
    
    methods
        function obj = SZSE_399005(varargin)
            obj = obj@BaseClass.Asset.Index.Index('399005', '中小100指数', varargin{:}, 1);
        end
    end
end

