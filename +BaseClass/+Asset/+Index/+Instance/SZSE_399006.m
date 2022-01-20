% 创业板指数
% v1.3.0.20220113.beta
%       首次添加
classdef (Sealed) SZSE_399006< BaseClass.Asset.Index.Index
    
    % 父类Asset属性
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SZSE;
        variety char = '399006';
        tradetimetable double = [[930, 1130]; [1300, 1500]];
        tick_size double = 0.01;
        date_ini char = '2010/06/01';
    end
    
    methods
        function obj = SZSE_399006(varargin)
            obj = obj@BaseClass.Asset.Index.Index('399006', '创业板指数', varargin{:}, 1);
        end
    end
end
