# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready = ->
  $("#relationship_business_id").change(bid)
  $("#relationship_supplier_id").change(sid)

$(document).ready(ready)
$(document).on('page:load', ready)

bid= ->
    $('#bid').val($('#relationship_business_id').val());
    bsid = $('#bid').val();

    burl = $('#specification_name').attr('data-autocomplete');
    b = '&businessid=';
    s = '&supplierid=';
    indexb = burl.lastIndexOf(b);
    indexs = burl.lastIndexOf(s);

    if indexs <0
      if indexb <0
         url = burl+b+bsid
         
      else
         arr = burl.split('&')
         url = arr[0]+b+bsid
         
    else
      if indexb <0
         url = burl+b+bsid
         
      else
         if arr[1].indexOf(b)>=0
            arr[1] = b+bsid
            
         else
            arr[2] = b+bsid
         url = arr[0]+arr[1]+arr[2]
    
    
    $('#specification_name').attr('data-autocomplete',url);


    return false;

sid= ->
    $('#sid').val($('#relationship_supplier_id').val());
    slid = $('#sid').val();

    surl = $('#specification_name').attr('data-autocomplete');
    b = '&businessid=';
    s = '&supplierid=';
    indexb = surl.lastIndexOf(b);
    indexs = surl.lastIndexOf(s);

    if indexb <0
      if indexs <0
         url = surl+s+slid
         
      else
         arr = surl.split('&')
         url = arr[0]+s+slid
         
    else
      if indexs <0
         url = surl+s+slid
         
      else
         if arr[1].indexOf(s)>=0
            arr[1] = s+slid
            
         else
            arr[2] = s+slid
         url = arr[0]+arr[1]+arr[2]
    
    
    $('#specification_name').attr('data-autocomplete',url);
    return false;

