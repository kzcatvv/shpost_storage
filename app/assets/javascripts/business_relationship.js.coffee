# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready = ->
  $("#relationship_supplier_id").change(brsid)
  brsid

$(document).ready(ready)
$(document).on('page:load', ready)

brsid= ->
    $('#br_sid').val($('#relationship_supplier_id').val());
    brid = $('#br_sid').val();
    alert("aaaa");
    surl = $('#br_specification_name').attr('data-autocomplete');

    
    
    s = '&supplierid=';
    indexs = surl.lastIndexOf(s);
    
    
    if indexs <0
       url = surl+s+brid
       
    else
       url = surl.slice(0,indexs)+s+brid
    
    
     
    $('#br_specification_name').attr("data-autocomplete",url);

    return false;