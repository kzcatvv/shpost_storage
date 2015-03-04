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
//= require datepicker
//= require autocomplete-rails


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



}

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

function add() {
  var tr = $("tr[id^=stock_logs_id]").eq(0).clone();
  var addid = "00";
  if ($("tr[id^=stock_logs_id_0]").last().attr("id") != undefined ) {
    param = $("tr[id^=stock_logs_id_0]").last().attr("id").split('_');
    addid = "0"+ (parseInt(param[3])+1);
  }
  alert(addid);
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

  tableset(addid,"id",addid)
  tableset(addid,"amount","0")
  tableset(addid,"actamount","0")
  tableset(addid,"shelfid","")
  tableset(addid,"paid","")
  tableset(addid,"status","处理中")

  ajaxstocklogs();
}

// function split(current)
// {
//   param = current.id.split('_');
//   var index=current.parentNode.parentNode.rowIndex;
//   var tr = $("table.wice-grid tr").eq(index+1).clone();
//   $("table.wice-grid tr").eq(index+1).after(tr)
//   addTr(param[3],index+2)
// }

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
    removeTr(current);
    var index=current.parentNode.parentNode.rowIndex;
    $("tr#stock_logs_id_"+id).remove();
  }
}

function assign_select()
{
  var userid = $("select#assign_user").val();
  var uri = window.location.href;
  param = uri.split('/');
  $.ajax({
    type: "POST",
    url: "/"+param[3]+"/"+param[4]+"/assign_select",
    data: "assign_user=" + userid,
    dataType: "json",
    complete: function(data) {
      if(data.success){
        // alert(data.responseText);
        // var jsonData = eval("("+data.responseText+")");
        alert("分配任务成功！");
      } else {
        alert("分配任务失败！");
      }
      window.close();
    }
  });
  
}

function purchase_modify(current)
{
  param = current.id.split('_');
  id = param[3];
  // alert("purchase modified");
  amount = $("tr#stock_logs_id_"+id+">td>input#stock_logs_amount_"+id).val();
  shelfid = $("tr#stock_logs_id_"+id+">td>input[id=stock_logs_shelfid_"+id+"][type=hidden]").val();
  arrivalid = $("tr#stock_logs_id_"+id+">td>select#stock_logs_paid_"+id).val();

  var x = param[3].substring(0,1)
  if (x == "0") {
    x = ""
  } else {
    x = param[3]
  }
  if (arrivalid == null) {
    arrivalid = ""
  }

  $.ajax({
    type: "POST",
    url: "/stock_logs/purchase_modify",
    data: "id=" + x + "&amount=" + amount + "&shelf_id=" + shelfid + "&arrival_id=" + arrivalid,
    dataType: "json",
    complete: function(data) {
      if(data.success){
        // alert(data.responseText);
        var jsonData = eval("("+data.responseText+")");
        // $("p#stock_logs_actamount_"+param[3]).text(jsonData.actual_amount);
        // if (jsonData.actual_amount < $("p#stock_logs_amount_"+param[3]).text() && jsonData.operation_type == "out") {
        //   $("p#stock_logs_amount_"+param[3]).css("background-color","red");
        // } else {
        //   $("p#"+current.id).css("background-color","transparent");
        // }

        // 20141219
        if (jsonData.id != undefined) {
          // f = (param[3] == (jsonData.id+""));
          // alert(param[3]);
          // alert(jsonData.id);
          // alert(f);
          if ((param[3] != (jsonData.id+"")) && (param[3].substring(0,1) == "0")) {
          $("tr#stock_logs_id_"+param[3]).attr("id","stock_logs_id_"+jsonData.id);
          tablereplace(jsonData.id,"p","id",jsonData.id);
          tablereplace(jsonData.id,"a","id",jsonData.id);
          tablereplace(jsonData.id,"a","href",jsonData.id);
          tablereplace(jsonData.id,"input","id",jsonData.id);
          tablereplace(jsonData.id,"select","id",jsonData.id);
          tablereplace(jsonData.id,"td","id",jsonData.id);
          }

          tableset(jsonData.id,"id",jsonData.id)
          tableset(jsonData.id,"amount",""+jsonData.amount)
          tableset(jsonData.id,"actamount",""+jsonData.total_amount)

          if (amount != jsonData.amount) {
            alert("该明细最大可入库数量：" + jsonData.amount);
          }
          // tableset(param[3],"shelfid",shelfid)
          // tableset(addid,"paid",jsonData.paid)
          // tableset(addid,"status","处理中")
        }
      }
    }
  });
}


// function addTr(slid,index)
// {
//   $.ajax({
//     type: "POST",
//     url: "/stock_logs/addtr",
//     data: "id=" + slid,
//     dataType: "json",
//     complete: function(data) {
//       if(data.success){
//         var jsonData = eval("("+data.responseText+")");
//         tablereplace(index,"p","id",jsonData.id);
//         tablereplace(index,"a","id",jsonData.id);
//         tablereplace(index,"a","href",jsonData.id);
//         tablereplace(index,"input","id",jsonData.id);
//         tablereplace(index,"select","id",jsonData.id);
//         amountset(jsonData.id,0);
//         statusset(jsonData.id,"处理中");
//         linkset(index,jsonData.id, jsonData.pid);
//       }
//     }
//   });
// }

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
  $('table#stock_logs tr#stock_logs_id_'+id+' td#stock_logs_'+type+'_'+id).each(function(){
    // $(this).css('background-color','red');
    $(this).text(value);
  })
}

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
  var x = param[3].substring(0,1)
  if (x == "0") {
    x = ""
  } else {
    x = param[3]
  }
  var invid = $("#inventoryid").val();
  if (invid == null){
    invid=""
  }
  $.ajax({
    type: "POST",
    url: "/stock_logs/remove",
    data: "id=" + x +"&inv_id=" + invid,
    dataType: "json",
    complete: function() {
      $("p#"+current.id).css("background-color","transparent");
    }
  });
}

