% SC FUTURE类
% v1.3.0.20220113.beta
%       首次添加
classdef (Sealed) INE_SC < BaseClass.Asset.Future.Future
    
    % 父类Asset属性
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.INE;
        variety char = 'SC';
        tradetimetable double = [[0, 230]; [900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 2400]];
        tick_size double = 0.001;
        date_ini char = '2018/03/26';
    end
    
    % 构造函数
    methods
        function obj = INE_SC(symb, snm, inv, sz, epdt, mgn, fety, f)
            obj = obj@BaseClass.Asset.Future.Future(symb, snm, inv, sz, epdt, mgn, fety, f);
        end
    end    
end

