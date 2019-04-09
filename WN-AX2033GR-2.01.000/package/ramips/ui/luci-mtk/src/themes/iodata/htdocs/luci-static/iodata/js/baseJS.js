function MM_showHideLayers() {for (i=0; i<(args.length-2); i+=3) if ((obj=MM_findObj(args[i]))!=null) { v=args[i+2];if (obj.style) { obj=obj.style; v=(v=='show')?'visible':(v=='hide')?'hidden':v; }obj.visibility=v; }}
function ConfirmDefault(){	if (confirm("Are you sure you want to reset the device back to the factory defaults?This will erase all of your custom configuration.")){ document.Config.submit();}}function MM_findObj(n, d) {var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layer[i].document);if(!x && d.getElementById) x=d.getElementById(n); return x;}
function MM_showHideLayers() {var i,p,v,obj,args=MM_showHideLayers.arguments;for (i=0; i<(args.length-2); i+=3) if ((obj=MM_findObj(args[i]))!=null) { v=args[i+2];if (obj.style) { objobj.style; v=(v=='show')?'visible':(v=='hide')?'hidden':v; }obj.visibility=v; }}
function MM_goToURL() {var i, args=MM_goToURL.arguments; document.MM_returnValue = false;for (i=0; i<(args.length-1); i+=2) eval(args[i]+".location='"+args[i+1]+"'");}

/* 2012.8.2 mark by jeffary
function showFullPath(str){fr =2;parent.frames[fr].document.open();parent.frames[fr].document.writeln(' <html>');parent.frames[fr].document.writeln(' <head>');parent.frames[fr].document.writeln(' <meta http-equiv=\"Content-Type\" content=\"text\/html; charset=iso-8859-1\">');	parent.frames[fr].document.writeln(' <title>.::Welcome to Mitrastar::.<\/title>');parent.frames[fr].document.writeln(' <link href=\"..\/css\/expert.css\" rel=\"stylesheet\" type=\"text/css\">');parent.frames[fr].document.writeln(' <\/head>');parent.frames[fr].document.writeln(' <body>');	parent.frames[fr].document.writeln(' <div class=\"path\">');parent.frames[fr].document.writeln(' <span class=\"i_path\">'+str+'<\/span>');parent.frames[fr].document.writeln(' <\/div>');parent.frames[fr].document.writeln(' <\/body>');parent.frames[fr].document.writeln(' <\/html>');	parent.frames[fr].document.close();}
*/
/* MSTC, Sharon, change the path name in path.htm */
function showFullPath(str)
{
	if (top.topFrame1.ChangePagePath != undefined )
		top.topFrame1.ChangePagePath(str);
}
function MM_showHideLayers() {var i,p,v,obj,args=MM_showHideLayers.arguments;for (i=0; i<(args.length-2); i+=3) if ((obj=MM_findObj(args[i]))!=null) { v=args[i+2]; if (obj.style) { obj=obj.style; v=(v=='show')?'visible':(v=='hide')?'hidden':v; }obj.visibility=v; }}
function MM_openBrWindow(theURL,winName,features) {  window.open(theURL,winName,features);}
function MM_preloadImages() { var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array(); var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}}
function MM_swapImgRestore() { var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;}
function MM_swapImage() {var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}}
//function checkLogout(){var flag;flag=confirm("Are you sure you want to log out?");if (flag)top.location.href="/";}
//function checkExit(){var flag;flag=confirm("Are you sure you want to Exit");if (flag)top.location.href="/";}
function showtab(){var string = document.getElementById("advanced").style.display;if (string == ""){document.getElementById("advanced").style.display = "none";document.getElementById("showWord").innerHTML = "more...";}else if (string =="none"){document.getElementById("advanced").style.display = "";document.getElementById("showWord").innerHTML = "hide more";}}
function MM_popupMsg(msg) { alert(msg);}
/* MSTC, Sharon, change web message in under.htm */
function showWebMessage(code, msg1, msg2)
{
	if (top.underFrame.ChangeMessage != undefined )
		top.underFrame.ChangeMessage(code, msg1, msg2);
}
function checkIpFormat(ipaddr){var i; var ipPattern = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/; var ipArray = ipaddr.match(ipPattern); if(ipaddr == "0.0.0.0"){ alert("special ip address [" + ipaddr + "] !"); return false;}if(ipArray == null){alert("invalid ip address [" + ipaddr + "] !");return false;}for(i=1;i<5;i++){if(ipArray[i] >= 255){alert("invalid ip address [" + ipaddr + "] !");return false;}}return true;}

