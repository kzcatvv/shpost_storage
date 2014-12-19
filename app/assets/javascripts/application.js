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
//= require autocomplete-rails
//= require datepicker

//= require twitter/bootstrap
//= require turbolinks
//= require_tree .


function ajaxspecifications() {
  $('#goodstype_id').change(function(){
   $.ajax({
      type : 'GET',
      url : '/relationships/select_commodities/',
      data: { goodstype_id: $('#goodstype_id').val(),
              object_id: $('#ajax_object_id').val()},
      dataType : 'script'
    });
   return false;
  }); 

  $('#commodity_id').change(function(){
   $.ajax({
      type : 'GET',
      url : '/relationships/select_specifications/',
      data: { commodity_id: $('#commodity_id').val(),
              object_id: $('#ajax_object_id').val()},
      dataType : 'script'
    });
   return false;
  });

  /*$('#relationship_business_id').change(function(){

    $('#bid').val($('#relationship_business_id').val());
    alert($('#bid').val());
    $('#specification_name').attr('data-autocomplete','/specification_autocom/autocomplete_specification_name?objid=#{obj_id}&businessid='+$('#bid').val()+'&supplierid=#{supplier_id}');

    return false;
  });

  $('#relationship_supplier_id').change(function(){

    $('#sid').val($('#relationship_supplier_id').val());
    alert($('#sid').val());
    $('#specification_name').attr('data-autocomplete','/specification_autocom/autocomplete_specification_name?objid=#{obj_id}&businessid='+$('#bid').val()+'&supplierid='+$('#sid').val()+'');
    return false;
  });*/

  $('#return_reason').change(function(){
   if ($('#return_reason').val() == "其他")
   {
      $('#reasondtl').show();
   }
   else
  {
      $('#reasondtl').hide();
  }
   return false;
  });

  $("#setreason").click(function(){ 
    $("input[name='cbids[]']:checked").each(function () { 

          if ($('#return_reason').val() == "其他")
          {
            var textid = "#rereason_"+$(this).val();
            $(textid).val($('#reasondtl').val());
          }
          else
          {
            var textid = "#rereason_"+$(this).val();
            $(textid).val($('#return_reason').val());
          }
          $(this).attr('checked',false);
               
    })
 
    return false; 
  })

  $("#selectall").click(function(){ 
    $("input[name='cbids[]']").each(function () { 
          $(this).prop("checked",true);
               
    })
 
    return false; 
  })

  $('#r_specification_name').bind('railsAutocomplete.select', function(event, data){
    /* Do something here */
    var spid = "#"+data.item.obj+"_specification_id";
    $(spid).val(data.item.id);
  });

  $('#br_specification_name').bind('railsAutocomplete.select', function(event, data){
    /* Do something here */
    var spid = "#"+data.item.obj+"_specification_id";
    $(spid).val(data.item.id);
  });

  $('#os_specification_name').bind('railsAutocomplete.select', function(event, data){
    /* Do something here */
    var spid = "#"+data.item.obj+"_specification_id";
    $(spid).val(data.item.id);
  });

  $('#ms_specification_name').bind('railsAutocomplete.select', function(event, data){
    /* Do something here */
    var spid = "#"+data.item.obj+"_specification_id";
    $(spid).val(data.item.id);
  });

  $('#pd_specification_name').bind('railsAutocomplete.select', function(event, data){
    /* Do something here */
    var spid = "#"+data.item.obj+"_specification_id";
    $(spid).val(data.item.id);
  });

  $('#ko_specification_name').bind('railsAutocomplete.select', function(event, data){
    /* Do something here */
    var spid = "#"+data.item.obj+"_specification_id";
    $(spid).val(data.item.id);
  });

  $('#org_stocks_import_specificaion').bind('railsAutocomplete.select', function(event, data){
    /* Do something here */
    $("#si_specificationid").val(data.item.id);
  });
  
  $('#org_stocks_import_shelf_code').bind('railsAutocomplete.select', function(event, data){
    /* Do something here */
    $("#si_shelfid").val(data.item.id);
  });



};