function iswaiting(current)
{
  param = current.id.split('_');
  if ($("td#stock_logs_status_"+param[3]).text() == "处理中") {
    return true
  } else {
    return false
  }
}

function  ajaxstocklogs(){
  $("input[id^=stock_logs_shelfid]").unbind('railsAutocomplete.select').bind('railsAutocomplete.select', function(event, data){
    $("input[id="+this.id+"][type=text]").val(data.item.value);
    $("input[id="+this.id+"][type=hidden]").val(data.item.id);
    $("input[id="+this.id+"][type=text]").blur();
  });

  $("p[id^=stock_logs_paid]").unbind('click').click(function() {
    if (iswaiting(this)) {
      $(this).toggle();
      $("select#"+this.id).toggle();
      $("select#"+this.id).focus();
    }
  });

  $("p[id^=stock_logs_shelfid]").unbind('click').click(function() {
    if (iswaiting(this)) {
      $(this).toggle();
      $("input#"+this.id).toggle();
      // $("input#"+this.id).val($(this).text());
      $("input#"+this.id).focus();
    }
  });

  $("p[id^=stock_logs_amount]").unbind('click').click(function() {
    // alert("amount click");
    if (iswaiting(this)) {
      $(this).toggle();
      $("input#"+this.id).toggle();
      $("input#"+this.id).focus();
    }
  });

  $("select[id^=stock_logs_paid]").unbind('blur').blur(function() {
    $(this).toggle();
    $("p#"+this.id).toggle();
    $("p#"+this.id).text($(this).find("option:selected").text());
    purchase_modify(this);
  });

  $("input[id^=stock_logs_shelfid]").unbind('blur').blur(function() {
    $(this).toggle();
    $("p#"+this.id).toggle();
    if ($(this).val() == "") {
      $("p#"+this.id).text("未选择");
    } else {
      $("p#"+this.id).text($(this).val());
    }
    purchase_modify(this);
  });

  $("input[id^=stock_logs_amount]").unbind('blur').blur(function() {
    // alert("amount blur");
    $(this).toggle();
    $("p#"+this.id).toggle();
    if ($(this).val() == "") {
      $("p#"+this.id).text("0");
    } else {
      $("p#"+this.id).text($(this).val());
    }
    purchase_modify(this);
  });

  $("p[id^=stock_logs_msid]").unbind('click').click(
    function() {
    if (iswaiting(this)){ 
      $(this).toggle();
      $("select#"+this.id).toggle();
      $("select#"+this.id).focus();
    }
    }
  );

  $("p[id^=stock_logs_mshelfid]").unbind('click').click(
    function() {
    param = this.id.split('_');
    id = param[3];
    stid = $("tr#stock_logs_id_"+id+">td>input[id=stock_logs_stid_"+id+"][type=hidden]").val();
    manual_stock_detail_modify(this);
    if (stid != null || stid != ""){
      $("select#"+this.id).val(stid);
    }
      
      
    if (iswaiting(this)){
      $(this).toggle();
      $("select#"+this.id).toggle();
      $("select#"+this.id).focus();
    }
    }
  );

  $("p[id^=stock_logs_mamount]").unbind('click').click(
    function() {
    if (iswaiting(this)){ 
      $(this).toggle();
      $("input#"+this.id).toggle();
      $("input#"+this.id).focus();
    }
  }
  );

  $("select[id^=stock_logs_msid]").unbind('blur').blur(
    function() {
    $(this).toggle();
    $("p#"+this.id).toggle();
    if ($(this).find("option:selected").text() == "") {
      $("p#"+this.id).text("未选择");
    }
    else {
      $("p#"+this.id).text($(this).find("option:selected").text());
    }
    manual_stock_modify(this);
  }
  );

  $("select[id^=stock_logs_mshelfid]").unbind('blur').blur(
    function() {
    $(this).toggle();
    $("p#"+this.id).toggle();
    if ($(this).find("option:selected").text() == "") {
      $("p#"+this.id).text("请先选择批量出库单明细");
    }
    else {
      $("p#"+this.id).text($(this).find("option:selected").text());
    }
    manual_stock_modify(this);
  }
  );

  $("input[id^=stock_logs_mamount]").unbind('blur').blur(
    function() {
    $(this).toggle();
    $("p#"+this.id).toggle();
    if ($(this).val() == ""){
      $("p#"+this.id).text("0");
    }
    else {
      $("p#"+this.id).text($(this).val());
    }
    
    manual_stock_modify(this);
  }
  );

  $("p[id^=stock_logs_ksid]").unbind('click').click(
    function() {
    if (iswaiting(this)){ 
      $(this).toggle();
      $("select#"+this.id).toggle();
      $("select#"+this.id).focus();
    }
    }
  );

  $("p[id^=stock_logs_kshelfid]").unbind('click').click(
    function() {
    param = this.id.split('_');
    id = param[3];
    kstid = $("tr#stock_logs_id_"+id+">td>input[id=stock_logs_kstid_"+id+"][type=hidden]").val();
    keyclientorder_stock_detail_modify(this);
    if (kstid != null || kstid != "")
      $("select#"+this.id).val(kstid);
    if (iswaiting(this)){
      $(this).toggle();
      $("select#"+this.id).toggle();
      $("select#"+this.id).focus();
    }
    }
  );

  $("p[id^=stock_logs_kamount]").unbind('click').click(
    function() {
    if (iswaiting(this)){ 
      $(this).toggle();
      $("input#"+this.id).toggle();
      $("input#"+this.id).focus();
    }
  }
  );

  $("select[id^=stock_logs_ksid]").unbind('blur').blur(
    function() {
    $(this).toggle();
    $("p#"+this.id).toggle();
    if ($(this).find("option:selected").text() == "") {
      $("p#"+this.id).text("未选择");
    }
    else {
      $("p#"+this.id).text($(this).find("option:selected").text());
    }
    
    keyclientorder_stock_modify(this);
  }
  );

  $("select[id^=stock_logs_kshelfid]").unbind('blur').blur(
    function() {
    $(this).toggle();
    $("p#"+this.id).toggle();
    if ($(this).find("option:selected").text() == "") {
      $("p#"+this.id).text("请先选择电商出库单明细");
    }
    else {
      $("p#"+this.id).text($(this).find("option:selected").text());
    }
    
    keyclientorder_stock_modify(this);
  }
  );

  $("input[id^=stock_logs_kamount]").unbind('blur').blur(
    function() {
    $(this).toggle();
    $("p#"+this.id).toggle();
    if ($(this).val() == ""){
      $("p#"+this.id).text("0");
    }
    else {
      $("p#"+this.id).text($(this).val());
    }
    
    keyclientorder_stock_modify(this);
  }
  );


  $("input[id^=stock_logs_oshelfid]").unbind('railsAutocomplete.select').bind('railsAutocomplete.select', function(event, data){
    $("input[id="+this.id+"][type=text]").val(data.item.value);
    $("input[id="+this.id+"][type=hidden]").val(data.item.id);
    $("input[id="+this.id+"][type=text]").blur();
  });

  $("p[id^=stock_logs_orid]").unbind('click').click(function() {
    if (iswaiting(this)) {
      $(this).toggle();
      $("select#"+this.id).toggle();
      $("select#"+this.id).focus();
    }
  });

  $("p[id^=stock_logs_oshelfid]").unbind('click').click(function() {
    if (iswaiting(this)) {
      $(this).toggle();
      $("input#"+this.id).toggle();
      $("input#"+this.id).focus();
    }
  });

  $("p[id^=stock_logs_oamount]").unbind('click').click(function() {
    if (iswaiting(this)) {
      $(this).toggle();
      $("input#"+this.id).toggle();
      $("input#"+this.id).focus();
    }
  });

  $("select[id^=stock_logs_orid]").unbind('blur').blur(function() {
    $(this).toggle();
    $("p#"+this.id).toggle();
    $("p#"+this.id).text($(this).find("option:selected").text());
    order_return_modify(this);
  });

  $("input[id^=stock_logs_oshelfid]").unbind('blur').blur(function() {
    $(this).toggle();
    $("p#"+this.id).toggle();
    if ($(this).val() == "") {
      $("p#"+this.id).text("未选择");
    } else {
      $("p#"+this.id).text($(this).val());
    }
    order_return_modify(this);
  });

  $("input[id^=stock_logs_oamount]").unbind('blur').blur(function() {
    $(this).toggle();
    $("p#"+this.id).toggle();
    if ($(this).val() == "") {
      $("p#"+this.id).text("0");
    } else {
      $("p#"+this.id).text($(this).val());
    }
    order_return_modify(this);
  });

  $("input[id^=stock_logs_pickshelf]").unbind('railsAutocomplete.select').bind('railsAutocomplete.select', function(event, data){
    $("input[id="+this.id+"][type=text]").val(data.item.value);
    $("input[id="+this.id+"][type=hidden]").val(data.item.id);
    $("input[id="+this.id+"][type=text]").blur();
    param = this.id.split('_');
    id = param[3];
    sheid = $("input[id="+this.id+"][type=hidden]").val();
    $.ajax({
      type: "POST",
      url: "/stock_logs/mod_stocklog_pickin_shelf",
      data: "id=" + id + "&shelfid=" + sheid,
      dataType: "json",
      complete: function(data) {
        if (data.success){
       
        } 
      }  
    });
  });

  $("a[id$=assign]").unbind('click').click(
    function() {
      window.open('assign' ,'_assign','top=200,left=300,width=500,height=300,menubar=no,toolbar=no,location=no,directories=no,status=no,scrollbars=no,resizable=no');
    });

  $("a#assign_select").unbind('click').click(
    function() {
      assign_select();
      // window.close();
})

}