function openwaitblock(blocktype, msg) 
{
	if(blocktype == 1) /* loading */
	{	
		if ( top.mainFrame.$.blockUI )
			top.mainFrame.$.blockUI({ message: '<img src="/luci-static/mitrastar/admin/images/loading.gif"/>' }); 
	}
	else if(blocktype == 2) /* loading with message */
	{
		if ( top.mainFrame.$.blockUI )
			top.mainFrame.$.blockUI({ message: '<img src="/luci-static/mitrastar/admin/images/loading.gif"/>'+'<h1>'+msg+'</h1>', css: { color:'#000', border:'2px solid #aaa', backgroundColor:'#fff', width:'15%'}}); 
	}
	
	if ( top.pannel.$.blockUI )
		top.pannel.$.blockUI({message: null});
	if ( top.underFrame.$.blockUI )
		top.underFrame.$.blockUI({message: null});
	if ( top.topFrame.$.blockUI )
		top.topFrame.$.blockUI({message: null});	
	if ( top.topFrame1.$.blockUI )
		top.topFrame1.$.blockUI({message: null});

}

function closewaitblock() 
{
	if ( top.mainFrame.$.unblockUI != undefined )
		top.mainFrame.$.unblockUI();

	if ( top.pannel.$.unblockUI )
		top.pannel.$.unblockUI();
	if ( top.topFrame1.$.unblockUI )
		top.topFrame1.$.unblockUI(); 
	if ( top.topFrame.$.unblockUI )
		top.topFrame.$.unblockUI(); 
	if ( top.underFrame.$.unblockUI )
		top.underFrame.$.unblockUI(); 

}

function chkIP(address) { 
		var IP = address;        
        IP = IP.replace(/ /g, "");
        //address.value = IP;
        var IPsplit = IP.split(".");
        if(IPsplit.length != 4) {
            //alert("<%:LAN_Error_1%>");
            return false;
        }
        //check first,and last byte is zero
        if((IPsplit[0] == "0") || (IPsplit[3] == "0")){
            //alert("<%:LAN_Error_1%>");
                return false;
        }
        for(i = 0; i < 4; i++)
            if((isNaN(IPsplit[i])) || (IPsplit[i] == undefined) || (IPsplit[i] == "")) {
                //alert("<%:LAN_Error_1%>");
                return false;
        } else
        if((parseInt(IPsplit[i], 10) > 255) || (parseInt(IPsplit[i], 10) < 0)) {
                    //alert("<%:LAN_Error_1%>");
                    return false;
        }
        return true;
}


function chkSubnetMask(address) {  //dedy this func is call at line 814,1246
        var SNMask = address;
        var SNMaskRanhge=[255,254,252,248,240,224,192,182,128];
        var Valid=0;
        SNMask = SNMask.replace(/ /g, "");
        //address.value = SNMask;
        var SNMaskSplit = SNMask.split(".");
        if(SNMaskSplit.length != 4) {
            //alert("<%:LAN_Error_2%>");
            return false;
        }
        for(i = 3; i >= 0; i--){
            if(Valid==0){
                for(j=0;j<SNMaskRanhge.length;j++){
                    if(parseInt(SNMaskSplit[i], 10) == SNMaskRanhge[j]) {
                        Valid=1;
                    }
                }
                if((Valid==0) && (parseInt(SNMaskSplit[i], 10) != 0)) break;
            }else{
                if(parseInt(SNMaskSplit[i], 10) != 255)  {
                        Valid=0;
                        break;
                }                
            }
            if(isNaN(SNMaskSplit[i])) {
                Valid=0;
                break;
            }
        }
        if(Valid==0){
            //alert("<%:LAN_Error_2%>");
            return false;                    
        }
        return true;
}

function atoi(str, num)
{
	i = 1;
	if (num != 1) {
		while (i != num && str.length != 0) {
			if (str.charAt(0) == '.') {
				i++;
			}
			str = str.substring(1);
		}
		if (i != num)
			return -1;
	}

	for (i=0; i<str.length; i++) {
		if (str.charAt(i) == '.') {
			str = str.substring(0, i);
			break;
		}
	}
	if (str.length == 0)
		return -1;
	return parseInt(str, 10);
}

