require(quantstrat)
getSymbols('SPY', from='2000-01-01')
currency('USD')
stock('SPY', currency='USD')
initPortf('bug', 'SPY')
initAcct('bug', portfolios='bug', initEq=1000000, initDate='1999-12-31')
initOrders(portfolio='bug', initDate='1999-12-31')
ant = strategy('bug')
ant = add.indicator(
                    strategy  =  ant,
                    name      = 'SMA', 
                    arguments = list(
                                     x = quote(Cl(mktdata)), 
                                     n = 9 ), 
                    label     ='sma')
ant = add.signal(
                    strategy  = ant, 
                    name      = 'sigCrossover', 
                    arguments = list(
                                     column       = c('Close', 'sma'), 
                                     relationship = 'gt'), 
                    label     ='cl.gt.sma')
ant = add.signal(
                    strategy  = ant, 
                    name      = 'sigCrossover',
                    arguments = list(
                                     column       = c('Close', 'sma'),
                                     relationship = 'lt'),
                    label='cl.lt.sma')
ant = add.rule(
                    strategy  = ant, 
                    name      = 'ruleSignal', 
                    arguments = list(
                                     sigcol       = 'cl.gt.sma', 
                                     sigval       = TRUE,
                                     orderqty     = 100,
                                     orderside    = 'long', 
                                     ordertype    = 'market' ), 
                    type      = 'enter')
ant = add.rule(
                    strategy  = ant, 
                    name      = 'ruleSignal',
                    arguments = list( 
                                      sigcol      = 'cl.lt.sma', 
                                      sigval      = TRUE, 
                                      orderqty    = 'all', 
                                      orderside   = 'long' ,
                                      ordertype   = 'market' ),
                    type      = 'exit')
out = applyStrategy(ant, portfolios='bug')