function add_move_stock_dtl(){
  var rand = "00";
  if ($("tr[id^=md_0]").last().attr("id") != undefined ) {
    param = $("tr[id^=md_0]").last().attr("id").split('_');
    rand = "0"+ (parseInt(param[1])+1);
  }

  var htmls = "<tr id='md_"+rand+"'><td><input type=\"hidden\" id='md_stock_log_"+rand+"' name='md_stock_log_"+rand+"'><input type=\"text\" id='md_out_shelf_"+rand+"' name='md_out_shelf_"+rand+"' data-autocomplete='/shelves/autocomplete_shelf_shelf_code'><input type=\"hidden\" id='md_out_shelf_"+rand+"' name='md_out_shelf_"+rand+"'></td>";
  htmls=htmls + "<td><select id='md_stock_"+rand+"' name='md_stock_"+rand+"'><option value=\"0\">请选择</option></select></td>";
  htmls=htmls + "<td><input type=\"text\" id='md_stock_amount_"+rand+"' name='md_stock_amount_"+rand+"' value='0' disabled='true'></td>";
  htmls=htmls + "<td><input type=\"text\" id='md_amount_"+rand+"' name='md_amount_"+rand+"' value='0'></td>";
  htmls=htmls + "<td><input type=\"text\" id='md_shelf_"+rand+"' name='md_shelf_"+rand+"' data-autocomplete='/shelves/autocomplete_shelf_shelf_code'><input type=\"hidden\" id='md_shelf_"+rand+"' name='md_shelf_"+rand+"'></td>"
  htmls=htmls + "<td><input type=\"button\" onclick=\"del_move_stock_dtl(this);\", id='md_del_"+rand+"' name='md_del_"+rand+"' class='btn btn-xs btn-danger' value='删除'</td></tr>";
  
  $("#move_stock_dtl").append(htmls);
  $("#dtl_cnt").val(rand);

  ajaxmovestock();
    
}

