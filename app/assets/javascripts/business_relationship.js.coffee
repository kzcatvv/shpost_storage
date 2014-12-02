# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  ready()

$(document).on "page:load",->
  ready()

ready = ->
  brsid()
  $("#relationship_supplier_id").change(brsid)

brsid= ->
  $('#br_sid').val($('#relationship_supplier_id').val());
  brid = $('#br_sid').val();
  surl = $('#br_specification_name').attr('data-autocomplete');
  #alert("business relationship")
  s = '&supplierid=';
  if surl != undefined
    indexs = surl.lastIndexOf(s);
      
    if indexs <0
      url = surl + s + brid
    else
      url = surl.slice(0,indexs) + s + brid
      
    $('#br_specification_name').attr("data-autocomplete",url);

  #return false;