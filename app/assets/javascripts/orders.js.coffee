# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
enterpress = (e) ->
  e = e || window.event;   
  if e.keyCode == 13    
    orderout()
    $('#tracking_number').val("");
    return false;

enterpress2 = (e) ->
  e = e || window.event;   
  if e.keyCode == 13    
    setorderweight()
    $('#goods_weight').val("");
    return false;
    
$ ->
  ready()

$(document).on "page:load",->
  ready()

ready = ->
  $("#tracking_number").keypress(enterpress)
  $("#goods_weight").keypress(enterpress2)

orderout = -> 
        $.ajax({
          type : 'GET',
          url : '/orders/findorderout/',
          data: { tracking_number: $('#tracking_number').val(),
          _tracking_number: $('#_tracking_number').val(),
          orderid: $('#orderid').val()},
          dataType : 'script'
          });

setorderweight = -> 
        $.ajax({
          type : 'GET',
          url : '/orders/setorallweight/',
          data: { orweight: $('#goods_weight').val(),
          orderid: $('#orderid').val()},
          dataType : 'script'
          });