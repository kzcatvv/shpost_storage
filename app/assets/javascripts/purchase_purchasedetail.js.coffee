# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready = ->
  $('#purchase_detail_supplier_id').change(pdsid)

  pdsid

$(document).ready(ready)
$(document).on('page:load', ready)

pdsid= ->
    $('#pd_sid').val($('#purchase_detail_supplier_id').val());
    pdid = $('#pd_sid').val();

    surl = $("#pd_specification_name").attr("data-autocomplete");

    alert(surl);
    
    s = '&supplierid=';
    indexs = surl.lastIndexOf(s);

    if indexs <0
       url = surl+s+pdid
    else
       url = surl.slice(0,indexs)+s+pdid

    alert(url);
       
    
    $("#pd_specification_name").attr("data-autocomplete",url);
    
    alert($("#pd_specification_name").attr("data-autocomplete") );

    return false;