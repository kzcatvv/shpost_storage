# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
  #$('#purchase_detail_supplier_id').val()?.pdsid
  #pdsid
 
$ ->
  ready()

$(document).on "page:load",->
  ready()

ready = ->
  pdsid()
  $('#purchase_detail_supplier_id').change(pdsid)

pdsid = ->
  supplier_id = $('#purchase_detail_supplier_id').val()
  #alert(supplier_id)
  #$('#pd_sid').val(supplier_id);
  #pdid = $('#pd_sid').val();

  surl = $("#pd_specification_name").attr("data-autocomplete");

  #alert("purchase");
    
  s = "&supplierid=";

  if surl != undefined
    indexs = surl.lastIndexOf(s);

    if indexs <0
      url = surl + s + supplier_id
    else
      url = surl.slice(0,indexs) + s + supplier_id

    $("#pd_specification_name").attr("data-autocomplete",url);
    
  #return false;