function del_move_stock_dtl(current) {
  if(confirm("确定删除？")){
    param = current.id.split('_');
    id = param[2];
    if ( $("#md_stock_log_"+id).val() == undefined || $("#md_stock_log_"+id).val() == "" ){
      $("tr#md_"+id).remove();
    }else{
      $.ajax({
        type: "POST",
        url: "/stock_logs/move_stock_remove",
        data: "stock_log_id=" + $("#md_stock_log_"+id).val(),
        dataType: "json",
        complete: function() {

        }
      });
      $("tr#md_"+id).remove();
    }
    
  }
}

function move_stock_modify(current)
{
  param = current.id.split('_');
  id = param[2];
  amount = $("#md_amount_"+id).val();
  shelfid = $("input[id=md_shelf_"+id+"][type=hidden]").val();
  stockid = $("select#md_stock_"+id).val();
  stocklogid = $("#md_stock_log_"+id).val();
  movestockid = $("#movestockid").val();

  $.ajax({
    type: "POST",
    url: "/stock_logs/move_stock_modify",
    data: "stocklogid=" + stocklogid + "&amount=" + amount + "&shelf_id=" + shelfid + "&stock_id=" + stockid + "&move_stock_id=" + movestockid,
    dataType: "json",
    complete: function(data) {
      if(data.success){
        // alert(data.responseText);
        var jsonData = eval("("+data.responseText+")");
        // $("p#stock_logs_actamount_"+param[3]).text(jsonData.actual_amount);
        // if (jsonData.actual_amount < $("p#stock_logs_amount_"+param[3]).text() && jsonData.operation_type == "out") {
        //   $("p#stock_logs_amount_"+param[3]).css("background-color","red");
        // } else {
        //   $("p#"+current.id).css("background-color","transparent");
        // }

        // 20141219
        if (jsonData.stock_log_id != undefined) {
          $("#md_stock_log_"+id).val(jsonData.stock_log_id);
          $("#md_stock_amount_"+id).val(jsonData.total_amount);
          $("#md_amount_"+id).val(jsonData.amount);

          if (amount != jsonData.amount) {
            alert("该明细最大可移库数量：" + jsonData.amount);
          }
          // tableset(param[3],"shelfid",shelfid)
          // tableset(addid,"paid",jsonData.paid)
          // tableset(addid,"status","处理中")
        }
      }
    }
  });

}

function ajaxmovestock() {
  $("input[id^=md_out_shelf]").unbind('railsAutocomplete.select').bind('railsAutocomplete.select', function(event, data){
    $("input[id="+this.id+"][type=text]").val(data.item.value);
    $("input[id="+this.id+"][type=hidden]").val(data.item.id);
    $("input[id="+this.id+"][type=text]").blur();
    param = this.id.split('_');
    rowid = param[3];
    $.ajax({
      type : 'GET',
      url : '/stocks/find_stock_in_shelf/',
      data: { shelf_id: data.item.id,
              row_id: rowid},
      dataType : 'script'
    });
  });

  $("input[id^=md_shelf]").unbind('railsAutocomplete.select').bind('railsAutocomplete.select', function(event, data){
    $("input[id="+this.id+"][type=text]").val(data.item.value);
    $("input[id="+this.id+"][type=hidden]").val(data.item.id);
    $("input[id="+this.id+"][type=text]").blur();
    move_stock_modify(this);
  });

  $("select[id^=md_stock]").change(function(){
    param = this.id.split('_');
    rowid = param[2];
    $.ajax({
      type : 'GET',
      url : '/stocks/find_stock_amount/',
      data: { stock_id: $(this).val(),
              row_id: rowid},
      dataType : 'script'
    });
  });

  $("select[id^=md_stock]").unbind('blur').blur(function() {
    move_stock_modify(this);
  });

  $("input[id^=md_amount]").unbind('blur').blur(function() {
    param = this.id.split('_');

    if ( parseInt($(this).val()) > parseInt($("#md_stock_amount_"+param[2]).val()) ) {
          // alert($(this).val());
          $(this).css("color","red");
    }else{
      $(this).css("color","black");
      move_stock_modify(this);
    }
    
    
  });

}


