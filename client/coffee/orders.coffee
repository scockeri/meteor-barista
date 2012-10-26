# events
# note: e is event and t is template
# find is Template find
Template.orders_index.events
  'click .edit': -> Router.orders_edit_path(@)
  'click .delete': -> Orders.remove({_id: @._id})
  'click #new': -> Router.navigate('orders/new', {trigger: true})
        
Template.orders_new.events
  'click #create': (e, t) -> 
    barista = t.find('#barista option:selected').value
    Meteor.call 'orders_insert', barista, (err, data) ->
      Router.navigate("orders/#{data}/edit", {trigger: true})
  'click #back': -> window.Back('orders')

Template.orders_edit.events
  'change #barista': (e, t) -> 
    barista = t.find('#barista option:selected').value
    Orders.update({_id: Session.get('id')}, {$set: {barista: barista}})
  'change #status': ->
    status = $('#status option:selected').val()
    Orders.update({_id: Session.get('id')}, {$set: {status: status}})
  'click #add': -> Meteor.call 'products_insert', Session.get('id')
  'click #back': -> window.Back('orders')

# formatters
Template.order.subtotal = -> accounting.formatMoney(@.subtotal)
Template.order.total = -> accounting.formatMoney(@.total)

# lists
Template.orders_index.orders = -> Orders.find()

# selects
Template.orders_new.baristas = -> Baristas.find()
Template.orders_main.baristas = -> Baristas.find()
Template.orders_main.statuses = -> Statuses.find()
Template.orders_edit.products = -> Products.find({order_id: Session.get('id')})

# dynamic values
# use Mini-Mongo rather than Server Methods - as have to return values in scope
Template.orders_edit.totaled = ->
  order = Orders.findOne({_id: Session.get('id')})
  total = order && order.total
  if total > 0 then return true else return false
Template.orders_total.subtotal = -> 
  order = Orders.findOne({_id: Session.get('id')})
  subtotal = order && order.subtotal
  accounting.formatMoney(subtotal)
Template.orders_total.hst = -> 
  order = Orders.findOne({_id: Session.get('id')})
  hst = order && order.hst
  accounting.formatMoney(hst)
Template.orders_total.total = -> 
  order = Orders.findOne({_id: Session.get('id')})
  total = order && order.total
  accounting.formatMoney(total)

# on re-render - use Mini-Mongo with short-circuting to re-paint both selects in-sync
# using a server method with a callback - re-paints out of sync
Template.orders_main.rendered = -> 
  order = Orders.findOne({_id: Session.get('id')})
  barista = order and order.barista
  status = order and order.status
  if !barista and !status
  else
    $("#barista option[value='" + barista + "']").attr('selected', 'selected')
    $("#status option[value='" + status + "']").attr('selected', 'selected')