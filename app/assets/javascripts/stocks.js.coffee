# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  ready()

$(document).on "page:load",->
  ready()

ready = ->
  $("#org_stocks_import_unit").change(ajaxunitselect)
  $("#org_stocks_import_storage").change(setautostorageid)
  $("#org_stocks_import_business").change(setautobusinessid)
  $("#org_stocks_import_supplier").change(setautosupplierid)

ajaxunitselect= ->
  $.ajax({
      type : 'GET',
      url : '/stocks/select_unit/',
      data: { unit_id: $('#org_stocks_import_unit').val()},
      dataType : 'script'
    });

setautostorageid= ->
  $('#si_storageid').val($('#org_stocks_import_storage').val());
  stoid = $('#si_storageid').val();
  surl = $('#org_stocks_import_shelf_code').attr('data-autocomplete');

  s = '?storage_id=';
  if surl != undefined
    indexs = surl.lastIndexOf(s);

    if indexs <0
      url = surl + s + stoid
    else
      url = surl.slice(0,indexs) + s + stoid

    $('#org_stocks_import_shelf_code').attr("data-autocomplete",url);

setautobusinessid= ->
  $('#si_businessid').val($('#org_stocks_import_business').val());
  sibuid = $('#si_businessid').val();
  surl = $('#org_stocks_import_specificaion').attr('data-autocomplete');
  
  s = '&businessid=';
  if surl != undefined
    indexs = surl.lastIndexOf(s);
      
    if indexs <0
      url = surl + s + sibuid
    else
      url = surl.slice(0,indexs) + s + sibuid
      
    $('#org_stocks_import_specificaion').attr("data-autocomplete",url);

setautosupplierid= ->
  $('#si_supplierid').val($('#org_stocks_import_supplier').val());
  sisuid = $('#si_supplierid').val();
  surl = $('#org_stocks_import_specificaion').attr('data-autocomplete');
  
  s = '&supplierid=';
  if surl != undefined
    indexs = surl.lastIndexOf(s);
      
    if indexs <0
      url = surl + s + sisuid
    else
      url = surl.slice(0,indexs) + s + sisuid
      
    $('#org_stocks_import_specificaion').attr("data-autocomplete",url);
