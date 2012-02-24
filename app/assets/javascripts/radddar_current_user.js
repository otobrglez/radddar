/* By Oto Brglez - <oto.brglez@opalab.com> */

var CurrentUser = new function(){

	/* Get current user object */
	this.current_user = function(callback){
		$.getJSON("/current_user.json",function(data){
			if(typeof(callback) != "undefined") callback(data);
		});
	};

};