% CF FUTURE类
% v1.3.0.20220113.beta
%       首次添加
classdef (Sealed) CZCE_CF < BaseClass.Asset.Future.Future
    
    % 父类Asset属性
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.CZCE;
        variety char = 'CF';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 2300]];
        tick_size double = 5;
        date_ini char = '2004/06/01';
    end
    
    % 构造函数
    methods
        function obj = CZCE_CF(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end