function manual_stock_add() {
  var tr = $("tr[id^=stock_logs_id]").eq(0).clone();
  var addid = "00";
  if ($("tr[id^=stock_logs_id_0]").last().attr("id") != undefined ) {
    param = $("tr[id^=stock_logs_id_0]").last().attr("id").split('_');
    addid = "0"+ (parseInt(param[3])+1);
  }
  tr.attr("id","stock_logs_id_"+addid);
  tr.appendTo("table#stock_logs");
  
  tablereplace(addid,"p","id",addid);
  tablereplace(addid,"a","id",addid);
  tablereplace(addid,"a","href",addid);
  tablereplace(addid,"input","id",addid);
  tablereplace(addid,"select","id",addid);
  tablereplace(addid,"td","id",addid);

  tableset(addid,"id",addid)
  tableset(addid,"mamount","0")
  tableset(addid,"actamount","0")
  tableset(addid,"mshelfid","")
  tableset(addid,"msid","")
  tableset(addid,"status","处理中")

  ajaxstocklogs();
}


function manual_stock_detail_modify(current){
  param = current.id.split('_');
  id = param[3];
  manualstockid = $("tr#stock_logs_id_"+id+">td>select#stock_logs_msid_"+id).val();
  stockid = $("tr#stock_logs_id_"+id+">td>select#stock_logs_mshelfid_"+id).val();
  stid = $("tr#stock_logs_id_"+id+">td>input[id=stock_logs_stid_"+id+"][type=hidden]").val();
  
  x = param[3].substring(0,1)
  if (x == "0"){
    x = ""
  }
  else {
    x = param[3]
  }
  
  if (manualstockid == null){
    manualstockid = ""
  }

  if (stockid == null || stockid ==""){
    if (stid != null){
      stockid = stid
    }
    else {
      stockid = ""
    }
  }

  $.ajax({
    type: "POST",
    url: "/stock_logs/manual_stock_modify",
    data: "id=" + x + "&amount=" + "" + "&stock_id=" + "" + "&manual_stock_id=" + manualstockid,
    dataType: "json",
    complete: function(data) {
      if (data.success){
        jsonData = eval("("+data.responseText+")");
        // alert(data.responseText);
        var jdata = eval(jsonData.stocks);
        
        var oplength = $("select#stock_logs_mshelfid_"+id).get(0).options.length;
        if(jdata.size!=0){
          if (oplength > 1){
            for (var a = 1; a < oplength; a++) {
              $("select#stock_logs_mshelfid_"+id).remove(a); 
            }
          }
 
          for (var i = 0; i < jdata.length; i++) {
            var optionstring = "<option value=\"" + jdata[i].id;
            
            optionstring = optionstring + "\" >" + jdata[i].name + "</option>";
            
            $("select#stock_logs_mshelfid_"+id).append(optionstring)
          }
        }
      }    
        
    }
  });
}

function manual_stock_modify(current){
  param = current.id.split('_');
  id = param[3];
  amount = $("tr#stock_logs_id_"+id+">td>input#stock_logs_mamount_"+id).val();
  stockid = $("tr#stock_logs_id_"+id+">td>select#stock_logs_mshelfid_"+id).val();
  stid = $("tr#stock_logs_id_"+id+">td>input[id=stock_logs_stid_"+id+"][type=hidden]").val();
  // alert("id"+id+"stockid"+stockid+"stid"+stid);
  manualstockid = $("tr#stock_logs_id_"+id+">td>select#stock_logs_msid_"+id).val();


  x = param[3].substring(0,1)
  if (x == "0"){
    x = ""
  }
  else {
    x = param[3]
  }
  
  if (manualstockid == null){
    manualstockid = ""
  }

  if (stockid == null || stockid ==""){
    if (stid != null){
      stockid = stid
    }
    else {
      stockid = ""
    }
  }
  

  if (amount == null){
    amount = "0"
  }
  // alert("id"+id+" "+"stockid"+stockid+" "+"manualstockid"+manualstockid+" "+"amount"+amount);
  
  $.ajax({
    type: "POST",
    url: "/stock_logs/manual_stock_modify",
    data: "id=" + x + "&amount=" + amount + "&stock_id=" + stockid + "&manual_stock_id=" + manualstockid,
    dataType: "json",
    complete: function(data) {
      if (data.success){
        jsonData = eval("("+data.responseText+")");
        
        // alert(data.responseText);
        // var jdata = eval(jsonData.stocks);
        // // alert(jdata);
        // var oplength = $("#stock_logs_mshelfid_"+id).get(0).options.length;
        // if(jdata.size!=0){
        //   if (oplength > 1){
        //     for (var a = 1; a < oplength; a++) {
        //       $("select#stock_logs_mshelfid_"+id).remove(a); 
        //     }
        //   }
 
        //   for (var i = 0; i < jdata.length; i++) {
        //     var optionstring = "<option value=\"" + jdata[i].id;
        //     optionstring = optionstring + "\" >" + jdata[i].name + "</option>";
        //     // alert("id:"+id);
        //     $("select#stock_logs_mshelfid_"+id).append(optionstring)
        //   }
        // }
        // alert(jsonData.id);
        if (jsonData.id != undefined){
          $("tr#stock_logs_id_"+param[3]).attr("id","stock_logs_id_"+jsonData.id);
          tablereplace(jsonData.id,"p","id",jsonData.id);
          tablereplace(jsonData.id,"a","id",jsonData.id);
          tablereplace(jsonData.id,"a","href",jsonData.id);
          tablereplace(jsonData.id,"input","id",jsonData.id);
          tablereplace(jsonData.id,"select","id",jsonData.id);
          tablereplace(jsonData.id,"td","id",jsonData.id);

          tableset(jsonData.id,"id",jsonData.id)
          tableset(jsonData.id,"mamount",""+jsonData.amount)
          tableset(jsonData.id,"actamount",""+jsonData.total_amount)

          if (amount != jsonData.amount){
            alert("该明细最大可出库数量：" + jsonData.amount);
          }

          
        }
      } 
    }
  });
}



