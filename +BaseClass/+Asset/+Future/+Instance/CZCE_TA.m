% TA FUTURE类
% v1.3.0.20220113.beta
%       首次添加
classdef (Sealed) CZCE_TA < BaseClass.Asset.Future.Future
    
    % 父类Asset属性
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.CZCE;
        variety char = 'TA';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 2300]];
        tick_size double = 2;
        date_ini char = '2006/12/18';
    end
    
    % 构造函数
    methods
        function obj = CZCE_TA(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end