% ZC FUTURE��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) CZCE_ZC < BaseClass.Asset.Future.Future
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.CZCE;
        variety char = 'ZC';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 2300]];
        tick_size double = 0.2;
        date_ini char = '2013/09/26';
    end
    
    % ���캯��
    methods
        function obj = CZCE_ZC(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end