function checkIpValid(lanIp, lanMask)
{
  ip_1 = atoi(lanIp, 1);
  mask_1 = atoi(lanMask, 1);
  subNet_1 = ip_1 & mask_1;
  
  ip_2 = atoi(lanIp, 2);
  mask_2 = atoi(lanMask, 2);
  subNet_2 = ip_2 & mask_2;
  
  ip_3 = atoi(lanIp, 3);
  mask_3 = atoi(lanMask, 3);
  subNet_3 = ip_3 & mask_3;
  
  ip_4 = atoi(lanIp, 4);
  mask_4 = atoi(lanMask, 4);
  subNet_4 = ip_4 & mask_4;
  
  subNet = subNet_1 + "." + subNet_2 +"." + subNet_3 + "." + subNet_4;
  if(lanIp == subNet) //all bits of ip representation for station part are all "0" 
  {
     //alert("Invalid Lan IP Address.");
     //document.lanCfg.lanIp.value = document.lanCfg.lanIp.defaultValue;
     //document.lanCfg.lanIp.focus();
     return false;
  }

   if(lanMask == "255.255.255.252")
   {
      subNet_4 = subNet_4 + 3; //all bits of ip representation for station part are all "1" 
   }
   else if(lanMask == "255.255.255.248")
   {
      subNet_4 = subNet_4 + 7;
   }
   else if(lanMask == "255.255.255.240")
   {
      subNet_4 = subNet_4 + 15;
   }
   else if(lanMask == "255.255.255.224")
   {
      subNet_4 = subNet_4 + 31;
   }
   else if(lanMask == "255.255.255.192")
   {
      subNet_4 = subNet_4 + 63;
   }
   else if(lanMask == "255.255.255.128")
   {
      subNet_4 = subNet_4 + 127;
   }
   else if(lanMask == "255.255.255.0")
   {
      subNet_4 = subNet_4 + 255;
   }

   subNet = subNet_1 + "." + subNet_2 +"." + subNet_3 + "." + subNet_4;
   if(lanIp == subNet) //all bits of ip representation for station part are all "1" 
   {
     //alert("Invalid Lan IP Address.");
     //document.lanCfg.lanIp.value = document.lanCfg.lanIp.defaultValue;
     //document.lanCfg.lanIp.focus();
     return false;
   }

   return true;
}

function ip2long(ip){
    var components;

    if(components = ip.match(/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/))
    {
        var iplong = 0;
        var power  = 1;
        for(var i=4; i>=1; i-=1)
        {
            iplong += power * parseInt(components[i]);
            power  *= 256;
        }
        return iplong;
    }
    else return -1;
};

function inSubNet(ip, subnet)
{   
    var mask, base_ip, long_ip = ip2long(ip);
    if( (mask = subnet.match(/^(.*?)\/(\d{1,2})$/)) && ((base_ip=ip2long(mask[1])) >= 0) )
    {
        var freedom = Math.pow(2, 32 - parseInt(mask[2]));
        return (long_ip > base_ip) && (long_ip < base_ip + freedom - 1);
    }
    else return false;
};

function checkInvalidIP(ip)
{
	if (!chkIP(ip)) {
		return false;
	}
	if(ip == "255.255.255.255") {
		return false;
	}
	if( inSubNet(ip,'240.0.0.0/4') ){
		return false;
	}
	if( inSubNet(ip,'224.0.0.0/4') ){
		return false;
	}
	if( inSubNet(ip,'127.0.0.0/8') ){
		return false;
	}
	
	return true;
		
}

function htmlEncode(value){
	if (value) {
		return $('<div/>').text(value).html();
	} else {
		return '';
	}
}

function htmldecode(value) {
	if (value) {
		return $('<div />').html(value).text();
	} else {
		return '';
	}
}

function find_last_index(stringToCount, max_length)  
{
	var length = 0;
	for( var i =0; i < stringToCount.length; i++) {
		if (stringToCount.charAt(i).match(/[^ -~]/g)) {
			length = length + 2;
		}
		else {
			length = length + 1;
		}
		
		if ( length > max_length ) {
			return i;
		}
	}
	return -1;
}

function checkssidlen(id)
{
	ssid = document.getElementById(id);
	var end_index = find_last_index(ssid.value, 32);
	if( end_index != -1 ) {
		ssid.value = ssid.value.substring(0, end_index);
	}
}

var reg_hostname = /^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/g;
var available_char_64 = /^[\ \!\#\$\%\&\(\)\*\+\-\.\/0-9\:\;\=\?\@A-Z\[\]\_a-z\{\}\~]{0,64}$/;
var available_char_16 = /^[\ \!\#\$\%\&\(\)\*\+\-\.\/0-9\:\;\=\?\@A-Z\[\]\_a-z\{\}\~]{0,16}$/;

function isASCII(str) {
    return /^[\x00-\x7F]*$/.test(str);
}
