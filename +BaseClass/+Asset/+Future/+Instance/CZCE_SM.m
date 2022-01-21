% SM FUTURE��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) CZCE_SM < BaseClass.Asset.Future.Future
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.CZCE;
        variety char = 'SM';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]];
        tick_size double = 2;
        date_ini char = '2014/08/08';
    end
    
    % ���캯��
    methods
        function obj = CZCE_SM(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end