# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready = ->
  $("#manual_stock_detail_supplier_id").change(msid)

$(document).ready(ready)
$(document).on('page:load', ready)

msid= ->
    $('#sid').val($('#manual_stock_detail_supplier_id').val());
    slid = $('#sid').val();

    surl = $('#specification_name').attr('data-autocomplete');
    
    s = '&supplierid=';
    indexs = surl.lastIndexOf(s);

    if indexs <0
       url = surl+s+slid
    else
       url = surl.slice(0,indexs)+s+slid

    $('#specification_name').attr('data-autocomplete',url);
    
    return false;