function keyclientorder_stock_add() {
  var tr = $("tr[id^=stock_logs_id]").eq(0).clone();
  var addid = "00";
  if ($("tr[id^=stock_logs_id_0]").last().attr("id") != undefined ) {
    param = $("tr[id^=stock_logs_id_0]").last().attr("id").split('_');
    addid = "0"+ (parseInt(param[3])+1);
  }
  tr.attr("id","stock_logs_id_"+addid);
  tr.appendTo("table#stock_logs");

  tablereplace(addid,"p","id",addid);
  tablereplace(addid,"a","id",addid);
  tablereplace(addid,"a","href",addid);
  tablereplace(addid,"input","id",addid);
  tablereplace(addid,"select","id",addid);
  tablereplace(addid,"td","id",addid);

  tableset(addid,"id",addid)
  tableset(addid,"kamount","0")
  tableset(addid,"actamount","0")
  tableset(addid,"kshelfid","")
  tableset(addid,"ksid","")
  tableset(addid,"status","处理中")
  tableset(addid,"pickshelf","")

  ajaxstocklogs();
}

function keyclientorder_stock_detail_modify(current){
  param = current.id.split('_');
  id = param[3];
  amount = $("tr#stock_logs_id_"+id+">td>input#stock_logs_kamount_"+id).val();
  stockid = $("tr#stock_logs_id_"+id+">td>select#stock_logs_kshelfid_"+id).val();
  ksid = $("tr#stock_logs_id_"+id+">td>select#stock_logs_ksid_"+id).val();
  kcoid = $("tr#stock_logs_id_"+id+">td>input[id=stock_logs_kcoid_"+id+"][type=hidden]").val();
  kstid = $("tr#stock_logs_id_"+id+">td>input[id=stock_logs_kstid_"+id+"][type=hidden]").val();

  x = param[3].substring(0,1)
  if (x == "0"){
    x = ""
  }
  else {
    x = param[3]
  }
  
  if (ksid == null){
    ksid = ""
  }

  if (amount == null){
    amount = "0"
  }

  if (stockid == null || stockid == ""){
    if (kstid != null){
      stockid = kstid
    }
    else {
      stockid = ""
    }
  }

  if (kcoid == null){
    kcoid = ""
  }

  $.ajax({
    type: "POST",
    url: "/stock_logs/keyclientorder_stock_modify",
    data: "id=" + x + "&amount=" + amount + "&stock_id=" + stockid + "&keyclientorder_params=" + ksid + "&keyclientorder=" + kcoid,
    dataType: "json",
    complete: function(data) {
      if (data.success){
        jsonData = eval("("+data.responseText+")");
        // alert(data.responseText);
        var jdata = eval(jsonData.stocks);
        var oplength = $("select#stock_logs_kshelfid_"+id).get(0).options.length;
        
        if(jdata.size!=0){
          if (oplength > 1){
            for (var a = 1; a < oplength; a++) {
              $("select#stock_logs_kshelfid_"+id).remove(a); 
            }
          }
 
          for (var i = 0; i < jdata.length; i++) {
            var optionstring = "<option value=\"" + jdata[i].id;
            optionstring = optionstring + "\" >" + jdata[i].name + "</option>";
            $("select#stock_logs_kshelfid_"+id).append(optionstring)
          }
        }
      }    
        
    }
  });
}

