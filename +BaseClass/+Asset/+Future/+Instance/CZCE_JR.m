% JR FUTURE类
% v1.3.0.20220113.beta
%       首次添加
classdef (Sealed) CZCE_JR < BaseClass.Asset.Future.Future
    
    % 父类Asset属性
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.CZCE;
        variety char = 'JR';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]];
        tick_size double = 1;
        date_ini char = '2013/11/18';
    end
    
    % 构造函数
    methods
        function obj = CZCE_JR(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end