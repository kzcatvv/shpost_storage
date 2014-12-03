# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready = ->
  $("#manual_stock_detail_supplier_id").change(mssid)
  
  mssid()

$ ->
  ready()

$(document).on "page:load",->
  ready()

mssid= ->
    $('#ms_sid').val($('#manual_stock_detail_supplier_id').val());
    msid = $('#ms_sid').val();

    surl = $('#ms_specification_name').attr('data-autocomplete');
    
    s = '&supplierid=';
    indexs = surl.lastIndexOf(s);

    if indexs <0
       url = surl+s+msid
    else
       url = surl.slice(0,indexs)+s+msid

    $('#ms_specification_name').attr('data-autocomplete',url);
    
    return false;