function selfAlert(msgstr,timer){  
    //该值可以作为返回值，初始化时为 0 ，点击确定后变为 1 ，点击关闭后变为 2 ，自动关闭 3   
    var alertValue = 0;   
  
    //确定遮罩层的高度，宽度  
    // var h = screen.availHeight;  
    // var w = screen.availWidth;  
    // //创建遮罩层，它的主要作用就是使网页中的其他元素不可用。  
    // var dv = document.createElement("div");  
    // dv.setAttribute('id','bg');  
    // //设置样式  
    // dv.style.height = h + "px";  
    // dv.style.width = w + "px";  
    // dv.style.zIndex = "1111";  
    // dv.style.top = 0;  
    // dv.style.left = 0;  
      
    // //如果不想遮罩，可以去掉这两句  
    // // dv.style.background = "#fff";  
    // // dv.style.filter = "alpha(opacity=0)";  
  
    // //设为绝对定位很重要  
    // dv.style.position = "absolute";  
    // //将该元素添加至body中  
    // document.body.appendChild(dv);  
  
    //创建提示对话框面板  
    var dvMsg = document.createElement("div");  
    dvMsg.style.position = "absolute";  
    dvMsg.setAttribute('id','msg');  
    dvMsg.style.width = "280px";  
    dvMsg.style.height = "100px";  
    dvMsg.style.top="30%";  
    dvMsg.style.left="40%";  
    dvMsg.style.background = "white";  
    dvMsg.style.zIndex = "1112";  
      
    //可以继续采用如上形式创建模拟对话框表格，这里为了方便采用html形式  
    strHtml =  "<table width='280' height='25' border='0' cellspacing='0' cellpadding='0' align='center'>"  
    strHtml += "    <tr height='25' style='line-height:25px;'>"  
    strHtml += "        <td width='250' title='移动' style='cursor:move;background:#CFD7EC url(title_bg_left.gif) no-repeat top left;' onmousedown='oMove(parentNode.parentNode.parentNode.parentNode);'>"  
    strHtml += "            <font style='font-size:12px;font-weight:bold;color:#000;margin-left:10px;'>消息提示框</font></td>"  
    strHtml += "        <td width='30' style='background:#CFD7EC url(title_bg_right.gif) no-repeat right top;'>"  
    strHtml += "    <td></tr>"  
    strHtml +=  "</table>"  
    strHtml +=  "<table width='280' height='145' border='0' cellspacing='0' cellpadding='0' align='center' style='border:1px solid #343434'>"  
    strHtml += "    <tr height='113' bgcolor='#F4F4F4'><td width='' style='padding-left:10;'></td>"  
    strHtml += "        <td width='200' align='left'>" + msgstr + "</td></tr>"  
    strHtml += "    <tr height='27'><td colspan='2' style='background:#F4F4F4;padding-top:0px;' valign='top' align='center'>"  
    strHtml += "         <input type='button' value='确&nbsp;定' style='width:70;' onclick='btnclick()'></td></tr>"  
    strHtml += "</table>"  
    dvMsg.innerHTML = strHtml;  
    document.body.appendChild(dvMsg);  
  
    //点击关闭按钮  
    imgClose = function (){  
        alertValue = 2; // 2 代表点击了关闭按钮  
        // document.body.removeChild(dv);  
        document.body.removeChild(dvMsg);  
    }  
    //点击确定按钮  
    btnclick = function (){  
        alertValue = 1; // 1 代表点击了确定按钮  
        // document.body.removeChild(dv);  
        document.body.removeChild(dvMsg);  
    }  
      
    remove = function ()  
    {  
        //timer时间过后如果仍未点击，则自动关闭selfAlert框  
        if(alertValue==0){  
            // document.body.removeChild(dv);  
            document.body.removeChild(dvMsg);  
        }  
    }  
    //timer秒后自动关闭selfAlert(提示框)  
    setTimeout("remove()",timer);  
      
    //实现鼠标拖动对话框  
    oMove = function(obj) {  
        var otop,oleft;  
        otop = event.y - obj.offsetTop;  
        oleft = event.x - obj.offsetLeft;  
        obj.setCapture();  
  
        obj.onmousemove  = function()  
        {  
            obj.style.left = event.x - oleft;  
            obj.style.top = event.y - otop;  
        }  
        obj.onmouseup  = function()  
        {  
            obj.onmousemove = null;  
            obj.style.filter = null;  
            obj.releaseCapture();  
        }  
    }  
}

