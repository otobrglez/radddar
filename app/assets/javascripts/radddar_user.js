/* By Oto Brglez - <oto.brglez@opalab.com> */

var User = new function(){

	/* Get current user object */
	this.get = function(id, callback){
		$.getJSON("/profile/"+id+".json",function(data){
			if(typeof(callback) != "undefined")
				return callback(data);
		});
	};

};