function keyclientorder_stock_modify(current){
  param = current.id.split('_');
  id = param[3];
  amount = $("tr#stock_logs_id_"+id+">td>input#stock_logs_kamount_"+id).val();
  stockid = $("tr#stock_logs_id_"+id+">td>select#stock_logs_kshelfid_"+id).val();
  ksid = $("tr#stock_logs_id_"+id+">td>select#stock_logs_ksid_"+id).val();
  kcoid = $("tr#stock_logs_id_"+id+">td>input[id=stock_logs_kcoid_"+id+"][type=hidden]").val();
  kstid = $("tr#stock_logs_id_"+id+">td>input[id=stock_logs_kstid_"+id+"][type=hidden]").val();
  pshid = $("tr#stock_logs_id_"+id+">td>input[id=stock_logs_pickshelf_"+id+"][type=hidden]").val();

  x = param[3].substring(0,1)
  if (x == "0"){
    x = ""
  }
  else {
    x = param[3]
  }
  
  if (ksid == null){
    ksid = ""
  }

  if (amount == null){
    amount = "0"
  }

  if (stockid == null || stockid == ""){
    if (kstid != null){
      stockid = kstid
    }
    else {
      stockid = ""
    }
  }

  if (kcoid == null){
    kcoid = ""
  }

  if (pshid == null){
    pshid = ""
  }
  // alert(x+" "+stockid+" "+ksid+" "+kcoid);
  $.ajax({
    type: "POST",
    url: "/stock_logs/keyclientorder_stock_modify",
    data: "id=" + x + "&amount=" + amount + "&stock_id=" + stockid + "&keyclientorder_params=" + ksid + "&keyclientorder=" + kcoid + "&pickshelfid=" + pshid,
    dataType: "json",
    complete: function(data) {
      if (data.success){
        jsonData = eval("("+data.responseText+")");
        
        if (jsonData.id != undefined){
          $("tr#stock_logs_id_"+param[3]).attr("id","stock_logs_id_"+jsonData.id);
          tablereplace(jsonData.id,"p","id",jsonData.id);
          tablereplace(jsonData.id,"a","id",jsonData.id);
          tablereplace(jsonData.id,"a","href",jsonData.id);
          tablereplace(jsonData.id,"input","id",jsonData.id);
          tablereplace(jsonData.id,"select","id",jsonData.id);
          tablereplace(jsonData.id,"td","id",jsonData.id);


          tableset(jsonData.id,"id",jsonData.id)
          tableset(jsonData.id,"kamount",""+jsonData.amount)
          tableset(jsonData.id,"actamount",""+jsonData.total_amount)
          tableset(jsonData.id,"pickshelf",""+jsonData.pick_shelf)

          if (amount != jsonData.amount){
            alert("该明细最大可出库数量：" + jsonData.amount);
          }

          
        }
      } 
    }
  });
}


function order_return_add() {
  var tr = $("tr[id^=stock_logs_id]").eq(0).clone();
  var addid = "00";
  if ($("tr[id^=stock_logs_id_0]").last().attr("id") != undefined ) {
    param = $("tr[id^=stock_logs_id_0]").last().attr("id").split('_');
    addid = "0"+ (parseInt(param[3])+1);
  }
  tr.attr("id","stock_logs_id_"+addid);
  tr.appendTo("table#stock_logs");
  
  tablereplace(addid,"p","id",addid);
  tablereplace(addid,"a","id",addid);
  tablereplace(addid,"a","href",addid);
  tablereplace(addid,"input","id",addid);
  tablereplace(addid,"select","id",addid);
  tablereplace(addid,"td","id",addid);

  tableset(addid,"id",addid)
  tableset(addid,"oamount","0")
  tableset(addid,"actamount","0")
  tableset(addid,"oshelfid","")
  tableset(addid,"orid","")
  tableset(addid,"status","处理中")

  ajaxstocklogs();
}


function order_return_modify(current)
{
  param = current.id.split('_');
  id = param[3];
  amount = $("tr#stock_logs_id_"+id+">td>input#stock_logs_oamount_"+id).val();
  shelfid = $("tr#stock_logs_id_"+id+">td>input[id=stock_logs_oshelfid_"+id+"][type=hidden]").val();
  orid = $("tr#stock_logs_id_"+id+">td>select#stock_logs_orid_"+id).val();

  var x = param[3].substring(0,1)
  if (x == "0") {
    x = ""
  } else {
    x = param[3]
  }
  if (orid == null) {
    orid = ""
  }
  // alert("id"+id+"shelfid"+shelfid+"orid"+orid+"amount"+amount);

  $.ajax({
    type: "POST",
    url: "/stock_logs/order_return_modify",
    data: "id=" + x + "&amount=" + amount + "&shelf_id=" + shelfid + "&order_return_detail_id=" + orid,
    dataType: "json",
    complete: function(data) {
      if(data.success){
        var jsonData = eval("("+data.responseText+")");
        // alert(data.responseText);
        
        if (jsonData.id != undefined) {
          $("tr#stock_logs_id_"+param[3]).attr("id","stock_logs_id_"+jsonData.id);
          tablereplace(jsonData.id,"p","id",jsonData.id);
          tablereplace(jsonData.id,"a","id",jsonData.id);
          tablereplace(jsonData.id,"a","href",jsonData.id);
          tablereplace(jsonData.id,"input","id",jsonData.id);
          tablereplace(jsonData.id,"select","id",jsonData.id);
          tablereplace(jsonData.id,"td","id",jsonData.id);

          tableset(jsonData.id,"id",jsonData.id)
          tableset(jsonData.id,"oamount",""+jsonData.amount)
          tableset(jsonData.id,"actamount",""+jsonData.total_amount)

          if (amount != jsonData.amount) {
            alert("该明细最大可入库数量：" + jsonData.amount);
          }
          // tableset(param[3],"shelfid",shelfid)
          // tableset(addid,"paid",jsonData.paid)
          // tableset(addid,"status","处理中")
        }
      }
    }
  });
}

