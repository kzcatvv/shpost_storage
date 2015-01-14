# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
  
$ ->
  ready()

$(document).on "page:load",->
  ready()

ready = ->
  pdsid()
  $('#purchase_detail_supplier_id').change(pdsid)

pdsid = ->
  
  supplier_id = $('#purchase_detail_supplier_id').val()
  
  surl = $("#pd_specification_name").attr("data-autocomplete");

  s = "&supplierid=";

  if surl != undefined
    indexs = surl.lastIndexOf(s);

    if indexs <0
      url = surl + s + supplier_id
    else
      url = surl.slice(0,indexs) + s + supplier_id

    $("#pd_specification_name").attr("data-autocomplete",url);
    
 