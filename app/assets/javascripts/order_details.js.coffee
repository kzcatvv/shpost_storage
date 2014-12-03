# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready = ->
  $("#order_detail_supplier_id").change(ossid)

ossid()

$ ->
  ready()

$(document).on "page:load",->
  ready()

ossid= ->
    $('#os_sid').val($('#order_detail_supplier_id').val());
    osid = $('#os_sid').val();

    surl = $('#os_specification_name').attr('data-autocomplete');
    
    s = '&supplierid=';
    indexs = surl.lastIndexOf(s);

    if indexs <0
       url = surl+s+osid
    else
       url = surl.slice(0,indexs)+s+osid

    $('#os_specification_name').attr('data-autocomplete',url);
    
    return false;