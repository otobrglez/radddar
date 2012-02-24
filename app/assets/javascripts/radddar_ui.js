/* By Oto Brglez - <oto.brglez@opalab.com> */

$(function(){

	$("#app").radddar_navigation();
	$("#app .selector").radddar_selector();
	$("#app .profile_header").radddar_status();
	
	// map_initialize();	

	$(document).bind("nav:pre_tab_switch",function(e){
		console.log("from: "+e.current_tab+" to:"+e.tab);
	});

});