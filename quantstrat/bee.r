# ok, here's the basics: use addPosLimit to set your max position, with a date = your initDate (before the first trade)
# [07:36am] braverock: and then, in your entry rules, add osFUN='osMaxPos' to your arguments=list(...)
# [07:36am] braverock: now, no matter how many 'entry' signals you get, you'll never exceed your max pos
# 
require(quantstrat)

suppressWarnings(rm("order_book.bug",pos=.strategy))
suppressWarnings(rm("account.bug","portfolio.bug",pos=.blotter))
suppressWarnings(rm("'bug'","'bug'","'GSPC'","bee","initDate","initEq",'start_t','end_t'))

currency('USD')
stock('GSPC',currency='USD',multiplier=1)

initDate='2000-12-31'
foo = as.Date(initDate)
initEq=1000000
sd = .5


initPortf('bug',symbols='GSPC', initDate=initDate)
initAcct('bug',portfolios='bug', initDate=initDate)
initOrders(portfolio='bug',initDate=initDate)

addPosLimit(
            portfolio='bug',
            symbol='GSPC', 
            timestamp = as.character(foo - 1),  
            maxpos=100)


bee <- strategy('bug')

bee <- add.indicator(
                              strategy = bee, 
                              name = "BBands", 
                              arguments = list(HLC=quote(HLC(mktdata)), 
                                               n=30, 
                                               sd=sd))

bee <- add.indicator(
                              strategy = bee, 
                              name = "SMA", 
                              arguments = list(x=quote(Cl(mktdata)), 
                                               n=10),
                              label= "ma10" )
bee <- add.signal(
                           strategy = bee,
                           name="sigCrossover",
                           arguments = list( columns=c('ma10',"dn"), 
                                            relationship="lt"),
                           label="ma10.lt.dn")
bee <- add.signal(
                           strategy = bee,
                           name="sigCrossover",
                           arguments = list( columns=c("ma10","dn"),
                                            relationship="gt"),
                           label="ma10.gt.up")

bee <- add.rule(
                         strategy = bee,
                         name='ruleSignal', 
                         arguments = list(sigcol="ma10.gt.up",
                                          sigval=TRUE, 
                                          orderqty=100, 
                                          ordertype='market', 
                                          orderside='long',
                                          osFUN='osMaxPos'),

                         type='enter')
bee <- add.rule(
                         strategy = bee,
                         name='ruleSignal', 
                         arguments = list(sigcol="ma10.lt.dn",
                                          sigval=TRUE, 
                                          orderqty='all', 
                                          ordertype='market', 
                                          orderside='long'),
                         type='exit')


bee <- add.rule(
                         strategy = bee,
                         name='ruleSignal', 
                         arguments = list(sigcol="ma10.lt.dn",
                                          sigval=TRUE, 
                                          orderqty=-100, 
                                          ordertype='market', 
                                          orderside='short',
                                          osFUN='osMaxPos'),
                         type='enter')
bee <- add.rule(
                         strategy = bee,
                         name='ruleSignal', 
                         arguments = list(sigcol="ma10.gt.up",
                                          sigval=TRUE, 
                                          orderqty='all', 
                                          ordertype='market', 
                                          orderside='short'),
                         type='exit')
 
getSymbols('^GSPC',from=initDate)
for(i in 'GSPC')
  assign(i, adjustOHLC(get(i),use.Adjusted=TRUE))

start_t<-Sys.time()
out<-try(applyStrategy(strategy=bee , portfolios='bug'))
end_t<-Sys.time()
print(end_t-start_t)

start_t<-Sys.time()
updatePortf(Portfolio='bug',Dates=paste('::',as.Date(Sys.time()),sep=''))
end_t<-Sys.time()
print("trade blotter portfolio update:")
print(end_t-start_t)

chart.Posn(Portfolio='bug',Symbol='GSPC')