function clickin(current)
{
  param = current.id.split('_');
  // alert(param);
  if ($("td#stock_logs_status_"+param[3]).text()!="处理中") {
    return false;
  }
  // if (param[2] == "amount") {
    if ($("input#"+current.id).is(":hidden")){ 
      $(current).hide();
      $("input#"+current.id).show();
      $("input#"+current.id).focus();
    }
  // } else {
     if ($("select#"+current.id).is(":hidden")){ 
       $(current).hide();
       $("select#"+current.id).show();
       $("select#"+current.id).focus();
     }
  // }
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
  } else if (param[2] == "shelfid") {
    if ($(current).val() == "") {
      // $(current).val("错误的货架");
      $(current).css("background-color","red");
    } else {
      $(current).css("background-color","transparent");
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
  var tr = $("tr[id^=stock_logs_id]").eq(0).clone();
  var addid = "0"+$("tr[id^=stock_logs_id_0]").length;
  tr.attr("id","stock_logs_id_"+addid);
  tr.appendTo("table#stock_logs");
  // slid=$('table.wice-grid tr:eq(2) input').first().val();
  // var index=tr.index()+2;
  // addTr(slid,index);
  tablereplace(addid,"p","id",addid);
  tablereplace(addid,"a","id",addid);
  tablereplace(addid,"a","href",addid);
  tablereplace(addid,"input","id",addid);
  tablereplace(addid,"select","id",addid);
  tablereplace(addid,"td","id",addid);

  tableset(addid,"amount","0")
  tableset(addid,"actamount","0")
  tableset(addid,"shelfid","")
  tableset(addid,"paid","")
  tableset(addid,"status","处理中")


  // amountset(addid,0);
  // actamountset(addid,0);
  // statusset(addid,"处理中");
  // shelfset(addid,"")
  // arrivalset(addid,"")
  // linkset(index,jsonData.id, jsonData.pid);
}

function split(current)
{
  param = current.id.split('_');
  var index=current.parentNode.parentNode.rowIndex;
  var tr = $("table.wice-grid tr").eq(index+1).clone();
  $("table.wice-grid tr").eq(index+1).after(tr)
  addTr(param[3],index+2)
}

function exportorder(input)
{

  var url = "/orders/exportorders.xls";  

  var postForm = document.createElement("form");//表单对象     
  postForm.method="post" ;     
  postForm.action = url;  
  
  
  var idsInput = document.createElement("input") ;     
  idsInput.setAttribute("name", "ids") ;     
  idsInput.setAttribute("value", input);  
  postForm.appendChild(idsInput);          
  
  document.body.appendChild(postForm) ;  
  postForm.submit() ;     
  document.body.removeChild(postForm) ;    


  // $.ajax({
  //   type: "POST",
  //   url: "/orders/exportorders.xls",
  //   data: "ids=" + input,
  //   dataType: "json",
  //   complete: function(data) {
  //     if(data.success){
  //       // alert(data.responseText)
  //     } else {
  //       alert("NG!!!")
  //     }
  //   }
  // });
}

function destroy(current) {
  if(confirm("确定删除？")){
    param = current.id.split('_');
    id = param[3];
    // alert(id)
    removeTr(current);
    var index=current.parentNode.parentNode.rowIndex;
    $("tr#stock_logs_id_"+id).remove();
  }
}

function modify(current)
{
  param = current.id.split('_');
  id = param[3];
  amount = $("tr#stock_logs_id_"+id+">td>input#stock_logs_amount_"+id).val();
  shelfid = $("tr#stock_logs_id_"+id+">td>input#stock_logs_shelfid_"+id).val();
  arrivalid = $("tr#stock_logs_id_"+id+">td>select#stock_logs_paid_"+id).val();
  // alert(id);
  // alert(amount);
  // alert(shelfid);
  // alert(arrivalid);
  $.ajax({
    type: "POST",
    url: "/stock_logs/modify",
    data: "id=" + param[3] + "&amount=" + amount + "&shelfid=" + shelfid + "&arrivalid=" + arrivalid,
    dataType: "json",
    complete: function(data) {
      if(data.success){
        // alert(data.responseText)
        var jsonData = eval("("+data.responseText+")");
        $("p#stock_logs_actamount_"+param[3]).text(jsonData.actual_amount);
        if (jsonData.actual_amount < $("p#stock_logs_amount_"+param[3]).text() && jsonData.operation_type == "out") {
          $("p#stock_logs_amount_"+param[3]).css("background-color","red");
        } else {
          $("p#"+current.id).css("background-color","transparent");
        }

        // 20141219
        tablereplace(addid,"p","id",jsonData.id);
        tablereplace(addid,"a","id",jsonData.id);
        tablereplace(addid,"a","href",jsonData.id);
        tablereplace(addid,"input","id",jsonData.id);
        tablereplace(addid,"select","id",jsonData.id);
        tablereplace(addid,"td","id",jsonData.id);

        tableset(addid,"amount",jsonData.amount)
        tableset(addid,"actamount",jsonData.actual_amount)
        tableset(addid,"shelfid",jsonData.shelfid)
        tableset(addid,"paid",jsonData.paid)
        // tableset(addid,"status","处理中")
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
        tablereplace(index,"a","href",jsonData.id);
        tablereplace(index,"input","id",jsonData.id);
        tablereplace(index,"select","id",jsonData.id);
        amountset(jsonData.id,0);
        statusset(jsonData.id,"处理中");
        linkset(index,jsonData.id, jsonData.pid);
      }
    }
  });
}

function tablereplace(id,column,type,value) {
  $('table#stock_logs tr#stock_logs_id_'+id+' '+column+"[id^=stock_logs]").each(function(){
    // alert($(this).attr(type).replace(/[0-9]+$/,value));
    $(this).attr(type,$(this).attr(type).replace(/[0-9]+$/,value));
  })
}

function tableset(id,type,value) {
  $('table#stock_logs tr#stock_logs_id_'+id+' p#stock_logs_'+type+'_'+id).each(function(){
    // $(this).css('background-color','red');
    if (value == "") {
      $(this).text("未选择");
    } else {
      $(this).text(value);
    }

  })
  $('table#stock_logs tr#stock_logs_id_'+id+' input#stock_logs_'+type+'_'+id).each(function(){
    // $(this).css('background-color','red');
    $(this).val(value);
  })
  $('table#stock_logs tr#stock_logs_id_'+id+' select#stock_logs_'+type+'_'+id).each(function(){
    // $(this).css('background-color','red');
    $(this).val(value);
  })
}

// function actamountset(id,value) {
//   $('table#stock_logs tr#stock_logs_id_'+id+' p#stock_logs_actamount_'+id).each(function(){
//     // $(this).css('background-color','red');
//     $(this).text(value);
//   })
// }

// function amountset(id,value) {
//   $('table#stock_logs tr#stock_logs_id_'+id+' p#stock_logs_amount_'+id).each(function(){
//     // $(this).css('background-color','red');
//     $(this).text(value);
//   })
//   $('table#stock_logs tr#stock_logs_id_'+id+' input#stock_logs_amount_'+id).each(function(){
//     $(this).val(value);
//   })
// }

// function statusset(id,value) {
//   $('table#stock_logs tr#stock_logs_id_'+id+' td#stock_logs_status_'+id).each(function(){
//     $(this).attr("id",$(this).attr("id").replace(/[0-9]+$/,id));
//     $(this).text(value);
//   })
// }

function linkset(id) {
  // remove the check button
  // check_link_field='<a class="btn btn-xs btn-info" href="/purchases/'+pid+'/onecheck?stock_log='+id+'" id="stock_logs_checklink_'+id+'" rel="nofollow" data-method="patch">确认入库</a>';
  // remove the split button
  // split_link_field='<a class="btn btn-xs btn-danger" href="javascript:void(0);" id="stock_logs_splitlink_'+id+'" onclick="split(this)">拆单</a>';
  delete_link_field='<a class="btn btn-xs btn-danger" href="javascript:void(0);" id="stock_logs_deletelink_'+id+'" onclick="destroy(this)">删除</a>';
  $('table#stock_logs tr:last td').last().html(delete_link_field);
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


