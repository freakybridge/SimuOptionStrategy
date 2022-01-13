% ���ݿ����
% v1.3.0.20220113.beta
%       �����Ա����Լ��
% v1.2.0.20220105.beta
%       �״����
classdef Database < handle    
    properties (Access = protected)
        user@char;
        password@char;
        driver@char; 
        url@char;
        conns@containers.Map;
        tables@containers.Map;
        db_default@char;
        db_instru@char;
    end
        
    methods
        % �˿ڳ�ʼ��
        function obj = Database(user, pwd, db_dft)
            obj.user = user;
            obj.password = pwd;
            obj.db_default = db_dft;
            obj.db_instru = "INSTRUMENTS";
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
        ret = SaveOptionChain(obj, var, exc, instrus);
        
        % ��ȡ��Ȩ��
        instru = LoadOptionChain(obj, var, exc);
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
        
        % ��ȡ���� / ��ȡ����
        function ret = GetDbName(ast)
            % Ԥ����
            inv = EnumType.Interval.ToString(ast.interval);
            product = EnumType.Product.ToString(ast.product);
            variety = ast.variety;
            exchange = EnumType.Exchange.ToString(ast.exchange);
            
            % ��������
            switch ast.product
                case EnumType.Product.Etf
                    ret = sprintf("%s-%s", inv, product);
                    
                case EnumType.Product.Future
                    ret = sprintf("%s-%s-%s-%s", inv, product, variety, exchange);
                    
                case EnumType.Product.Index
                    ret = sprintf("%s-%s", inv, product);
                    
                case EnumType.Product.Option
                    ret = sprintf("%s-%s-%s-%s", inv, product, variety, exchange);
                    
                otherwise
                    error("Unexpected product for name database, please check !");
            end
            ret = upper(ret);
        end
        function ret = GetTableName(varargin)
            % ��̬����
            if (nargin() == 1 && ismember('BaseClass.Asset.Asset', superclasses(varargin{1})))
                % �������
                % Ԥ����
                ast = varargin{1};
                symbol = ast.symbol;
                exchange = EnumType.Exchange.ToString(ast.exchange);
                
                % ��������
                switch ast.product
                    case EnumType.Product.Etf
                        ret = sprintf("%s_%s", symbol, exchange);
                        
                    case EnumType.Product.Future
                        ret = symbol;
                        
                    case EnumType.Product.Index
                        ret = sprintf("%s_%s", symbol, exchange);
                        
                    case EnumType.Product.Option
                        ret = symbol;
                        
                    otherwise
                        error("Unexpected product for name table, please check !");
                end
                ret = upper(ret);
                
            elseif (nargin() == 3 && isa(varargin{1}, 'EnumType.Product') && (isa(varargin{2}, 'string') || isa(varargin{2}, 'char')) && isa(varargin{3}, 'EnumType.Exchange'))
                % ��Լ����
                pdt = varargin{1};
                var = varargin{2};
                exc = varargin{3};
                ret = sprintf("%s-%s-%s", EnumType.Product.ToString(pdt), var, EnumType.Exchange.ToString(exc));
                
            else
                error("Unexpected input arguments, please check!");
            end
        end
        
    end
end