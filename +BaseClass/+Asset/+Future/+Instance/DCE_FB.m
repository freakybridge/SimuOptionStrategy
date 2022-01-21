% FB FUTURE��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) DCE_FB < BaseClass.Asset.Future.Future
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.DCE;
        variety char = 'FB';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]];
        tick_size double = 0.05;
        date_ini char = '2014/12/09';
    end
    
    % ���캯��
    methods
        function obj = DCE_FB(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end