% ���ݿ����
% v1.2.0.20220105.beta
%       �״����
classdef Database < handle    
    properties (Access = protected)
        user;
        password;
        driver; 
        url;
        conns;
        tables;
        db_default;
    end
        
    methods
        % �˿ڳ�ʼ��
        function obj = Database(user, pwd, db_dft)
            obj.user = user;
            obj.password = pwd;
            obj.db_default = db_dft;
            obj.conns = containers.Map();
            obj.tables = containers.Map();
        end
        
        % ��������
        function ret = SaveMarketData(obj, ast)
            switch ast.product
                case EnumType.Product.Option
                    switch ast.interval
                        case {EnumType.Interval.min1, EnumType.Interval.min5, EnumType.Interval.day}
                            ret = SaveBar(obj, ast);
                        otherwise
                            error("Unsupported ""interval"" for market data saving, please check.");
                    end                            
                            
                    
                otherwise
                    error("Unsupported ""product"" for market data saving, please check.");
            end
        end
        
        % ��ȡ����
        function LoadMarketData(obj, ast)
            switch ast.product
                case EnumType.Product.Option
                    switch ast.interval
                        case {EnumType.Interval.min1, EnumType.Interval.min5, EnumType.Interval.day}
                            obj.LoadBar(ast);
                        otherwise
                            error("Unsupported ""interval"" for market data loading, please check.");
                    end      
                    
                otherwise
                    error("Unsupported ""product"" for market data saving, please check.");
            end
        end
    end
    
    methods (Abstract)
        % ������Ȩ��
        ret = SaveOptionChain(obj, instru);
        
        % ��ȡ��Ȩ��
        instru = LoadOptionChain(obj, opt);
    end
    methods (Abstract, Hidden)
        % ����K������
        ret = SaveBar(obj, opt);
        
        % ��ȡK������
        LoadBar(obj, opt);      
    end
    
    methods (Static)
        % ������
        function obj = Selector(driver, user, pwd)
            switch EnumType.DatabaseSupported.ToEnum(driver)
                case EnumType.DatabaseSupported.Mss
                    obj = BaseClass.Database.MSS(user, pwd);
                    
                otherwise
                    error("Unsupported database driver, please check.");
            end            
        end
    end
end