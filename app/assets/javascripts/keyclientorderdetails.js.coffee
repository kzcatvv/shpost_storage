# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready = ->
  $("#keyclientorderdetail_supplier_id").change(kosid)

  kosid()

$ ->
  ready()

$(document).on "page:load",->
  ready()

kosid= ->
    $('#ko_sid').val($('#keyclientorderdetail_supplier_id').val());
    koid = $('#ko_sid').val();

    surl = $('#ko_specification_name').attr('data-autocomplete');
    
    s = '&supplierid=';
    indexs = surl.lastIndexOf(s);

    if indexs <0
       url = surl+s+koid
    else
       url = surl.slice(0,indexs)+s+koid

    $('#ko_specification_name').attr('data-autocomplete',url);
    
    return false;