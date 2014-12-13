# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

enterpress = (e) ->
  e = e || window.event;   
  if e.keyCode == 13    
    countscan()
    return false;   

dosplit = ->
  splitanorder()
  return false;

donumber = ->
  settrackingnumber()
  return false;
    
$ ->
  ready()

$(document).on "page:load",->
  ready()

ready = ->
  $("#b2bos_sixnine_code").keypress(enterpress)
  $("#splitorder").click(dosplit)
  $("#setsptnumber").click(donumber)

countscan = -> 
        $.ajax({
          type : 'GET',
          url : '/keyclientorders/b2bfind69code/',
          data: { sixninecode: $('#b2bos_sixnine_code').val(),keyco: $('#keyco').val() },
          dataType : 'script'
          });

splitanorder = -> 
        $.ajax({
          type : 'GET',
          url : '/keyclientorders/b2bsplitanorder/',
          data:  $('#keydtl input[type=\'text\'],#keydtl input[type=\'hidden\']'),
          dataType : 'script'
          });

settrackingnumber = -> 
        $.ajax({
          type : 'GET',
          url : '/keyclientorders/b2bsettrackingnumber/',
          data: { split_tracking_num: $('#so_tra_num').val(),keyco: $('#keyco').val(),split_order: $('#splitorderid').val() },
          dataType : 'script'
          });