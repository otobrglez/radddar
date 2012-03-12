/* By Oto Brglez - <oto.brglez@opalab.com> */

var CurrentUser = new function(){

	this.data = null;

	/* Get current user object */
	this.current_user = function(callback){
		$.getJSON("/current_user.json",function(data){
			this.data = data;
			if(typeof(callback) != "undefined")
				return callback(data);
		});
	};

	/* Get current user */
	this.get = function(callback){
		this.current_user(callback)
	};

	/* Set fileds for user */
	this.set = function(user_data,callback){
		$.post('/profile_update.json',{user:user_data},function(data){
			if(typeof(callback) != "undefined")
				return callback(data);
		});
	};

};