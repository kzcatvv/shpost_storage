// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require wice_grid

//= require twitter/bootstrap
//= require turbolinks
//= require_tree .


function ajaxspecifications() {
  $('#ajax_goodstype_id').change(function(){
   $.ajax({
      type : 'GET',
      url : '/thirdpartcodes/select_commodities/',
      data: { goodstype_id: $('#ajax_goodstype_id').val()},
      dataType : 'script'
    });
   return false;
  }); 

  $('#ajax_commodity_id').change(function(){
   $.ajax({
      type : 'GET',
      url : '/thirdpartcodes/select_specifications/',
      data: { commodity_id: $('#ajax_commodity_id').val(),
              object_id: $('#ajax_object_id').val()},
      dataType : 'script'
    });
   return false;
  }); 
};

function clickin(current)
{
  param = current.id.split('_');
  if ($("td#stock_logs_status_"+param[3]).text()!="waiting") {
    return false;
  }
  if (param[2] == "amount") {
    if ($("input#"+current.id).is(":hidden")){ 
      $(current).hide();
      $("input#"+current.id).show();
      $("input#"+current.id).focus();
    }
  } else {
    if ($("select#"+current.id).is(":hidden")){ 
      $(current).hide();
      $("select#"+current.id).show();
      $("select#"+current.id).focus();
    }
  }
}

function hideit(current)
{
  param = current.id.split('_');
  $("p#"+current.id).show();
  if (param[2] == "amount") {
    if ($(current).val() == "") {
      $(current).val(0);
    }
    $("p#"+current.id).text($(current).val());
  } else {
    $("p#"+current.id).text($(current).find("option:selected").text());
  }
  $(current).hide();
}

function clickout(current)
{
  hideit(current);
  modify(current);
}

function add() {
  var tr = $("table.wice-grid tr").eq(2).clone();
  tr.appendTo("table.wice-grid");
  slid=$('table.wice-grid tr:eq(2) input').first().val();
  var index=tr.index()+2;
  addTr(slid,index);
}



function destroy(current) {
  if(confirm("确定删除？")){
    removeTr(current);
    var index=current.parentNode.parentNode.rowIndex;
    $("table.wice-grid tr").eq(index+1).remove();
  }
}

function modify(current)
{
  param = current.id.split('_');
  $.ajax({
    type: "POST",
    url: "/stock_logs/modify",
    data: "id=" + param[3] + "&" + param[2] + "=" + $(current).val(),
    dataType: "json",
    complete: function(data) {
      if(data.success){
        // alert(data.responseText)
        var jsonData = eval("("+data.responseText+")");
        $("td#stock_logs_actamount_"+param[3]).text(jsonData.actual_amount);
        if (jsonData.actual_amount < $("p#stock_logs_amount_"+param[3]).text() && jsonData.operation_type == "out") {
          $("p#stock_logs_amount_"+param[3]).css("background-color","red");
        } else {
          $("p#"+current.id).css("background-color","transparent");
        }
      }
    }
  });
}

function addTr(slid,index)
{
  $.ajax({
    type: "POST",
    url: "/stock_logs/addtr",
    data: "id=" + slid,
    dataType: "json",
    complete: function(data) {
      if(data.success){
        var jsonData = eval("("+data.responseText+")");
        tablereplace(index,"p","id",jsonData.id);
        tablereplace(index,"a","id",jsonData.id);
        tablereplace(index,"input","id",jsonData.id);
        tablereplace(index,"select","id",jsonData.id);
        amountset(index,jsonData.id,0);
        statusset(slid,index,jsonData.id,"waiting");
        linkset(index,jsonData.id);
      }
    }
  });
}

function tablereplace(index,column,type,value) {
  $('table.wice-grid tr:eq('+index+') '+column).each(function(){
    // alert($(this).attr(type).replace(/[0-9]+$/,value));
    $(this).attr(type,$(this).attr(type).replace(/[0-9]+$/,value));
  })
}

function amountset(index,id,value) {
  $('table.wice-grid tr:eq('+index+') p#stock_logs_amount_'+id).each(function(){
    $(this).css('background-color','red');
    $(this).text(value);
  })
  $('table.wice-grid tr:eq('+index+') input#stock_logs_amount_'+id).each(function(){
    $(this).val(value);
  })
}

function statusset(slid,index,id,value) {
  $('table.wice-grid tr:eq('+index+') td#stock_logs_status_'+slid).each(function(){
    $(this).attr("id",$(this).attr("id").replace(/[0-9]+$/,id));
    $(this).text(value);
  })
}

function linkset(index,id) {
  link_field='<a class="btn btn-xs btn-danger" href="javascript:void(0);" id="stock_logs_link_'+id+'" onclick="destroy(this)">删除</a>';
  $('table.wice-grid tr:eq('+index+') td').last().html(link_field);
}

function removeTr(current)
{
  param = current.id.split('_');
  $.ajax({
    type: "POST",
    url: "/stock_logs/removetr",
    data: "id=" + param[3],
    dataType: "json",
    complete: function() {
      $("p#"+current.id).css("background-color","transparent");
    }
  });
}