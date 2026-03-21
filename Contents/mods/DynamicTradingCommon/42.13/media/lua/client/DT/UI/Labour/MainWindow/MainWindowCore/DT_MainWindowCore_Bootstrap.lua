DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal

Internal.Config = DT_Labour.Config
Internal.MoneyProvider = DT_MainWindow.MoneyProvider or {}
DynamicTrading.TradingProvider.AttachCore(Internal.MoneyProvider)
DT_MainWindow.MoneyProvider = Internal.MoneyProvider

