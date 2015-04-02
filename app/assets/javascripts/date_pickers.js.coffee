ready = ->
  $('#purchase_arrival_arrived_at').datepicker({
    changeMonth:true,
    changeYear:true
  });
  $('#purchase_arrival_expiration_date').datepicker({
    changeMonth:true,
    changeYear:true
  });
  $('#purchase_detail_expiration_date').datepicker({
    showAnim:"blind",
    changeMonth:true,
    changeYear:true
  });
  $('#start_date_start_date').datepicker({
    changeMonth:true,
    changeYear:true
  });
  $('#end_date_end_date').datepicker({
    changeMonth:true,
    changeYear:true
  });
  $('#sp_start_date_sp_start_date').datepicker({
    changeMonth:true,
    changeYear:true
  });
  $('#sp_end_date_sp_end_date').datepicker({
    changeMonth:true,
    changeYear:true
  });

$(document).ready(ready)
$(document).on('page:load', ready)