﻿function getLodop(oOBJECT,oEMBED){
/**************************
  本函数根据浏览器类型决定采用哪个对象作为控件实例：
  IE系列、IE内核系列的浏览器采用oOBJECT，
  其它浏览器(Firefox系列、Chrome系列、Opera系列、Safari系列等)采用oEMBED。
**************************/
        var strHtml1="<br><font color='#FF00FF'>打印控件未安装!点击这里<a href='/install_lodop.exe'>执行安装</a>,安装后请刷新页面或重新进入。</font>";
        var strHtml2="<br><font color='#FF00FF'>打印控件需要升级!点击这里<a href='/install_lodop.exe'>执行升级</a>,升级后请重新进入。</font>";
        var strHtml3="<br><br><font color='#FF00FF'>注意：<br>1：如曾安装过Lodop旧版附件npActiveXPLugin,请在【工具】->【附加组件】->【扩展】中先卸它;<br>2：如果浏览器表现出停滞不动等异常，建议关闭其“plugin-container”(网上搜关闭方法)功能;</font>";
        var LODOP=oEMBED;		
	try{		     
	     if (navigator.appVersion.indexOf("MSIE")>=0) LODOP=oOBJECT;

	     if ((LODOP==null)||(typeof(LODOP.VERSION)=="undefined")) {
		 if (navigator.userAgent.indexOf('Firefox')>=0)
  	         document.documentElement.innerHTML=strHtml3+document.documentElement.innerHTML;
		 if (navigator.appVersion.indexOf("MSIE")>=0) document.write(strHtml1); else
		 document.documentElement.innerHTML=strHtml1+document.documentElement.innerHTML;
		 return LODOP; 
	     } else if (LODOP.VERSION<"6.0.5.6") {
		 if (navigator.appVersion.indexOf("MSIE")>=0) document.write(strHtml2); else
		 document.documentElement.innerHTML=strHtml2+document.documentElement.innerHTML; 
		 return LODOP;
	     }
	     //*****如下空白位置适合调用统一功能:*********	     


	     //*******************************************
	     return LODOP; 
	}catch(err){
	     document.documentElement.innerHTML="Error:"+strHtml1+document.documentElement.innerHTML;
	     return LODOP; 
	}
}

String.prototype.trim = function()
{
    return this.replace(/(^\s*)|(\s*$)/g, "");
}

function CurentTime(addtime,flag)   
    {   
        var now = new Date();    
        var year = now.getFullYear();       //年   
        var month = now.getMonth() + 1;     //月   
        var day = now.getDate();            //日

        var hh = now.getHours(); //时
        var mm = (now.getMinutes() + addtime) % 60;  //分
        if ((now.getMinutes() + addtime) / 60 > 1) {
            hh += Math.floor((now.getMinutes() + addtime) / 60);
        }
         if(flag==0){
        var clock = year + "-";   
         
        if(month < 10)   
            clock += "0";   
         
        clock += month + "-";   
         
        if(day < 10)   
            clock += "0";   
             
        clock += day + " ";   
         
        if(hh < 10)   
            clock += "0";   
             
        clock += hh + ":";   
        if (mm < 10) clock += '0';   
        clock += mm;
        }
        if(flag==1){
        	var clock = year + "年";   
         
        if(month < 10)   
            clock += "0";   
         
        clock += month + "月";   
         
        if(day < 10)   
            clock += "0";   
             
        clock += day + "日";
        }   
        return(clock);
    }


function stockin_preview() { 
    CreateStockinPage();  
    LODOP.PREVIEW();  
  }; 
  function stockout_preview() { 
    CreateStockoutPage();  
    LODOP.PREVIEW();  
  }; 
  function tracking1_preview() {

  	if(document.getElementById('num').value.trim()==''){
		alert('请输入面单号');
		return false;
	}
  	LODOP=getLodop(document.getElementById('LODOP_OB'),document.getElementById('LODOP_EM'));
    LODOP.SET_PRINT_PAGESIZE(1,"230mm","127mm","");
    LODOP.PRINT_INITA("-5.5mm","-3mm","232mm","130.7mm","");
    CreateTracking1Page();  
    LODOP.PREVIEW();
    return true;
  }; 
  