function add_inventory_dtl(){
  var tr = $("tr[id^=stock_logs_id]").eq(0).clone();
  var addid = "00";
  if ($("tr[id^=stock_logs_id]").last().attr("id") != undefined ) {
    param = $("tr[id^=stock_logs_id]").last().attr("id").split('_');
    addid = "0"+ (parseInt(param[3])+1);
  }
  tr.attr("id","stock_logs_id_"+addid);
  tr.appendTo("table#stock_logs");
  var addtd = "<td><a class=\"btn btn-xs btn-danger\" href=\"javascript:void(0);\" id=\"stock_logs_deletelink_"+addid+"\" onclick=\"destroy(this)\">删除</a></td>"
  tr.append(addtd);
  // slid=$('table.wice-grid tr:eq(2) input').first().val();
  // var index=tr.index()+2;
  // addTr(slid,index);
  tablereplace(addid,"a","id",addid);
  tablereplace(addid,"a","href",addid);
  tablereplace(addid,"input","id",addid);
  tablereplace(addid,"select","id",addid);
  tablereplace(addid,"td","id",addid);

  tableset(addid,"id",addid)
  tableset(addid,"invactamount","0")
  tableset(addid,"invamount","")
  tableset(addid,"invshelfid","0")
  tableset(addid,"relationshipid","")
  tableset(addid,"invstatus","处理中")
  
  ajaxinventory();
}

function inventory_modify(current)
{
  param = current.id.split('_');
  id = param[3];
  shelfid = $("#stock_logs_invshelfid_"+id).val();
  relid = $("input[id=stock_logs_relationshipid_"+id+"][type=hidden]").val();
  amount = $("#stock_logs_invamount_"+id).val();
  invid = $("#inventoryid").val();
  var x = param[3].substring(0,1)
  if (x == "0") {
    x = ""
  } else {
    x = param[3]
  }
  if (shelfid == null) {
    shelfid = ""
  }
  if (relid == null) {
    relid = ""
  }
  if (amount == null) {
    amount = ""
  }
  // alert("id"+id+"shelfid"+shelfid+"orid"+orid+"amount"+amount);

  $.ajax({
    type: "POST",
    url: "/stock_logs/inventory_modify",
    data: "slid=" + x + "&amount=" + amount + "&shelf_id=" + shelfid + "&rel_id=" + relid + "&inv_id=" + invid,
    dataType: "json",
    complete: function(data) {
      if(data.success){
        var jsonData = eval("("+data.responseText+")");
        // alert(data.responseText);
        
        if (jsonData.stock_log_id != undefined) {
          $("tr#stock_logs_id_"+param[3]).attr("id","stock_logs_id_"+jsonData.stock_log_id);

          tablereplace(jsonData.stock_log_id,"a","id",jsonData.stock_log_id);
          tablereplace(jsonData.stock_log_id,"a","href",jsonData.stock_log_id);
          tablereplace(jsonData.stock_log_id,"input","id",jsonData.stock_log_id);
          tablereplace(jsonData.stock_log_id,"select","id",jsonData.stock_log_id);
          tablereplace(jsonData.stock_log_id,"td","id",jsonData.stock_log_id);

          tableset(jsonData.stock_log_id,"invamount",jsonData.amount)

        }
      }
    }
  });
}

function ajaxinventory() {

  $("select[id^=stock_logs_invshelfid]").unbind('blur').blur(function() {
    inventory_modify(this);
  });

  $("input[id^=stock_logs_relationshipid]").unbind('railsAutocomplete.select').bind('railsAutocomplete.select', function(event, data){
    $("input[id="+this.id+"][type=text]").val(data.item.value);
    $("input[id="+this.id+"][type=hidden]").val(data.item.id);
    $("input[id="+this.id+"][type=text]").blur();

    param = this.id.split('_');
    id = param[3];
    alert(id);
    var shelfid = $("#stock_logs_invshelfid_"+id).val();
    if (shelfid == null) {
      shelfid = ""
    }

    $.ajax({
    type: "POST",
    url: "/inventories/find_stamt",
    data: "rel_id=" + data.item.id + "&shelf_id=" + shelfid,
    dataType: "json",
    complete: function(data) {
      if(data.success){
        var jsonData = eval("("+data.responseText+")");

          tableset(id,"invactamount",jsonData.actual_amount)
          tableset(id,"invamount","")

        }
      }
    });
  });

  $("input[id^=stock_logs_relationshipid]").unbind('blur').blur(function() {
    inventory_modify(this);
  });

  $("input[id^=stock_logs_invamount]").unbind('blur').blur(function() {
    inventory_modify(this);
  });

}

function showgrid() {
  $("#inventory_inv_type").change(function(){
    var i = $("#inventory_inv_type").val();
    var el1 = document.getElementById("grid1")
    var el2 = document.getElementById("grid2")

    if (i == 'byshelf'){
      el2.style.display = 'none';
      el1.style.display = 'block';
    }else{
      el1.style.display = 'none';
      el2.style.display = 'block';
    }
   
  })

}

